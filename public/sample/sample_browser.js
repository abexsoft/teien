function MyUi(world){
    this.world = world;
    this.container = document.getElementById('threejs_canvas');
    this.threejs_ui = new teien.ThreejsUi(this.container, {option : true});
    
    this.stats = new Stats();
    this.stats.domElement.style.position = 'absolute';
    this.stats.domElement.style.top = '10px';
    this.container.appendChild(this.stats.domElement);

    this.setup = function(){
        this.threejs_ui.setup();
    };

    this.update = function(delta) {
        this.threejs_ui.update(delta, this.world.actors)

        this.stats.update();
        
        if (this.freeze) return;
/*
        var actualMoveSpeed = delta * this.movementSpeed;

        if ( this.moveForward )
            this.controls.pan(new THREE.Vector3(0, 0,  -actualMoveSpeed));
        
        if ( this.moveBackward ) 
            this.controls.pan(new THREE.Vector3(0, 0,  actualMoveSpeed));

        if ( this.moveLeft ) 
            this.controls.pan(new THREE.Vector3(-actualMoveSpeed, 0, 0));

        if ( this.moveRight ) 
            this.controls.pan(new THREE.Vector3(actualMoveSpeed, 0, 0));
*/


//        this.container.requestPointerLock();
    };

    this.onKeyDown = function ( event ) {
        console.log("user onKeyDown");

        switch ( event.keyCode ) {
        case 38: /*up*/
        case 87: /*W*/ this.moveForward = true; break;
            
        case 37: /*left*/
        case 65: /*A*/ this.moveLeft = true; break;
            
        case 40: /*down*/
        case 83: /*S*/ this.moveBackward = true; break;
            
        case 39: /*right*/
        case 68: /*D*/ this.moveRight = true; break;
            
        case 81: /*Q*/ this.freeze = !this.freeze; break;
        }
    };
    
    this.onKeyUp = function ( event ) {
        switch( event.keyCode ) {
        case 38: /*up*/
        case 87: /*W*/ this.moveForward = false; break;
            
        case 37: /*left*/
        case 65: /*A*/ this.moveLeft = false; break;
            
        case 40: /*down*/
        case 83: /*S*/ this.moveBackward = false; break;
            
        case 39: /*right*/
        case 68: /*D*/ this.moveRight = false; break;

        case 82: /*r*/
        }       
    };

    this.onMouseDown = function(event) {
        event.preventDefault();
        event.stopPropagation();

        switch ( event.button ) {
        case 0: 

/*
            this.leftMouse = true; 
            var pos = this.camera.position;
            var dir = new THREE.Vector3(0, 0, -1);
            dir.applyQuaternion(this.world.camera.quaternion);
*/
/*
            world.postMessage({type: "shotbox",
                               pos: pos,
                               dir: dir
                              });
*/
            break;
        case 2:
            this.rightMouse = true; 
            console.log("right mouse");
            break;
        }
    };

    this.onWindowResize = function(s){
        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
        
        this.renderer.setSize( window.innerWidth, window.innerHeight );
    };
//    document.addEventListener( 'keydown', this.onKeyDown.bind(this), false );
//    document.addEventListener( 'keyup', this.onKeyUp.bind(this), false );
    document.addEventListener( 'mousedown', this.onMouseDown.bind(this), false );
};

var host = window.location.host
var browser = new teien.Browser("ws://" + host + "/sample", MyUi);
