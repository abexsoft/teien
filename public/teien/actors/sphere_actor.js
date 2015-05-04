SphereActor = function(param){
    teien.Actor.call(this, param);
    this.type = param.type;
    this.radius = param.radius;
};
SphereActor.prototype = Object.create(teien.Actor.prototype);

SphereActor.prototype.setup = function(physics){
    var col_obj = new Ammo.btSphereShape(this.radius);
    var inertia = new Ammo.btVector3();
    col_obj.calculateLocalInertia(this.physics_info.mass, inertia);
    // Ammo does not support btMotionState handling.
    //this.rigidBody = new Ammo.btRigidBody(this.mass, this, col_obj, inertia);
    var ms = new Ammo.btDefaultMotionState(this.transform);
    this.rigidBody = new Ammo.btRigidBody(this.physics_info.mass, ms, col_obj, inertia);
    physics.addRigidBody(this.rigidBody);

    teien.Actor.prototype.setup.call(this, physics);
};

SphereActor.prototype.fromHash = function(param){
    teien.Actor.prototype.fromHash.call(this, param);
    this.radius = param.radius;
};

SphereActor.prototype.update = function(params){
    
};
