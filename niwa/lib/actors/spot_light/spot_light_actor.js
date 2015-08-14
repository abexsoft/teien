(function (exports) {
    exports.SpotLightActor = SpotLightActor;
    
    // The instance of this class is sent throght network. 
    function SpotLightActor(actorInfo, actorManager) {
	    exports.Actor.call(this, actorInfo, actorManager);
        
	    var cShape = new Ammo.btSphereShape(1);
	    var inertia = new Ammo.btVector3();
	    cShape.calculateLocalInertia(0, inertia);
        
	    this.physicsState = new exports.PhysicsState(actorManager.physics);
	    this.physicsState.rigidBody = new Ammo.btRigidBody(0, this, cShape, inertia);
    }
    
    SpotLightActor.prototype = Object.create(exports.Actor.prototype);
    SpotLightActor.prototype.constructor = exports.Actor;
    
    exports.ActorManager.setCreator(
	    exports.SpotLightActorInfo.prototype.type, 
	    function(actorInfo, actorManager){
	        return new SpotLightActor(actorInfo, actorManager);
	    }
    );
})(typeof exports === 'undefined' ? niwa : exports);
