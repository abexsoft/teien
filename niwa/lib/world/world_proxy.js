importScripts("/ammo.js/builds/ammo.fast.js");
importScripts("/socket.io/socket.io.js");

(function (exports) {
    exports.WorldProxy = WorldProxy;
    
    function WorldProxy() {
	    var that = this;
	    this.actorManager = new exports.ActorManager();
	    
	    this.enableShadow = function(bl) {
	        this.actorManager.defaultShadow = bl;
	        postMessage({type: "shadow", flag: bl});
	    };
	    
	    this.update = function(delta) {
	        var now;
	        var delta;
	        
	        if (delta === undefined) {
		        now = Date.now();
		        delta = now - that.lastTime;
		        that.lastTime = now;
	        }
	        
	        that.actorManager.update(delta);
	        
	        var actors = that.getAllActors();
	        postMessage({type: "update", actors: actors});
	    };
        
	    this.merge = function(actors) {
	        that.actorManager.merge(actors);
	    };
        
	    this.run = function() {
	        var socket = io.connect();
            
	        socket.on('news', 
		              function (data) {
			              console.log(data);
			              socket.emit('test_event', { proxy: 'hello world' });
		              });
            
	        socket.on('actors', 
		              function (data) {
			              that.merge(data);
		              });
	        
	        onmessage = function(event) {
		        switch(event.data.type){
		        case "setup": 
		            that.setup();
		            break;
		        default:
		        };
	        };
	    };
	    
    };
    
    WorldProxy.prototype.setup = function() {
	    this.lastTime = Date.now();
	    setInterval(this.update, 1000 / 30);
    };
    
    
    WorldProxy.prototype.getAllActors = function() {
	    var actors = {};
	    
	    for(key in this.actorManager.actors) {
	        var actor = {};
	        
	        actor.actorInfo = this.actorManager.actors[key].actorInfo;
	        
	        var transform = this.actorManager.actors[key].getTransform();
	        actor.transform = new exports.Transform(
		        exports.Vector3D.createFromAmmo(transform.getOrigin()),
		        exports.Quaternion.createFromAmmo(transform.getRotation()));
	        
	        actors[key] = actor;
	    }
	    
	    return actors;
    };
})(typeof exports === 'undefined' ? niwa : exports);

var world = new niwa.WorldProxy();
world.run();
