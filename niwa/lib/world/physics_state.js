(function (exports) {
    exports.PhysicsState = PhysicsState;
    
    function PhysicsState(physics) {
	    this.physics = physics;
	    this.rigidBody = null;
	    
	    this.transform = new Ammo.btTransform();
	    this.transform.setIdentity();
	    this.acceleration = new exports.Vector3D(0, 0, 0);
	    
	    this.maxHorizontalVelocity = 0;
	    this.maxVerticalVelocity = 0;
    };
    
    PhysicsState.prototype.setPosition = function(vec) {
	    this.transform.setOrigin(new Ammo.btVector3(vec.x, vec.y, vec.z));
	    if (this.rigidBody){
	        this.rigidBody.setCenterOfMassTransform(this.transform);
        }
    };
    
    PhysicsState.prototype.setInterpolatePosition = function(vec) {
	    var oldVec = this.getPosition();
	    var ipVec = new Ammo.btVector3((vec.x + oldVec.x()) / 2, 
					                   (vec.y + oldVec.y()) / 2, 
					                   (vec.z + oldVec.z()) / 2);
	    //console.log("(" + ipVec.x() + ", " + ipVec.y() + ", " + ipVec.z() +")");
        
	    this.transform.setOrigin(ipVec);
	    if (this.rigidBody !== null)
	        this.rigidBody.setCenterOfMassTransform(this.transform);
    };
    
    PhysicsState.prototype.setLinearVelocity = function(vec) {
	    this.rigidBody.setLinearVelocity(new Ammo.btVector3(vec.x, vec.y, vec.z));
    };
    
    PhysicsState.prototype.setRotation = function(quat) {
	    this.transform.setRotation(new Ammo.btQuaternion(quat.x, quat.y, quat.z, quat.w));
	    if (this.rigidBody !== null)
	        this.rigidBody.setCenterOfMassTransform(this.transform);
    };
    
    
    PhysicsState.prototype.updateTransform = function() {
	    this.transform = this.rigidBody.getCenterOfMassTransform();
    };
    
    PhysicsState.prototype.getTransform = function() {
	    return this.transform;
    };
    
    PhysicsState.prototype.getPosition = function() {
	    return this.transform.getOrigin();
    };
    
    PhysicsState.prototype.getLinearVelocity = function() {
	    return this.rigidBody.getLinearVelocity();
    };
    
    PhysicsState.prototype.getRotation = function() {
	    return this.transform.getRotation();
    };
    
    PhysicsState.prototype.applyImpulse= function(imp, rel) {
	    this.rigidBody.activate(true);
	    this.rigidBody.applyImpulse(new Ammo.btVector3(imp.x, imp.y, imp.z),
				                    new Ammo.btVector3(rel.x, rel.y, rel.z));
    };
})(typeof exports === 'undefined' ? niwa : exports);

