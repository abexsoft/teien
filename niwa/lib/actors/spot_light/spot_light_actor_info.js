(function (exports) {
    exports.SpotLightActorInfo = SpotLightActorInfo;
    
    // The instance of this class is sent throght network. 
    function SpotLightActorInfo(color) {
	    this.color = color;
	    this.usePhysics = false;
	    this.type = exports.SpotLightActorInfo.prototype.type;
    };
    SpotLightActorInfo.prototype.type = "spotlight";
})(typeof exports === 'undefined' ? niwa : exports); 
