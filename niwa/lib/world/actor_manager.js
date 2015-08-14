(function (exports) {
    exports.ActorManager = ActorManager;
    
    function ActorManager() {
	    this.physics = new exports.Physics(this);
	    
	    this.defaultShadow = false;
	    this.actorNum = 0;
	    this.actors = {};
    };
    
     ActorManager.creators = {};
    
    ActorManager.setCreator = function(type, creator) {
	    this.creators[type] = creator;
    };
    
    ActorManager.prototype.createActor = function(name, actorInfo) {
	    if (this.actors[name] !== undefined) {
	        console.log("There is a object with the same name: " + name);
	        return this.actors[name];
	    }
	    else {
	        if (exports.ActorManager.creators[actorInfo.type] !== undefined) {
		        
		        if (this.defaultShadow) {
		            if (actorInfo.castShadow === undefined)
			            actorInfo.castShadow = true;
		            if (actorInfo.receiveShadow === undefined)
			            actorInfo.receiveShadow = true;
		        }
		        
		        var actor = exports.ActorManager.creators[actorInfo.type](actorInfo, this);	
		        actor.name = name;
		        this.actors[name] = actor;
		        actor.id = this.actorNum;
		        this.actorNum += 1;
		        
		        return actor;
	        }
	        else {
		        console.log("no such class: #{obj.object_info.class}");
		        return null;
		        
	        }
	    }
    };
    
    ActorManager.prototype.update = function(delta) {
	    this.physics.update(delta);
	    
	    // update each object's transform here,
	    // because set/getWorldTransform callback is not supported by Ammo.
	    for (name in this.actors) {
	        this.actors[name].updateTransform();
	    };
    };
    
    ActorManager.prototype.merge = function(actors) {
	    for (name in actors) {
	        if (this.actors[name] === undefined){
		        this.actors[name] = this.createActor(name, actors[name].actorInfo);
	        }
            
	        var transform = actors[name].transform;
	        this.actors[name].setInterpolatePosition(transform.position);
	        //this.actors[name].setPosition(transform.position);
	        this.actors[name].setRotation(transform.rotation);
            
	        this.actors[name].setLinearVelocity(actors[name].linearVelocity);
	    }
    };
})(typeof exports === 'undefined' ? niwa : exports);
