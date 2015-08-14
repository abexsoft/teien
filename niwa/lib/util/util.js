/**
 * These classes are used for follows.
 * 1. ammo.js-to-three.js communication.
 * 2. browser-to-worker and worker-to-node communications.
 */

(function (exports) {
    
    //
    // Vector3D
    //
    exports.Vector3D = Vector3D;
    
    function Vector3D(x, y, z) {
	    this.x = x || 0;
	    this.y = y || 0;
	    this.z = z || 0;
    };
    
    Vector3D.createFromAmmo = function(vec) {
	    return (new exports.Vector3D()).setFromAmmo(vec);
    };
    
    Vector3D.prototype.setFromAmmo = function(vec) {
	    this.x = vec.x();
	    this.y = vec.y();
	    this.z = vec.z();  
	    return this;
    };
    
    
    //
    // Quaternion
    //
    exports.Quaternion = Quaternion;
    
    function Quaternion(x, y, z, w) {
	    this.x = x || 0;
	    this.y = y || 0;
	    this.z = z || 0;
	    this.w = ( w !== undefined ) ? w : 1;
    };
    
    Quaternion.createFromAmmo = function(quat) {
	    return (new exports.Quaternion()).setFromAmmo(quat);
    };
    
    Quaternion.prototype.setFromAmmo = function(quat) {
	    this.x = quat.x();
	    this.y = quat.y();
	    this.z = quat.z();  
	    this.w = quat.w();  
	    return this;
    };
    
    
    //
    // Transform
    //
    exports.Transform = Transform;
    
    function Transform(position, rotation) {
	    this.position = position || new exports.Vector3D();
	    this.rotation = rotation || new exports.Quaternion();
    };
})(typeof exports === 'undefined' ? niwa : exports); 


