
if (typeof exports === 'undefined'){
    var niwa = {};
}

/*
if (typeof importScripts !== 'undefined'){
    function Console() {
	this.log = function(str) {
	    postMessage({type: "log", log: str});
	};
    }
    console = new Console();
}
*/



niwa.Browser = function(app_klass) {
    var that = this;
    
    this.userInterface = new niwa.UserInterface(app_klass);
    this.worldWorker = new Worker("/niwa/niwa_proxy.js");    
    
    this.fpsCnt = 0;
    this.deltaSum = 0;
    this.deltaMax = 0;
    this.deltaMin = 1000;
    
    // requestAnimationFrame handler function.
    this.update = function() {
	    requestAnimationFrame(that.update);
        
	    var now = Date.now();
	    var delta = now - that.lastTime;
	    that.lastTime = now;
        
	    that.userInterface.render(delta);
        
	    that.showFps(delta);
    };
    
    this.worldWorker.onmessage = function(event) {
	    switch(event.data.type) {
	    case "log":  
	        console.log(event.data.log);
	        break;
	    case "update":
	        that.userInterface.update(event.data.actors);
	        break;
	    case "shadow":
	        that.userInterface.render.shadowMapEnabled = event.data.flag;
	        break;
	    default:
	        that.userInterface.onMessage(event);
	    };
    };
};

niwa.Browser.prototype.run = function() {
    
    this.worldWorker.postMessage({type: "setup"});
    this.userInterface.setup(this.worldWorker);
    
    this.lastTime = Date.now();
    requestAnimationFrame(this.update)
};

niwa.Browser.prototype.showFps = function(delta) {
    
    this.fpsCnt += 1;
    this.deltaSum += delta;
    
    if (delta > this.deltaMax) this.deltaMax = delta;
    if (delta < this.deltaMin) this.deltaMin = delta;
    
    if (this.fpsCnt > 60) {
	    console.log("Min: " + this.deltaMin + 
		            ", Avg: " + this.deltaSum / this.fpsCnt +
		            ", Max: " + this.deltaMax);
        
	    this.fpsCnt = 0;
	    this.deltaSum = 0;
	    this.deltaMax = 0;
	    this.deltaMin = 1000;
    }
};




/**
 * These classes are used for follows.
 * 1. ammo.js-to-three.js communication.
 * 2. browser-to-worker and worker-to-node communications.
 */

(function (exports) {
    
    //
    // Vector3D
    //
    exports.Vector3D = Vector3D;
    
    function Vector3D(x, y, z) {
	    this.x = x || 0;
	    this.y = y || 0;
	    this.z = z || 0;
    };
    
    Vector3D.createFromAmmo = function(vec) {
	    return (new exports.Vector3D()).setFromAmmo(vec);
    };
    
    Vector3D.prototype.setFromAmmo = function(vec) {
	    this.x = vec.x();
	    this.y = vec.y();
	    this.z = vec.z();  
	    return this;
    };
    
    
    //
    // Quaternion
    //
    exports.Quaternion = Quaternion;
    
    function Quaternion(x, y, z, w) {
	    this.x = x || 0;
	    this.y = y || 0;
	    this.z = z || 0;
	    this.w = ( w !== undefined ) ? w : 1;
    };
    
    Quaternion.createFromAmmo = function(quat) {
	    return (new exports.Quaternion()).setFromAmmo(quat);
    };
    
    Quaternion.prototype.setFromAmmo = function(quat) {
	    this.x = quat.x();
	    this.y = quat.y();
	    this.z = quat.z();  
	    this.w = quat.w();  
	    return this;
    };
    
    
    //
    // Transform
    //
    exports.Transform = Transform;
    
    function Transform(position, rotation) {
	    this.position = position || new exports.Vector3D();
	    this.rotation = rotation || new exports.Quaternion();
    };
})(typeof exports === 'undefined' ? niwa : exports); 




