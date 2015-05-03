teien.Actor = function(param) {
    this.param = param;
    
	this.name = param.name;
    this.state = param.state;
    this.ext_info = param.ext_info;

    this.transform = new Ammo.btTransform();
    this.transform.setIdentity();
    
    this.rigidBody = null;
    
    this.observers = [];
};

teien.Actor.prototype.setup = function(physics) {
    this.fromHash(this.param);
/*
    var pos = new teien.Vector3D(this.param.transform.position.x,
                                 this.param.transform.position.y,
                                 this.param.transform.position.z);
    this.setPosition(pos);
    var rot = new teien.Quaternion(this.param.transform.rotation.x,
                                   this.param.transform.rotation.y,
                                   this.param.transform.rotation.z,
                                   this.param.transform.rotation.w);
    this.setRotation(rot);

    this.setLinearVelocity(new teien.Vector3D(this.param.linear_vel.x,
                                              this.param.linear_vel.y,
                                              this.param.linear_vel.z));
    
    this.setAngularVelocity(new teien.Vector3D(this.param.angular_vel.x,
                                               this.param.angular_vel.y,
                                               this.param.angular_vel.z));
*/
};

// vec: teien.Vector3D
teien.Actor.prototype.setPosition = function(vec) {
    this.transform.setOrigin(new Ammo.btVector3(vec.x, vec.y, vec.z));
    if (this.rigidBody) {
        this.rigidBody.setCenterOfMassTransform(this.transform);
    }
};

// quat: teien.Quaternion
teien.Actor.prototype.setRotation = function(quat) {
    this.transform.setRotation(new Ammo.btQuaternion(quat.x, quat.y, quat.z, quat.w));
    if (this.rigidBody) {    
        this.rigidBody.setCenterOfMassTransform(this.transform);
    }
};

teien.Actor.prototype.setLinearVelocity = function(vec) {
    if (this.rigidBody)
        this.rigidBody.setLinearVelocity(new Ammo.btVector3(vec.x, vec.y, vec.z));
};

teien.Actor.prototype.setAngularVelocity = function(vec) {
    if (this.rigidBody)
        this.rigidBody.setAngularVelocity(new Ammo.btVector3(vec.x, vec.y, vec.z));
};

teien.Actor.prototype.getPosition = function() {
    var pos = this.transform.getOrigin();
	return teien.Vector3D.createFromAmmo(pos);
};

teien.Actor.prototype.getRotation = function() {
	return teien.Quaternion.createFromAmmo(this.transform.getRotation())
};

teien.Actor.prototype.getLinearVelocity = function() {
    return this.rigidBody.getLinearVelocity();
};

/* These two functions are not supported by Ammo.
teien.Actor.prototype.setWorldTransform = function(worldTrans){
    console.log("setWorldTransform is called.\n");
    this.transform = new Ammo.btTransform(worldTrans);
};

teien.Actor.prototype.getWorldTransform = function(worldTrans){
    console.log("getWorldTransform is called.\n");
};
*/

teien.Actor.prototype.fromHash = function(param){
	this.name = param.name;
    this.state = param.state;
    this.ext_info = param.ext_info;
    
    var pos = new teien.Vector3D(param.transform.position.x,
                                 param.transform.position.y,
                                 param.transform.position.z);
    this.setPosition(pos);
    var rot = new teien.Quaternion(param.transform.rotation.x,
                                   param.transform.rotation.y,
                                   param.transform.rotation.z,
                                   param.transform.rotation.w);
    this.setRotation(rot);

    this.setLinearVelocity(new teien.Vector3D(param.linear_vel.x,
                                              param.linear_vel.y,
                                              param.linear_vel.z));
    
    this.setAngularVelocity(new teien.Vector3D(param.angular_vel.x,
                                               param.angular_vel.y,
                                               param.angular_vel.z));
    pos = this.getPosition();
};

/*
teien.Actor.prototype.applyImpulse = function(imp, rel) {
	if (rel === undefined)
	    rel = new exports.Vector3D(0, 0, 0);
    
	this.physicsState.applyImpulse(imp, rel);
};
*/

teien.Actor.prototype.updateTransform = function() {
    if (this.rigidBody){
        this.transform = this.rigidBody.getCenterOfMassTransform();
        // This function don't return the right value of @mass == 0.
        //this.rigidBody.getMotionState().getWorldTransform(this.transform); 
        //console.log(this.transform.getOrigin().y() + "\n");
        this.notify();
    }
};

// Objserver
teien.Actor.prototype.attach = function(observer){
    for(i=0; i < this.observers.length; i++){
        if(this.observers[i] == observer)
            return;
    }
    this.observers.push(observer);
};

teien.Actor.prototype.detach = function(observer){
    for(i=0; i < this.observers.length; i++){
        if(this.observers[i] == observer){
            this.observers.splice(i--, 1);
        }
    }    
};

teien.Actor.prototype.notify = function(){
    for(i=0; i < this.observers.length; i++){
        this.observers[i].update();
    }
}
