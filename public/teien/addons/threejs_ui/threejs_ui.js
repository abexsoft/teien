(function(){
    var scripts = new Array(
        'teien/addons/threejs_ui/three.js/build/three.min.js',
        'teien/addons/threejs_ui/three.js/examples/js/controls/OrbitControls.js'
    );
    for (var i=0; i<scripts.length; i++) {
        document.write('<script type="text/javascript" src="' + scripts[i] + '"><\/script>');
    }
})();


teien.ThreejsUi = function(container, options){
    this.container = container;

    this.options = options || {}
    
    this.options.shadow = this.options.shadow !== undefined ? this.options.shadow : false;
};

teien.ThreejsUi.prototype.setup = function(){
    this.renderer = new THREE.WebGLRenderer({antialias:true});
    this.renderer.setSize( window.innerWidth, window.innerHeight );

    if (this.options.shadow)
        this.renderer.shadowMapEnabled = true;
        
    if (typeof this.container === 'undefined') 
        document.body.appendChild( this.renderer.domElement );
    else
        this.container.appendChild( this.renderer.domElement );
        
    this.camera = new THREE.PerspectiveCamera(60, 
                                              window.innerWidth / window.innerHeight, 
                                              1, 1000 );
    this.camera.position.y = 30;
    this.camera.position.z = 30;    
    this.camera.lookAt(new THREE.Vector3( 0, 0, 0 ));
    
    this.scene = new THREE.Scene();
    
    window.addEventListener( 'resize', this.onWindowResize.bind(this), false );
    
    this.controls = new THREE.OrbitControls(this.camera);
    
    this.viewActors = {}

// for testing    
//    pointLight = new THREE.PointLight( 0xff4400, 5, 30 );
//    pointLight.position.set(5, 0, 0 );
///    this.scene.add( pointLight );
};

teien.ThreejsUi.prototype.onWindowResize = function(s){
    this.camera.aspect = window.innerWidth / window.innerHeight;
    this.camera.updateProjectionMatrix();
    
    this.renderer.setSize( window.innerWidth, window.innerHeight );
};

teien.ThreejsUi.prototype.update = function(delta, actors) {
    for (var i in actors) {
        var actor = actors[i];
        if (actor.ext_info.threejs){
            if (this.viewActors[actor.name] == undefined){
                viewActor = teien.ThreejsUi.createViewActor(actor, this.scene);
                viewActor.setup(this.scene);
                actor.attach(viewActor);
                this.viewActors[actor.name] = viewActor;
            }
            
        }
    }
    this.controls.update(delta * 1000);
    
    this.renderer.render(this.scene, this.camera);
};

teien.ThreejsUi.createViewActor = function(actor, scene){
    var viewActor = null;

    if (actor.ext_info.threejs.spot_light){
        viewActor = new teien.ThreejsUi.SpotLightViewActor(actor);                
    }
    else if (actor.ext_info.threejs.mesh){
        viewActor = new teien.ThreejsUi.MeshViewActor(actor);        
    }
    else if (actor.ext_info.threejs.json){
        viewActor = new teien.ThreejsUi.JsonViewActor(actor, scene);        
    }
    else{
        console.log("No such view actor tyep: " + actor.ext_info.threejs.type + "\n");        
    }
    return viewActor;
};

teien.ThreejsUi.createTexture = function(params){
    var texture = null;
    if (params.texture){
        texture = THREE.ImageUtils.loadTexture(params.texture.image,
                                               params.texture.wrapS,
                                               params.texture.wrapT,
                                               params.texture.magFilter,
                                               params.texture.minFilter,
                                               params.texture.format,
                                               params.texture.type,
                                               params.texture.anisotropy
                                              );
    }
    else {
        console.log("Error: no such texture type.\n");
    }

    return texture;
};


//
// LightViewActor
//
teien.ThreejsUi.SpotLightViewActor = function(actor){
    this.actor = actor;
    
    var params = actor.ext_info.threejs.spot_light;

    this.light = new THREE.SpotLight(params.hex,
                                     params.intensity,
                                     params.distance,
                                     params.angle,
                                     params.exponent);
};

teien.ThreejsUi.SpotLightViewActor.prototype.setup = function(scene){
    var pos = this.actor.getPosition();
    this.light.position.x = pos.x;
    this.light.position.y = pos.y;
    this.light.position.z = pos.z;

    var rot = this.actor.getRotation();
    this.light.quaternion.x = rot.x;
    this.light.quaternion.y = rot.y;
    this.light.quaternion.z = rot.z;
    this.light.quaternion.w = rot.w;    
    
//    this.mesh.castShadow = true;
    scene.add( this.light );
    
    console.log('add light');
};

teien.ThreejsUi.SpotLightViewActor.prototype.update = function(delta){
    //console.log(this.actor.name + " update()\n");
    
    var pos = this.actor.getPosition();
    
    this.light.position.x = pos.x;
    this.light.position.y = pos.y;
    this.light.position.z = pos.z;

    var rot = this.actor.getRotation();
    this.light.quaternion.x = rot.x;
    this.light.quaternion.y = rot.y;
    this.light.quaternion.z = rot.z;
    this.light.quaternion.w = rot.w;        
};