niwa.UserInterface = function(applicationUi) {
    var that = this;
    this.application = new applicationUi(this);
    
    this.renderer = new THREE.WebGLRenderer();
    this.renderer.setSize( window.innerWidth, window.innerHeight );
    document.body.appendChild( this.renderer.domElement );
    
    this.camera = new THREE.PerspectiveCamera(60, 
					                          window.innerWidth / window.innerHeight, 
					                          1, 1000 );
    this.camera.position.z = 20;
    this.camera.lookAt(new THREE.Vector3( 0, 0, 0 ));
    
    this.scene = new THREE.Scene();
    
    this.actors = {};
    this.actorNum = 0;
    
    this.onWindowResize = function() {
	    that.camera.aspect = window.innerWidth / window.innerHeight;
	    that.camera.updateProjectionMatrix();
        
	    that.renderer.setSize( window.innerWidth, window.innerHeight );
    };
    window.addEventListener( 'resize', this.onWindowResize, false );
};

niwa.UserInterface.creators = {};

niwa.UserInterface.setCreator = function(type, creator) {
    this.creators[type] = creator;
};

///
// prototypes

niwa.UserInterface.prototype.createActorView = function(name, actorInfo, transform) {
    if (this.actors[name] !== undefined) {
	    console.log("UserInterface: There is a actor with the same name: " + name);
	    return this.actors[name];
    }
    else {
	    if (niwa.UserInterface.creators[actorInfo.type] !== undefined) {
	        var actor = niwa.UserInterface.creators[actorInfo.type](name, actorInfo, this);	
            
	        actor.setTransform(transform);
	        actor.userInterface = this;
	        this.actors[actor.name] = actor;
	        actor.id = this.actorNum;
	        this.actorNum += 1;
            
	        return actor;
	    }
	    else {
	        console.log("no such class: " + actorInfo.type);
	        return null;
	    }
    }
};

niwa.UserInterface.prototype.setup = function(model) {
    this.model = model;
    this.application.setup(model, this);
};

niwa.UserInterface.prototype.update = function(models) {
    for (key in models) {
	    var model = models[key];
	    if (this.actors[key] === undefined) {
	        this.actors[key] = this.createActorView(key, model.actorInfo, model.transform);
	    }
	    else {
	        this.actors[key].setTransform(model.transform);
	    }
    }
};

niwa.UserInterface.prototype.render = function(delta) {
    for (key in this.actors) {
	    if (this.actors[key].updateAnimation !== undefined)
	        this.actors[key].updateAnimation(delta);
    }
    
    this.application.update(delta);
    
    this.renderer.render(this.scene, this.camera);
};

niwa.UserInterface.prototype.onMessage = function(event) {
    this.application.onMessage(event);
};


niwa.ActorView = function(userInterface) {
    this.userInterface = userInterface;
    this.objectInfo = null;
    this.mesh = null;
};

niwa.ActorView.prototype.setTransform = function(transform) {
    
    this.object.position.x = transform.position.x;
    this.object.position.y = transform.position.y;
    this.object.position.z = transform.position.z;
    
    this.object.quaternion.x = transform.rotation.x;
    this.object.quaternion.y = transform.rotation.y;
    this.object.quaternion.z = transform.rotation.z;
    this.object.quaternion.w = transform.rotation.w;
};


/**
 */

