var HelloWorldBrowser = function() {
    var that = this;
    
    this.setup = function(model, userInterface) {
	    this.model = model;
	    this.userInterface = userInterface;
	    this.morphs = [];
        
	    this.userInterface.renderer.shadowMapEnabled = true;
        
	    this.userInterface.camera.position.set(0, 5, 10);
	    this.controls = new THREE.OrbitControls(this.userInterface.camera);
        
        
        //	this.userInterface.scene.add( new THREE.AmbientLight( 0xcccccc ) );
        
        
	    this.movementSpeed = 1.0;
	    this.moveForward = false;
	    this.moveBackward = false;
	    this.moveLeft = false;
	    this.moveRight = false;
	    this.freeze = false;
    };
    
    this.update = function(delta) {
        
	    if (this.freeze) return;
        
	    var actualMoveSpeed = delta * this.movementSpeed;
        
	    if ( this.moveForward )
	        this.controls.pan(new THREE.Vector3(0, 0,  -actualMoveSpeed));
	    
	    if ( this.moveBackward ) 
	        this.controls.pan(new THREE.Vector3(0, 0,  actualMoveSpeed));
        
	    if ( this.moveLeft ) 
	        this.controls.pan(new THREE.Vector3(-actualMoveSpeed, 0, 0));
        
	    if ( this.moveRight ) 
	        this.controls.pan(new THREE.Vector3(actualMoveSpeed, 0, 0));
        
	    this.controls.update(delta);
        
	    if (this.morphs[0])
	        this.morphs[0].updateAnimation(delta );
    };
    
    this.onKeyDown = function ( event ) {
	    switch ( event.keyCode ) {
	    case 38: /*up*/
	    case 87: /*W*/ that.moveForward = true; break;
	        
	    case 37: /*left*/
	    case 65: /*A*/ that.moveLeft = true; break;
	        
	    case 40: /*down*/
	    case 83: /*S*/ that.moveBackward = true; break;
	        
	    case 39: /*right*/
	    case 68: /*D*/ that.moveRight = true; break;
	        
	    case 81: /*Q*/ that.freeze = !this.freeze; break;
	    }
    };
    
    this.onKeyUp = function ( event ) {
	    switch( event.keyCode ) {
	    case 38: /*up*/
	    case 87: /*W*/ that.moveForward = false; break;
	        
	    case 37: /*left*/
	    case 65: /*A*/ that.moveLeft = false; break;
	        
	    case 40: /*down*/
	    case 83: /*S*/ that.moveBackward = false; break;
	        
	    case 39: /*right*/
	    case 68: /*D*/ that.moveRight = false; break;
            
	    case 82: /*r*/
            
	    }	
    };
    
    document.addEventListener( 'keydown', this.onKeyDown, false );
    document.addEventListener( 'keyup', this.onKeyUp, false );
};

/*
  var ui = new teien.UserInterface(HelloWorldBrowser);
  var model = new Worker("/hello_world_shared/hello_world_proxy.js");
*/
var browser = new niwa.Browser(HelloWorldBrowser);
browser.run();

