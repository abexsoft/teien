BoxActor = function(param){
    teien.Actor.call(this, param);
    this.type = param.type;
    this.x = param.x;
    this.y = param.y;
    this.z = param.z;    
};
BoxActor.prototype = Object.create(teien.Actor.prototype);

BoxActor.prototype.setup = function(physics){
    var col_obj = new Ammo.btBoxShape(new Ammo.btVector3(this.x / 2, this.y / 2, this.z / 2));
    var inertia = new Ammo.btVector3();
    col_obj.calculateLocalInertia(this.physics_info.mass, inertia);
    
    // Ammo does not support btMotionState handling.
    //this.rigidBody = new Ammo.btRigidBody(this.mass, this, col_obj, inertia);
    var ms = new Ammo.btDefaultMotionState(this.transform);
    this.rigidBody = new Ammo.btRigidBody(this.physics_info.mass, ms, col_obj, inertia);
    physics.addRigidBody(this.rigidBody);

    teien.Actor.prototype.setup.call(this, physics);    
};

BoxActor.prototype.fromHash = function(param){
    teien.Actor.prototype.fromHash.call(this, param);
    this.x = param.x;
    this.y = param.y;
    this.z = param.z;    
};

BoxActor.prototype.update = function(params){
    
};