niwa.FpvOrbitControls = function( object, domElement ) {

    this.object = object;
    this.target = new THREE.Vector3( 0, 0, 0 );
    
    this.domElement = ( domElement !== undefined ) ? domElement : document;

    this.body = this.domElement.body;
    
    this.movementSpeed = 1.0;
    this.lookSpeed = 0.005;
    
    this.lookVertical = true;
    this.autoForward = false;
    
    this.activeLook = true;
    
    this.heightSpeed = false;
    this.heightCoef = 1.0;
    this.heightMin = 0.0;
    this.heightMax = 1.0;
    
    this.constrainVertical = false;
    this.verticalMin = 0;
    this.verticalMax = Math.PI;
    
    this.autoSpeedFactor = 0.0;
    
    this.mouseX = 0;
    this.mouseY = 0;
    
    this.lat = 0;
    this.lon = 0;
    this.phi = 0;
    this.theta = 0;
    
    this.moveForward = false;
    this.moveBackward = false;
    this.moveLeft = false;
    this.moveRight = false;
    this.freeze = false;
    
    this.mouseDragOn = false;
    
    this.viewHalfX = 0;
    this.viewHalfY = 0;
    
    if ( this.domElement !== document ) {
	    this.domElement.setAttribute( 'tabindex', -1 );
    }
    
    //
    
    this.handleResize = function () {
	    if ( this.domElement === document ) {
	        this.viewHalfX = window.innerWidth / 2;
	        this.viewHalfY = window.innerHeight / 2;
	    } else {
	        this.viewHalfX = this.domElement.offsetWidth / 2;
	        this.viewHalfY = this.domElement.offsetHeight / 2;
	    }
    };
    
    this.onMouseDown = function ( event ) {
	    if ( this.domElement !== document ) {
	        this.domElement.focus();
	    }
	    
	    event.preventDefault();
	    event.stopPropagation();
	    
	    if ( this.activeLook ) {
	        
	        switch ( event.button ) {
		        
	        case 0: this.moveForward = true; break;
	        case 2: this.moveBackward = true; break;
		        
	        }
	        
	    }
	    
	    this.mouseDragOn = true;
	    
    };
    
    this.onMouseUp = function ( event ) {
	    
	    event.preventDefault();
	    event.stopPropagation();
	    
	    if ( this.activeLook ) {
	        
	        switch ( event.button ) {
		        
	        case 0: this.moveForward = false; break;
	        case 2: this.moveBackward = false; break;
		        
	        }
	        
	    }
	    
	    this.mouseDragOn = false;
	    
    };
    
    this.onMouseMove = function ( event ) {
	    
	    if ( this.domElement === document ) {
	        //var e = event.originalEvent;
	        var e = event;
	        this.mouseX = (e.movementX || e.mozMovementX || e.webkitMovementX);
	        this.mouseY = (e.movementY || e.mozMovementY || e.webkitMovementY);
            
	        //this.mouseX = event.clientX - this.viewHalfX;
	        //this.mouseY = event.clientY - this.viewHalfY;
	        console.log("(" + this.mouseX + ", " + this.mouseY +")");
	        
	    } else {
	        
	        this.mouseX = event.pageX - this.domElement.offsetLeft - this.viewHalfX;
	        this.mouseY = event.pageY - this.domElement.offsetTop - this.viewHalfY;
	        
	    }
	    
    };
    
    this.onKeyDown = function ( event ) {
	    
	    //event.preventDefault();
	    
	    switch ( event.keyCode ) {
	        
	    case 38: /*up*/
	    case 87: /*W*/ this.moveForward = true; break;
	        
	    case 37: /*left*/
	    case 65: /*A*/ this.moveLeft = true; break;
	        
	    case 40: /*down*/
	    case 83: /*S*/ this.moveBackward = true; break;
	        
	    case 39: /*right*/
	    case 68: /*D*/ this.moveRight = true; break;
	        
	    case 82: /*R*/ this.moveUp = true; break;
	    case 70: /*F*/ this.moveDown = true; break;
	        
	    case 81: /*Q*/ this.freeze = !this.freeze; break;
            
	    case 76:
	        console.log("lock");
	        this.body.requestPointerLock = 
		        this.body.requestPointerLock || 
		        this.body.mozRequestPointerLock || 
		        this.body.webkitRequestPointerLock;
	        this.body.requestPointerLock();
	        break;
	    }
	    
    };
    
    this.onKeyUp = function ( event ) {
	    console.log("controls onKeyDown");
	    
	    switch( event.keyCode ) {
	        
	    case 38: /*up*/
	    case 87: /*W*/ this.moveForward = false; break;
	        
	    case 37: /*left*/
	    case 65: /*A*/ this.moveLeft = false; break;
	        
	    case 40: /*down*/
	    case 83: /*S*/ this.moveBackward = false; break;
	        
	    case 39: /*right*/
	    case 68: /*D*/ this.moveRight = false; break;
	        
	    case 82: /*R*/ this.moveUp = false; break;
	    case 70: /*F*/ this.moveDown = false; break;
	        
	    }
	    
    };
    
    this.update = function( delta ) {
	
	    if ( this.freeze ) {
	        
	        return;
	        
	    }
	    
	    if ( this.heightSpeed ) {
	        
	        var y = THREE.Math.clamp( this.object.position.y, this.heightMin, this.heightMax );
	        var heightDelta = y - this.heightMin;
	        
	        this.autoSpeedFactor = delta * ( heightDelta * this.heightCoef );
	        
	    } else {
	        
	        this.autoSpeedFactor = 0.0;
	        
	    }
	    
	    var actualMoveSpeed = delta * this.movementSpeed;
	    
	    if ( this.moveForward || ( this.autoForward && !this.moveBackward ) ) this.object.translateZ( - ( actualMoveSpeed + this.autoSpeedFactor ) );
	    if ( this.moveBackward ) this.object.translateZ( actualMoveSpeed );
	    
	    if ( this.moveLeft ) this.object.translateX( - actualMoveSpeed );
	    if ( this.moveRight ) this.object.translateX( actualMoveSpeed );
	    
	    if ( this.moveUp ) this.object.translateY( actualMoveSpeed );
	    if ( this.moveDown ) this.object.translateY( - actualMoveSpeed );
	    
	    var actualLookSpeed = delta * this.lookSpeed;
	    
	    if ( !this.activeLook ) {
	        
	        actualLookSpeed = 0;
	        
	    }
	    
	    var verticalLookRatio = 1;
	    
	    if ( this.constrainVertical ) {
	        
	        verticalLookRatio = Math.PI / ( this.verticalMax - this.verticalMin );
	        
	    }
	    
	    this.lon += this.mouseX * actualLookSpeed;
	    if( this.lookVertical ) this.lat -= this.mouseY * actualLookSpeed * verticalLookRatio;
	    
	    this.lat = Math.max( - 85, Math.min( 85, this.lat ) );
	    this.phi = THREE.Math.degToRad( 90 - this.lat );
	    
	    this.theta = THREE.Math.degToRad( this.lon );
	    
	    if ( this.constrainVertical ) {
	        
	        this.phi = THREE.Math.mapLinear( this.phi, 0, Math.PI, this.verticalMin, this.verticalMax );
	        
	    }
	    
	    var targetPosition = this.target,
	        position = this.object.position;
	    
	    targetPosition.x = position.x + 100 * Math.sin( this.phi ) * Math.cos( this.theta );
	    targetPosition.y = position.y + 100 * Math.cos( this.phi );
	    targetPosition.z = position.z + 100 * Math.sin( this.phi ) * Math.sin( this.theta );
	    
	    this.object.lookAt( targetPosition );
        
	    this.mouseX = 0;
	    this.mouseY = 0;
    };
    
    
    this.domElement.addEventListener( 'contextmenu', function ( event ) { event.preventDefault(); }, false );
    
    this.domElement.addEventListener( 'mousemove', bind( this, this.onMouseMove ), false );
    this.domElement.addEventListener( 'mousedown', bind( this, this.onMouseDown ), false );
    this.domElement.addEventListener( 'mouseup', bind( this, this.onMouseUp ), false );
    this.domElement.addEventListener( 'keydown', bind( this, this.onKeyDown ), false );
    this.domElement.addEventListener( 'keyup', bind( this, this.onKeyUp ), false );
    
    function bind( scope, fn ) {
        return function () {
	        fn.apply( scope, arguments );
	    };
    };
    
    this.handleResize();
};


