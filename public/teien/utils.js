//
// Vector3D
//
teien.Vector3D = Vector3D;

function Vector3D(x, y, z) {
	this.x = x || 0;
	this.y = y || 0;
	this.z = z || 0;
};

Vector3D.createFromAmmo = function(vec) {
	return (new teien.Vector3D()).setFromAmmo(vec);
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
teien.Quaternion = Quaternion;

function Quaternion(x, y, z, w) {
	this.x = x || 0;
	this.y = y || 0;
	this.z = z || 0;
	this.w = ( w !== undefined ) ? w : 1;
};

Quaternion.createFromAmmo = function(quat) {
	return (new teien.Quaternion()).setFromAmmo(quat);
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
teien.Transform = Transform;

function Transform(position, rotation) {
	this.position = position || new teien.Vector3D();
	this.rotation = rotation || new teien.Quaternion();
};

teien.Transform.prototype.getPosition = function(){
    return this.position;
};

teien.Transform.prototype.getRotation = function(){
    return this.rotation;
};

teien.Transform.prototype.setPosition = function(pos){
    this.position = pos
};

teien.Transform.prototype.setRotation = function(rot){
    this.rotation = rot
};

//
// for Web Worker
//
// ref.
// http://updates.html5rocks.com/2012/06/How-to-convert-ArrayBuffer-to-and-from-String

teien.ab2str = function(buf) {
    return String.fromCharCode.apply(null, new Uint16Array(buf));
};

teien.str2ab = function(str) {
    var buf = new ArrayBuffer(str.length*2); // 2 bytes for each char
    var bufView = new Uint16Array(buf);
    for (var i = 0, strLen = str.length; i < strLen; i++) {
        bufView[i] = str.charCodeAt(i);
    }
    return buf;
};
