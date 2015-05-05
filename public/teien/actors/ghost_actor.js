GhostActor = function(param){
    teien.Actor.call(this, param);
    this.radius = param.radius;
};
GhostActor.prototype = Object.create(teien.Actor.prototype);

GhostActor.prototype.setup = function(physics){
    teien.Actor.prototype.setup.call(this, physics);
};

SphereActor.prototype.fromHash = function(param){
    teien.Actor.prototype.fromHash.call(this, param);
};

SphereActor.prototype.update = function(params){
    
};