(function (exports) {
    exports.BoxActorInfo = BoxActorInfo;
    
    // The instance of this class is sent throght network. 
    function BoxActorInfo(width, height, depth) {
	    this.width = width;
	    this.height = height;
	    this.depth = depth;
	    
	    // for physics
	    this.usePhysics = true;
	    this.mass = 0;
	    this.angularFactor = new exports.Vector3D(1.0, 1.0, 1.0);
	    this.restitution = 0.2;
	    this.friction = 1.0;
	    this.linearDamping = 0.0;
	    this.angularDamping = 0.0;
	    this.collisionFilter = null;
	    
	    // for visual
	    this.textureName = null;
	    
	    this.type = BoxActorInfo.prototype.type;
    };
    BoxActorInfo.prototype.type = "box";
})(typeof exports === 'undefined' ? niwa : exports);


niwa.BoxActorView = function(name, actorInfo, userInterface) {
    niwa.ActorView.call(this, userInterface);    
    
    this.name = name;
    this.actorInfo = actorInfo;
    
    var texture = THREE.ImageUtils.loadTexture(actorInfo.textureName);
    texture.anisotropy = userInterface.renderer.getMaxAnisotropy();
    
    if (actorInfo.castShadow || actorInfo.receiveShadow)
	    var material = new THREE.MeshLambertMaterial({ map: texture });
    else
	    var material = new THREE.MeshBasicMaterial( { map: texture } );
    
    var geometry = new THREE.BoxGeometry(actorInfo.width, actorInfo.height, actorInfo.depth);
    this.object = new THREE.Mesh( geometry, material );
    //this.object.useQuaternion = true;
    
    this.object.castShadow = actorInfo.castShadow;
    this.object.receiveShadow = actorInfo.receiveShadow;
    
    userInterface.scene.add(this.object);
};

