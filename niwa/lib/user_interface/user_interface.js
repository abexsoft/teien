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
