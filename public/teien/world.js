teien.World = function World(ws, app_klass) {
    this.ws = ws;
    this.physics = new teien.Physics(this);
    
    this.app = new app_klass(this);
    
    this.updatePeriod = 1.0 / 60.0; // sec
    this.actors = {};
};
/*
teien.World.prototype.run = function(ws_uri) {
    this.setup(ws_uri);
};
*/
teien.World.prototype.setup = function() {
    this.physics.setup();
    
    if (typeof(this.app.setup) == 'function')
        this.app.setup();

	this.lastUpdate = 0;
	setInterval(this.intervalHandler.bind(this), this.updatePeriod * 1000);
};

teien.World.prototype.intervalHandler = function() {
    if (this.lastUpdate == 0){
        this.lastUpdate = Date.now();
        return;
    }
        
    var now = Date.now();
    var delta = now - this.lastUpdate;
    this.lastUpdate = now;
    this.update(delta / 1000);  // sec
};

teien.World.prototype.hasActor = function(name){
    if (this.actors[name] == undefined)
        return false;
    else
        return true;
};

teien.World.prototype.createActor = function(actor_param){
    var actor = null;
    switch(actor_param['type']){
    case 'Sphere':
        actor = new SphereActor(actor_param);
        break;
    case 'Box':
        actor = new BoxActor(actor_param);
        break;        
    default:
        console.log("No such actor type: " + actor_param['type'] + "\n");
    }
    return actor;
};

teien.World.prototype.addActor = function(actor_param){
    var actor = this.createActor(actor_param);
    if (actor){
        actor.setup(this.physics);
        this.actors[actor_param.name] = actor;
        console.log("addActor: " + actor_param.name + "\n");
        if (typeof(this.app.addActor) == 'function')
            this.app.addActor(actor);            
    }
    return true;
}


teien.World.prototype.connected = function(event) {
    console.log("connected: " + event.total_clients + "\n");

    if (typeof(this.app.connected) == 'function')
        this.app.connected(this.ws, event);
};

teien.World.prototype.disconnected = function(event) {
    console.log("disconnected: " + event.total_clients + "\n");

    if (typeof(this.app.disconnected) == 'function')
        this.app.connected(this.ws, event);    
};

teien.World.prototype.receiveMessage = function(event) {
    switch(event.type){
    case "actors":
        for (var i = 0; i < event.data.length; i++) {
            //console.log("actor: " + event.data[i].name + "\n");
            if (!this.hasActor(event.data[i].name)){
                this.addActor(event.data[i]);
            }
            else {
                this.actors[event.data[i].name].fromHash(event.data[i]);
            }
        }
        break;
    default:
        //console.log("No such an event: " + event.type + "\n");
    }

    if (typeof(this.app.receiveMessage) == 'function')
        this.app.receiveMessage(this.ws, event);    
};


teien.World.prototype.update = function(delta) {
    //console.log("World::update is called: " + delta + "\n");

    // Physics update
    this.physics.update(delta);
    for (var i in this.actors){
        this.actors[i].updateTransform();
    }
    
    // App update
    if (typeof(this.app.update) == 'function')
        this.app.update(delta);
};





