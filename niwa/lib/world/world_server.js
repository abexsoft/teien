//
// startup frontend.
//
Ammo = require("../deps/ammo.js/builds/ammo.fast.js").Ammo;

(function (exports) {
    exports.WorldServer = WorldServer;
    
    function WorldServer(server_app_klass, browser_app_html, browser_app_public, user_port, admin_port) {
	    this.actorManager = new exports.ActorManager();
	    this.server_app = new server_app_klass(this);
        
	    this.browser_app_html = browser_app_html;
	    this.browser_app_public = browser_app_public;
	    this.user_port = user_port;
	    this.admin_port = admin_port;
        
	    this.syncTimePeriod = 300;
	    this.lastSyncTime = 0;
        
	    this.firstConnection = true;
	    this.sockets = {};
    };

    WorldServer.prototype.run = function() {
        this.path = require('path');
        var express = require('express');
        this.user_app = express();
        this.admin_app = express();
        
        this.user_app.use('/niwa', express.static(this.path.resolve(__dirname)));
        this.user_app.use(express.static(this.path.resolve(__dirname + '/../deps')));                        
        this.user_app.use(express.static(this.path.resolve(this.browser_app_public)));
        //user_app.set('views', this.path.resolve(this.browser_app_public));            

        this.setup_user_channel();
        if (this.admin_port) {
            this.setup_admin_channel();
        }
	};

    WorldServer.prototype.setup_user_channel = function(){
        /*
         * User channel
         */
        this.user_app.get('/', function (req, res) {
            var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress; 
            console.log('user reqest ip addr: %s', ip);
            res.sendFile(this.path.resolve(this.browser_app_html));
        }.bind(this));
        
        var user_port = this.user_port;
        var user_server = require('http').Server(this.user_app);
        var socket_io = require('socket.io')(user_server);
        
        var user_sock = user_server.listen(user_port, function () {
            var host = user_sock.address().address;
            var port = user_sock.address().port;
            
            console.log('Example app listening at http://%s:%s', host, port);
        }.bind(this));

	    socket_io.sockets.on(
            'connection', function (socket) {
			    console.log("connect: " + socket.id);
			    socket.emit('news', { server: 'hello world' });
			    socket.on('test_event', 
					      function (data) {
					          console.log(data);
					      });
                
			    if (this.firstConnection){
				    this.setup_server_app();
				    this.firstConnection = false;
			    }
                
			    this.sockets[socket.id] = socket;
                console.log('connection num: ' + Object.keys(this.sockets).length);
                
                socket.on('disconnect', function(){
                    console.log('disconnect: ' + socket.id);
	                delete this.sockets[socket.id];
                    console.log('connection num: ' + Object.keys(this.sockets).length);
                }.bind(this));
			}.bind(this));
    };

    /* 
     *  Admin channel
     */
    WorldServer.prototype.setup_admin_channel = function(){
        this.admin_app.get('/', function (req, res) {
            var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
            console.log('admin reqest ip addr: %s', ip);
            res.sendFile(__dirname + '/admin.html');    
        }.bind(this));
        
        var admin_port = this.admin_port;
        var admin_server = require('http').Server(this.admin_app);
        var admin_sock = admin_server.listen(admin_port, function () {
            var host = admin_sock.address().address;
            var port = admin_sock.address().port;
            
            console.log('Example app listening at http://%s:%s', host, port);
        }.bind(this));        
    };
    
    WorldServer.prototype.setup_server_app = function() {
	    this.server_app.setup();    
	    
	    this.lastTime = Date.now();
	    setInterval(this.update.bind(this), 1000 / 30);
    };

	WorldServer.prototype.enableShadow = function(bl) {
	    this.actorManager.defaultShadow = bl;
        //	     postMessage({type: "shadow", flag: bl});
	};
        
	WorldServer.prototype.update = function(delta) {
	    var now;
	    var delta;
	    
	    if (delta === undefined) {
		    now = Date.now();
		    delta = now - this.lastTime;
		    this.lastTime = now;
	    }
	    
	    this.actorManager.update(delta);
	    this.server_app.update(delta);
        
	    if ((now - this.lastSyncTime) > this.syncTimePeriod) {
		    var actors = this.getAllActors();
            for (var key in this.sockets) {
		        this.sockets[key].emit('actors', actors);
		    }
		    this.lastSyncTime = now;
	    }
	};    

    
    WorldServer.prototype.getAllActors = function() {
	    var actors = {};
	    
	    for(key in this.actorManager.actors) {
	        var actor = {};
	        
	        // actorInfo
	        actor.actorInfo = this.actorManager.actors[key].actorInfo;
	        
	        // transform
	        var transform = this.actorManager.actors[key].getTransform();
	        actor.transform = new exports.Transform(
		        exports.Vector3D.createFromAmmo(transform.getOrigin()),
		        exports.Quaternion.createFromAmmo(transform.getRotation()));
            
	        // linearVelocity
	        var linearVelocity = this.actorManager.actors[key].getLinearVelocity();
	        actor.linearVelocity = new exports.Vector3D.createFromAmmo(linearVelocity);
	        
	        actors[key] = actor;
	    }
	    
	    return actors;
    };
})(typeof exports === 'undefined' ? niwa : exports);