niwa.BoxActorView.prototype = Object.create(niwa.ActorView.prototype);
niwa.BoxActorView.prototype.constructor = niwa.ActorView;

niwa.UserInterface.setCreator(
    niwa.BoxActorInfo.prototype.type, 
    function(name, actorInfo, userInterface) {
	    return new niwa.BoxActorView(name, actorInfo, userInterface);
    }
);


(function (exports) {
    exports.SphereActorInfo = SphereActorInfo;
    
    // The instance of this class is sent throght network. 
    function SphereActorInfo(radius) {
	    this.radius = radius;
        
	    // for physics
	    this.usePhysics = true;
	    this.mass = 0;
	    this.angularFactor = new exports.Vector3D(1.0, 1.0, 1.0);
	    this.restitution = 0.2;
	    this.friction = 1.0;
	    this.linearDamping = 0.0;
	    this.angularDamping = 0.0;
	    this.collisionFilter = null;
	    
	    // for visual
	    this.textureName = null;
	    
	    this.type = exports.SphereActorInfo.prototype.type;
    };
    SphereActorInfo.prototype.type = "sphere";
})(typeof exports === 'undefined' ? niwa : exports);


niwa.SphereActorView = function(name, actorInfo, userInterface) {
    niwa.ActorView.call(this, userInterface);
    
    this.name = name;
    this.actorInfo = actorInfo;
    
    var texture = THREE.ImageUtils.loadTexture(actorInfo.textureName);
    texture.anisotropy = userInterface.renderer.getMaxAnisotropy();
    
    if (actorInfo.castShadow || actorInfo.receiveShadow)
	    var material = new THREE.MeshLambertMaterial({ map: texture });
    else
	    var material = new THREE.MeshBasicMaterial( { map: texture } );
    
    var geometry = new THREE.SphereGeometry(actorInfo.radius);
    this.object = new THREE.Mesh( geometry, material );
    //this.object.useQuaternion = true;
    
    this.object.castShadow = actorInfo.castShadow;
    this.object.receiveShadow = actorInfo.receiveShadow;
    
    userInterface.scene.add(this.object);
};

niwa.SphereActorView.prototype = Object.create(niwa.ActorView.prototype);
niwa.SphereActorView.prototype.constructor = niwa.ActorView;

niwa.UserInterface.setCreator(
    niwa.SphereActorInfo.prototype.type, 
    function(name, actorInfo, userInterface) {
	    return new niwa.SphereActorView(name, actorInfo, userInterface);
    }
);


(function (exports) {
    exports.SpotLightActorInfo = SpotLightActorInfo;
    
    // The instance of this class is sent throght network. 
    function SpotLightActorInfo(color) {
	    this.color = color;
	    this.usePhysics = false;
	    this.type = exports.SpotLightActorInfo.prototype.type;
    };
    SpotLightActorInfo.prototype.type = "spotlight";
})(typeof exports === 'undefined' ? niwa : exports); 


niwa.SpotLightActorView = function(name, objectInfo, userInterface) {
    niwa.ActorView.call(this, userInterface);            
    this.name = name;
    this.objectInfo = objectInfo;
    
    this.object = new THREE.SpotLight(this.objectInfo.color);
    this.object.castShadow = this.objectInfo.castShadow;
    
    this.object.shadowMapWidth = 1024;
    this.object.shadowMapHeight = 1024;
    
    this.object.shadowCameraNear = 10;
    this.object.shadowCameraFar = 500;
    this.object.shadowCameraFov = 30;
    
    this.object.shadowDarkness = 0.8;
    
    this.object.shadowCameraVisible = this.objectInfo.shadowCameraVisible || false;
    
    userInterface.scene.add(this.object);
};

