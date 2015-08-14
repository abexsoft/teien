(function (exports) {
    exports.SphereActor = SphereActor;
    
    function SphereActor(actorInfo, actorManager) {
	    exports.Actor.call(this, actorInfo, actorManager);
	    
	    var cShape = new Ammo.btSphereShape(actorInfo.radius);
	    var inertia = new Ammo.btVector3();
	    cShape.calculateLocalInertia(actorInfo.mass, inertia);
	    
	    var rb = actorManager.physics.createRigidBody(this, actorInfo, cShape, inertia);
	    actorManager.physics.addRigidBody(rb, actorInfo);
	    
	    this.physicsState = new exports.PhysicsState(actorManager.physics);
	    this.physicsState.rigidBody = rb;
    };
    
    SphereActor.prototype = Object.create(exports.Actor.prototype);
    SphereActor.prototype.constructor = exports.Actor;
    
    exports.ActorManager.setCreator(
	    exports.SphereActorInfo.prototype.type, 
	    function(actorInfo, actorManager){
	        return new exports.SphereActor(actorInfo, actorManager);
	    }
    );
})(typeof exports === 'undefined' ? niwa : exports);
