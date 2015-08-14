niwa.SkyBoxActorView = function(name, objectInfo, userInterface) {
    niwa.ActorView.call(this, userInterface);            
    this.name = name;
    this.objectInfo = objectInfo;
    
    var materials = objectInfo.materials;
    var textureCube = THREE.ImageUtils.loadTextureCube(materials, THREE.CubeRefractionMapping);
    var shader = THREE.ShaderLib[ "cube" ];
    shader.uniforms[ "tCube" ].value = textureCube;
    
    var material = new THREE.ShaderMaterial( 
	    {
	        fragmentShader: shader.fragmentShader,
            vertexShader: shader.vertexShader,
            uniforms: shader.uniforms,
            depthWrite: false,
            side: THREE.BackSide
        } );
    
    this.object = new THREE.Mesh( new THREE.BoxGeometry( 300, 300, 300 ), material );
    userInterface.scene.add(this.object);
};

niwa.SkyBoxActorView.prototype = Object.create(niwa.ActorView.prototype);
niwa.SkyBoxActorView.prototype.constructor = niwa.ActorView;

niwa.UserInterface.setCreator(
    niwa.SkyBoxActorInfo.prototype.type, 
    function(name, actorInfo, userInterface) {
	    return new niwa.SkyBoxActorView(name, actorInfo, userInterface);
    }
);





