niwa = require("../../builds/niwa_server.js");

var HelloWorld = function(world) {
    var that = this;
    this.world = world;
	
    this.setup = function(){
	    var obj;
	    var actorInfo;
        
	    this.world.enableShadow(true);
        
	    var materials = [
            '/three.js/examples/textures/cube/skybox/px.jpg' ,
            '/three.js/examples/textures/cube/skybox/nx.jpg' ,
            '/three.js/examples/textures/cube/skybox/py.jpg' ,
            '/three.js/examples/textures/cube/skybox/ny.jpg' ,
            '/three.js/examples/textures/cube/skybox/pz.jpg' ,
            '/three.js/examples/textures/cube/skybox/nz.jpg'  
        ];
        
	    actorInfo = new niwa.SkyBoxActorInfo(materials);
	    obj = this.world.actorManager.createActor("skybox", actorInfo);

	    actorInfo = new niwa.SpotLightActorInfo(0xffffff);
	    obj = this.world.actorManager.createActor("spotLight", actorInfo);
	    obj.setPosition(new niwa.Vector3D(-60,150,-30));

	    actorInfo = new niwa.JsonMeshActorInfo(
	        '/three.js/examples/models/animated/monster/monster.js');
	    actorInfo.mass = 10;
	    actorInfo.height = 1;
	    actorInfo.width = 1;
	    actorInfo.depth = 1;
	    actorInfo.viewPositionOffset = new niwa.Vector3D(0, -0.5, 0);
	    obj = this.world.actorManager.createActor("jsonMesh", actorInfo);
	    obj.setPosition(new niwa.Vector3D(0, 5 ,0));
        
	    actorInfo = new niwa.BoxActorInfo(1, 1, 1);
	    actorInfo.textureName = "/three.js/examples/textures/crate.gif";
	    actorInfo.mass = 10;
	    obj = this.world.actorManager.createActor("box1", actorInfo);
	    obj.setPosition(new niwa.Vector3D(0, 10, 0));
        
	    obj = this.world.actorManager.createActor("box2", actorInfo);
	    obj.setPosition(new niwa.Vector3D(2, 10, 0));
        
	    obj = this.world.actorManager.createActor("box3", actorInfo);
	    obj.setPosition(new niwa.Vector3D(4, 10, 0));
        
	    obj = this.world.actorManager.createActor("box4", actorInfo);
	    obj.setPosition(new niwa.Vector3D(-2, 10, 0));
        
        
	    actorInfo = new niwa.SphereActorInfo(0.5);
	    actorInfo.mass = 5;
	    actorInfo.textureName = "/three.js/examples/textures/crate.gif";
	    obj = this.world.actorManager.createActor("sphere0", actorInfo);
	    obj.setPosition(new niwa.Vector3D(0, 15, 0));
        
	    obj = this.world.actorManager.createActor("sphere1", actorInfo);
	    obj.setPosition(new niwa.Vector3D(0.5, 17, 0));
        
	    obj = this.world.actorManager.createActor("sphere2", actorInfo);
	    obj.setPosition(new niwa.Vector3D(0, 19, -0.5));
        
	    actorInfo = new niwa.BoxActorInfo(50, 1, 50);
	    actorInfo.textureName = "/three.js/examples/textures/terrain/grasslight-big.jpg";
	    obj = this.world.actorManager.createActor("floor", actorInfo);
	    obj.setPosition(new niwa.Vector3D(0, -0.5, 0));
    };
    
    this.update = function(delta){
    };
};

var indexHtml = __dirname + "/hello_world_browser.html";
var publicRoot = __dirname;

var server = new niwa.WorldServer(HelloWorld, indexHtml, publicRoot, 3000);
server.run();





