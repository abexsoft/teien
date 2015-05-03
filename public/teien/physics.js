teien.Physics = function(world) {
	this.world = world;

	this.rigidBodies = [];
	this.maxSubSteps = 10;
	this.fixedTimeStep = 1.0 / 60.0;
};

teien.Physics.prototype.setup = function() {
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

/*
teien.Physics.prototype.createRigidBody = function(motionState, actorInfo, cShape, inertia) {
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
*/
teien.Physics.prototype.addRigidBody = function(rigidBody) {
	this.dynamicsWorld.addRigidBody(rigidBody);
	this.rigidBodies.push(rigidBody);
    console.log("addRigidBody is called.\n");
};    

/*
teien.Physics.prototype.addRigidBody = function(rigidBody, actorInfo) {
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
*/

teien.Physics.prototype.delRigidBody = function(rigidBody) {
	this.rigidBodies.delete(rigidBody);
	this.dynamicsWorld.removeRigidBody(rigidBody);
};

teien.Physics.prototype.update = function(delta) {
    this.dynamicsWorld.stepSimulation(delta, this.maxSubSteps, this.fixedTimeStep);    
//    this.dynamicsWorld.stepSimulation(delta / 1000, this.maxSubSteps, this.fixedTimeStep);
    //console.log("Physics::update is called.\n");

};
     
