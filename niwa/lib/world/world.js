(function (exports) {
     exports.World = World;

    function World(appModel) {
	    var that = this;
	    
	    this.actorManager = new exports.ActorManager();
	    this.application = new appModel(this);
	    
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
	        that.application.update(delta);
	        
	        var actors = that.getAllActors();
	        postMessage({type: "update", actors: actors});
	    };
        
	    this.run = function() {
	        onmessage = function(event) {
		        switch(event.data.type){
		        case "setup": 
		            that.setup();
		            break;
		        default:
		            console.log(event.data.type);
		            that.application.onMessage(event);
		            break;
		        };
	        };
	    };
	    
    };
    
    World.prototype.setup = function() {
	    this.application.setup();    
	    
	    this.lastTime = Date.now();
	    setInterval(this.update, 1000 / 30);
    };
    
    
    World.prototype.getAllActors = function() {
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




