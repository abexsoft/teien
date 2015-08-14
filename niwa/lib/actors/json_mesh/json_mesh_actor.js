(function (exports) {
    exports.JsonMeshActor = JsonMeshActor;
    
    function JsonMeshActor(actorInfo, actorManager) {
	    exports.Actor.call(this, actorInfo, actorManager);
	    
	    var cShape = new Ammo.btBoxShape(new Ammo.btVector3(actorInfo.width / 2,
							                                actorInfo.height / 2,
							                                actorInfo.depth / 2));
	    var inertia = new Ammo.btVector3();
	    cShape.calculateLocalInertia(actorInfo.mass, inertia);
	    
	    var rb = actorManager.physics.createRigidBody(this, actorInfo, cShape, inertia);
	    actorManager.physics.addRigidBody(rb, actorInfo);
	    
	    this.physicsState = new exports.PhysicsState(actorManager.physics);
	    this.physicsState.rigidBody = rb;
    };
    
    JsonMeshActor.prototype = Object.create(exports.Actor.prototype);
    JsonMeshActor.prototype.constructor = exports.Actor;
    
    exports.ActorManager.setCreator(
	    exports.JsonMeshActorInfo.prototype.type, 
	    function(actorInfo, actorManager){
	        return new exports.JsonMeshActor(actorInfo, actorManager);
	    }
    );
    
})(typeof exports === 'undefined' ? niwa : exports);