niwa.SpotLightActorView.prototype = Object.create(niwa.ActorView.prototype);
niwa.SpotLightActorView.prototype.constructor = niwa.ActorView;

niwa.UserInterface.setCreator(
    niwa.SpotLightActorInfo.prototype.type, 
    function(name, actorInfo, userInterface) {
	    return new niwa.SpotLightActorView(name, actorInfo, userInterface);
    }
);







(function (exports) {
    exports.SkyBoxActorInfo = SkyBoxActorInfo;
    
    // The instance of this class is sent throght network. 
    function SkyBoxActorInfo(materials) {
	    this.materials = materials;
	    this.usePhysics = false;
	    this.type = SkyBoxActorInfo.prototype.type;
    };
    SkyBoxActorInfo.prototype.type = "skybox";
})(typeof exports === 'undefined' ? niwa : exports); 


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







(function (exports) {
    exports.JsonMeshActorInfo = JsonMeshActorInfo;
    
    // The instance of this class is sent throght network. 
    function JsonMeshActorInfo(model) {
	    this.model = model;
	    this.width = 1;
	    this.height = 1;
	    this.depth = 1;
	    
	    // for physics
	    this.usePhysics = true;
	    this.mass = 0;
	    this.angularFactor = new exports.Vector3D(1.0, 1.0, 1.0);
	    this.restitution = 0.2;
	    this.friction = 1.0;
	    this.linearDamping = 0.0;
	    this.angularDamping = 0.0;
	    this.collisionFilter = null;
	    
	    // for visual
	    this.textureName = null;
	    
	    this.type = exports.JsonMeshActorInfo.prototype.type;
    };
    JsonMeshActorInfo.prototype.type = "json";
    
})(typeof exports === 'undefined' ? niwa : exports);    


niwa.JsonMeshActorView = function(name, actorInfo, userInterface) {
    niwa.ActorView.call(this, userInterface);        

    var that = this;
    this.name = name;
    this.actorInfo = actorInfo;
    this.userInterface = userInterface;
    this.object = new THREE.Object3D();
    //this.object.useQuaternion = true;
    userInterface.scene.add(this.object);

    var loader = new THREE.JSONLoader();
    loader.load(actorInfo.model, 
		function ( geometry, materials ) {
		    var material = materials[ 0 ];
            material.morphTargets = true;
            material.color.setHex( 0xffaaaa );
            //material.ambient.setHex( 0x222222 );
		    //console.log(material);

                    var faceMaterial = new THREE.MeshFaceMaterial( materials );
		    that.mesh = new THREE.MorphAnimMesh( geometry, faceMaterial );
		    
		    // one second duration
            that.mesh.duration = 1000;
		    
            // random animation offset
            that.mesh.time = 1000 * Math.random();
		    
            var s = THREE.Math.randFloat( 0.00075, 0.001 );
            that.mesh.scale.set( s, s, s );

		    //that.mesh.useQuaternion = true;
		    that.mesh.castShadow = actorInfo.castShadow;
		    that.mesh.receiveShadow = actorInfo.receiveShadow;

		    that.mesh.position.set(actorInfo.viewPositionOffset.x, 
					   actorInfo.viewPositionOffset.y,
					   actorInfo.viewPositionOffset.z);

		    that.object.add(that.mesh)

//		    
		}
	       );
};

niwa.JsonMeshActorView.prototype = Object.create(niwa.ActorView.prototype);
niwa.JsonMeshActorView.prototype.constructor = niwa.ActorView;

niwa.JsonMeshActorView.prototype.setTransform = function(transform) {

    // takes a little longer to load a mesh.
    if (this.object === undefined)
	return;

    niwa.ActorView.prototype.setTransform.call(this, transform);
};

niwa.JsonMeshActorView.prototype.updateAnimation = function(delta) {
    if (this.mesh)
	this.mesh.updateAnimation(delta);
};


niwa.UserInterface.setCreator(
    niwa.JsonMeshActorInfo.prototype.type, 
    function(name, actorInfo, userInterface) {
	return new niwa.JsonMeshActorView(name, actorInfo, userInterface);
    }
);


