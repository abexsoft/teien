(function (exports) {
    exports.SphereActorInfo = SphereActorInfo;
    
    // The instance of this class is sent throght network. 
    function SphereActorInfo(radius) {
	    this.radius = radius;
        
	    // for physics
	    this.usePhysics = true;
	    this.mass = 0;
	    this.angularFactor = new exports.Vector3D(1.0, 1.0, 1.0);
	    this.restitution = 0.2;
	    this.friction = 1.0;
	    this.linearDamping = 0.0;
	    this.angularDamping = 0.0;
	    this.collisionFilter = null;
	    
	    // for visual
	    this.textureName = null;
	    
	    this.type = exports.SphereActorInfo.prototype.type;
    };
    SphereActorInfo.prototype.type = "sphere";
})(typeof exports === 'undefined' ? niwa : exports);
