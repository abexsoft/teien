GhostActor = function(param){
    teien.Actor.call(this, param);
    this.type = param.type;    
};
GhostActor.prototype = Object.create(teien.Actor.prototype);

GhostActor.prototype.setup = function(physics){
    teien.Actor.prototype.setup.call(this, physics);
};

GhostActor.prototype.fromHash = function(param){
    teien.Actor.prototype.fromHash.call(this, param);
};

GhostActor.prototype.toHash = function(){
    hash = teien.Actor.prototype.toHash.call(this);
    hash.type = this.type;    
    return hash;
};


GhostActor.prototype.update = function(params){
    
};
