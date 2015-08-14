(function (exports) {
    exports.Physics = Physics;
    
    function Physics(objectManager) {
	    this.objectManager = objectManager;
        
	    this.rigidBodies = [];
	    this.maxSubSteps = 1;
	    this.fixedTimeStep = 1.0 / 60.0;
	    
	    var collisionConfig = new Ammo.btDefaultCollisionConfiguration();
	    var collisionDispatcher = new Ammo.btCollisionDispatcher(collisionConfig);
	    
	    var worldAabbMin = new Ammo.btVector3(-3000.0,-500.0, -3000.0);
	    var worldAabbMax = new Ammo.btVector3(3000.0, 500.0, 3000.0);
	    var maxProxies = 1024 * 4;
	    var aabbCache = new Ammo.btAxisSweep3(worldAabbMin, worldAabbMax, maxProxies);
	    
	    var solver = new Ammo.btSequentialImpulseConstraintSolver();
	    
	    this.dynamicsWorld = new Ammo.btDiscreteDynamicsWorld(collisionDispatcher, 
							                                  aabbCache,
                                                              solver, 
							                                  collisionConfig);
	    
	    var gravity = new Ammo.btVector3(0.0, -9.8, 0.0);
	    this.dynamicsWorld.setGravity(gravity);
    };
    
    Physics.prototype.createRigidBody = function(motionState, actorInfo, cShape, inertia) {
	    if (actorInfo.physicsPositionOffset === undefined) 
	        var offset = new exports.Vector3D(0, 0, 0);
	    else
	        var offset = actorInfo.physicsPositionOffset;
	    
	    var localTrans = new Ammo.btTransform();
	    localTrans.setIdentity();
	    localTrans.setOrigin(offset);
	    var pivotShape = new Ammo.btCompoundShape();
	    pivotShape.addChildShape(localTrans, cShape);
	    
	    var rigidBody = new Ammo.btRigidBody(actorInfo.mass, motionState, pivotShape, inertia);
	    rigidBody.setAngularFactor(new Ammo.btVector3(actorInfo.angularFactor.x,
						                              actorInfo.angularFactor.y,
						                              actorInfo.angularFactor.z));
	    rigidBody.setRestitution(actorInfo.restitution);
	    rigidBody.setFriction(actorInfo.friction);
	    rigidBody.setDamping(actorInfo.linearDamping, 
                             actorInfo.angularDamping);
	    
	    return rigidBody;
    };
    
    Physics.prototype.addRigidBody = function(rigidBody, actorInfo) {
	    if (actorInfo.usePhysics === false || rigidBody === null)
	        return;
	    
	    if (actorInfo.collisionFilter) {
	        this.dynamicsWorld.addRigidBody(rigidBody, 
					                        actorInfo.collisionFilter.group, 
					                        actorInfo.collisionFilter.mask);
	    }
	    else
	        this.dynamicsWorld.addRigidBody(rigidBody);
	    
	    this.rigidBodies.push(rigidBody);
    };    
    
    Physics.prototype.delRigidBody = function(rigidBody) {
	    this.rigidBodies.delete(rigidBody);
	    this.dynamicsWorld.removeRigidBody(rigidBody);
    };
    
    Physics.prototype.update = function(delta) {
	    //console.log(delta);
	    this.dynamicsWorld.stepSimulation(delta / 1000, this.maxSubSteps, this.fixedTimeStep);
    };
})(typeof exports === 'undefined' ? niwa : exports);