//
// MeshViewActor
//
teien.ThreejsUi.MeshViewActor = function(actor){
    this.actor = actor;
    
    var threejs_params = {};
    
    // Geometry
    var geometry = null;
    var geometry_params = actor.ext_info.threejs.mesh.geometry;
    if (geometry_params.sphere) {
        geometry = new THREE.SphereGeometry(geometry_params.sphere.radius,
                                            geometry_params.sphere.widthSegments,
                                            geometry_params.sphere.heightSegments,
                                            geometry_params.sphere.phiStart,
                                            geometry_params.sphere.phiLength,
                                            geometry_params.sphere.thetaStart,
                                            geometry_params.sphere.thetaLength);
    }
    else if (geometry_params.box) {
        geometry = new THREE.BoxGeometry(geometry_params.box.width,
                                         geometry_params.box.height,
                                         geometry_params.box.depth,
                                         geometry_params.box.widthSegments,
                                         geometry_params.box.heightSegments,
                                         geometry_params.box.depthSegments);
    }    
    else {
        console.log("Error: no such geometry.\n");
    }

    // Material
    threejs_params = {};
    var material = null;
    var material_params = actor.ext_info.threejs.mesh.material;
    if (material_params.mesh_basic_material) {
        if (material_params.mesh_basic_material.color)
            threejs_params['color'] = material_params.mesh_basic_material.color;
        if (material_params.mesh_basic_material.map)
            threejs_params['map'] = teien.ThreejsUi.createTexture(material_params.mesh_basic_material.map)

        material = new THREE.MeshBasicMaterial(threejs_params);
    }
    else {
        console.log("Error: no such material.\n");        
    }
    this.mesh = new THREE.Mesh(geometry, material);
};

teien.ThreejsUi.MeshViewActor.prototype.setup = function(scene){
    var pos = this.actor.getPosition();
    this.mesh.position.x = pos.x;
    this.mesh.position.y = pos.y;
    this.mesh.position.z = pos.z;

    var rot = this.actor.getRotation();
    this.mesh.quaternion.x = rot.x;
    this.mesh.quaternion.y = rot.y;
    this.mesh.quaternion.z = rot.z;
    this.mesh.quaternion.w = rot.w;    
    
//    this.mesh.castShadow = true;
    scene.add( this.mesh );
    
    console.log('add mesh');
};

teien.ThreejsUi.MeshViewActor.prototype.update = function(delta){
    //console.log(this.actor.name + " update()\n");
    
    var pos = this.actor.getPosition();
    
    this.mesh.position.x = pos.x;
    this.mesh.position.y = pos.y;
    this.mesh.position.z = pos.z;

    var rot = this.actor.getRotation();
    this.mesh.quaternion.x = rot.x;
    this.mesh.quaternion.y = rot.y;
    this.mesh.quaternion.z = rot.z;
    this.mesh.quaternion.w = rot.w;        
};

//
// JsonViewActor
//
teien.ThreejsUi.JsonViewActor = function(actor, scene){
    this.actor = actor;
    this.scene = scene;

    console.log("JsonViewActor");
    
    var json_params = actor.ext_info.threejs.json;

    var loader = new THREE.JSONLoader();
    loader.load(json_params.url, this.loadHandler.bind(this));
};

teien.ThreejsUi.JsonViewActor.prototype.loadHandler = function(geometry, materials){
    console.log("loadHandler is called.");
    
    // adjust color a bit
    var material = materials[ 0 ];
    material.morphTargets = true;
    material.color.setHex( 0xffaaaa );
    
    var faceMaterial = new THREE.MeshFaceMaterial( materials );
    this.morph = new THREE.MorphAnimMesh( geometry, faceMaterial );
    
    // one second duration
    this.morph.duration = 1;
    
    // random animation offset
    this.morph.time = 1000 * Math.random();
    
    this.morph.scale.set(0.5, 0.5, 0.5);

    // setup
    var pos = this.actor.getPosition();
    this.morph.position.x = pos.x;
    this.morph.position.y = pos.y;
    this.morph.position.z = pos.z;
    
    var rot = this.actor.getRotation();
    this.morph.quaternion.x = rot.x;
    this.morph.quaternion.y = rot.y;
    this.morph.quaternion.z = rot.z;
    this.morph.quaternion.w = rot.w;    
    
    //this.morph.castShadow = true;
    this.scene.add(this.morph);
    
    console.log('add morph');        
};

teien.ThreejsUi.JsonViewActor.prototype.setup = function(scene){
    // move into loadHandler because of loading delay.
};

teien.ThreejsUi.JsonViewActor.prototype.update = function(delta){
    //console.log(this.actor.name + " update()\n");
    if (this.morph) {
        var pos = this.actor.getPosition();
        
        this.morph.position.x = pos.x;
        this.morph.position.y = pos.y;
        this.morph.position.z = pos.z;
        
        var rot = this.actor.getRotation();
        this.morph.quaternion.x = rot.x;
        this.morph.quaternion.y = rot.y;
        this.morph.quaternion.z = rot.z;
        this.morph.quaternion.w = rot.w;
        
        //THREE.AnimationHandler.update( delta );
        this.morph.updateAnimation(delta);
    }
};
