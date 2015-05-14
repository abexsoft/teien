teien.World = function World(app_klass) {
    var that = this;
    this.physics = new teien.Physics(this);
    this.app = new app_klass(this);
    
    this.updatePeriod = 1.0 / 60.0; // sec
    this.actors = {};
};

teien.World.prototype.setup = function(ws_uri) {
    this.ws_uri = ws_uri;
    this.ws = new WebSocket(ws_uri);
    this.ws.onmessage = this.receiveMessage.bind(this);
    
    this.physics.setup();
    
    if (typeof(this.app.setup) == 'function')
        this.app.setup();

	this.lastUpdate = 0;
	//setInterval(this.intervalHandler.bind(this), this.updatePeriod * 1000.0);
    requestAnimationFrame(this.intervalHandler.bind(this));
};

teien.World.prototype.intervalHandler = function() {
    requestAnimationFrame(this.intervalHandler.bind(this));
    
    if (this.lastUpdate == 0){
        this.lastUpdate = Date.now();
        return;
    }
        
    var now = Date.now();
    var delta = now - this.lastUpdate;
    this.lastUpdate = now;
    this.update(delta / 1000.0);  // sec

    //console.log("delta: " + delta);
};

teien.World.prototype.receiveMessage = function(ws_msg){
    var event = JSON.parse(ws_msg.data);
    switch(event.type){
    case "client_connected":
        this.clientConnected(event);
        break;
    case "client_disconnected":
        this.clientDisconnected(event);
        break;
    case "connected":
        for (var i = 0; i < event.data.length; i++) {
            //console.log("actor: " + event.data[i].name + "\n");
            this.addActor(event.data[i]);
        }
        
        if (typeof(this.app.connected) == 'function')
            this.app.connected();
        
        this.ws.send(JSON.stringify({type: 'ready'}));
        break;        
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
    case 'Ghost':
        actor = new GhostActor(actor_param);
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
//        if (typeof(this.app.addActor) == 'function')
//            this.app.addActor(actor);            
    }
    return true;
}


teien.World.prototype.clientConnected = function(event) {
    console.log("A client is connected: " + event.total_clients + "\n");
};

teien.World.prototype.clientDisconnected = function(event) {
    console.log("A client is disconnected: " + event.total_clients + "\n");
};

teien.World.prototype.update = function(delta) {
    //console.log("World::update is called: " + delta + "\n");

    // Physics update
    this.physics.update(delta);
    for (var i in this.actors){
        this.actors[i].updateTransform(delta);
    }
    
    if (typeof(this.app.update) == 'function')
        this.app.update(delta);    
};

