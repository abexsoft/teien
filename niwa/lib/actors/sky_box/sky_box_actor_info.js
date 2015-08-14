(function (exports) {
    exports.SkyBoxActorInfo = SkyBoxActorInfo;
    
    // The instance of this class is sent throght network. 
    function SkyBoxActorInfo(materials) {
	    this.materials = materials;
	    this.usePhysics = false;
	    this.type = SkyBoxActorInfo.prototype.type;
    };
    SkyBoxActorInfo.prototype.type = "skybox";
})(typeof exports === 'undefined' ? niwa : exports); 
