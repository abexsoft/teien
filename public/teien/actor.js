teien.Actor = function(param) {
    this.param = param;
    
	this.name = param.name;
    this.state = param.state;
    this.physics_info = param.physics_info;    
    this.ext_info = param.ext_info;

    this.transform = new Ammo.btTransform();
    this.transform.setIdentity();
    
    this.rigidBody = null;
    
    this.observers = [];
};

teien.Actor.prototype.setup = function(physics) {
    if (this.rigidBody){
        this.rigidBody.setRestitution(this.physics_info.restitution);
        this.rigidBody.setFriction(this.physics_info.friction);
        this.rigidBody.setDamping(this.physics_info.linear_damping,
                                  this.physics_info.angular_damping);
    }
    this.fromHash(this.param);
};

// vec: teien.Vector3D
teien.Actor.prototype.setPosition = function(vec) {
    this.transform.setOrigin(new Ammo.btVector3(vec.x, vec.y, vec.z));
    if (this.rigidBody) {
        this.rigidBody.setCenterOfMassTransform(this.transform);
	    //this.rigidBody.setWorldTransform(this.transform);        
        this.rigidBody.activate();
    }
};

teien.Actor.prototype.setInterpolatePosition = function(vec) {
    var oldVec = this.getPosition();
    var ipVec = new teien.Vector3D((vec.x + oldVec.x) / 2, 
                                   (vec.y + oldVec.y) / 2, 
                                   (vec.z + oldVec.z) / 2);
    //console.log("(" + ipVec.x() + ", " + ipVec.y() + ", " + ipVec.z() +")");

    this.setPosition(ipVec);
};


// quat: teien.Quaternion
teien.Actor.prototype.setRotation = function(quat) {
    this.transform.setRotation(new Ammo.btQuaternion(quat.x, quat.y, quat.z, quat.w));
    if (this.rigidBody) {    
        this.rigidBody.setCenterOfMassTransform(this.transform);
	    //this.rigidBody.setWorldTransform(this.transform);                
        this.rigidBody.activate();
    }
};

teien.Actor.prototype.setLinearVelocity = function(vec) {
    if (this.rigidBody){
        this.rigidBody.setLinearVelocity(new Ammo.btVector3(vec.x, vec.y, vec.z));
        this.rigidBody.activate();
    }
};

teien.Actor.prototype.setAngularVelocity = function(vec) {
    if (this.rigidBody){
        this.rigidBody.setAngularVelocity(new Ammo.btVector3(vec.x, vec.y, vec.z));
        this.rigidBody.activate();
    }
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
    this.physics_info = param.physics_info;
    this.ext_info = param.ext_info;
    
    var pos = new teien.Vector3D(param.transform.position.x,
                                 param.transform.position.y,
                                 param.transform.position.z);
    this.setPosition(pos);
    //this.setInterpolatePosition(pos);    
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

teien.Actor.prototype.toHash = function(){
    var hash = {};
	hash.name = this.name;
    hash.state = this.state;
    hash.physics_info = this.physics_info;
    hash.ext_info = this.ext_info;

    var trans = {};
    var pos = this.transform.getOrigin();
    trans.position = {
        x: pos.x(),
        y: pos.y(),
        z: pos.z()
    };
    var rot = this.transform.getRotation();    
    trans.rotation = {
        x: rot.x(),
        y: rot.y(),
        z: rot.z(),
        w: rot.w()
    };
    hash.transform = trans;

    if (this.rigidBody) {
        var l_v = this.rigidBody.getLinearVelocity();
        hash.linear_vel = {
            x: l_v.x(),
            y: l_v.y(),
            z: l_v.z()
        };
    }

    if (this.rigidBody) {    
        var a_v = this.rigidBody.getAngularVelocity();
        hash.angular_vel = {
            x: a_v.x(),
            y: a_v.y(),
            z: a_v.z()
        };
    }

    return hash;
};


/*
teien.Actor.prototype.applyImpulse = function(imp, rel) {
	if (rel === undefined)
	    rel = new exports.Vector3D(0, 0, 0);
    
	this.physicsState.applyImpulse(imp, rel);
};
*/

teien.Actor.prototype.updateTransform = function(delta) {

    if (this.rigidBody){
        this.transform = this.rigidBody.getCenterOfMassTransform();
        // This function don't return the right value of @mass == 0.
        //this.rigidBody.getMotionState().getWorldTransform(this.transform); 
        //console.log(this.transform.getOrigin().y() + "\n");
    }
    //this.notify(delta);    
};

/*
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

teien.Actor.prototype.notify = function(delta){
    for(i=0; i < this.observers.length; i++){
        this.observers[i].update(delta);
    }
}
*/
