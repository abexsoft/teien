(function (exports) {
    exports.SkyBoxActor = SkyBoxActor;
    
    // The instance of this class is sent throght network. 
    function SkyBoxActor(actorInfo, actorManager) {
	    exports.Actor.call(this, actorInfo, actorManager);
        
	    var cShape = new Ammo.btSphereShape(1);
	    var inertia = new Ammo.btVector3();
	    cShape.calculateLocalInertia(0, inertia);
        
	    this.physicsState = new exports.PhysicsState(actorManager.physics);
	    this.physicsState.rigidBody = new Ammo.btRigidBody(0, this, cShape, inertia);
    };
    
    SkyBoxActor.prototype = Object.create(exports.Actor.prototype);
    SkyBoxActor.prototype.constructor = exports.Actor;
    
    exports.ActorManager.setCreator(
	    exports.SkyBoxActorInfo.prototype.type, 
	    function(actorInfo, actorManager){
	        return new exports.SkyBoxActor(actorInfo, actorManager);
	    }
    );
})(typeof exports === 'undefined' ? niwa : exports);

