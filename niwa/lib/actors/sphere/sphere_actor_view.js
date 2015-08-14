niwa.SphereActorView = function(name, actorInfo, userInterface) {
    niwa.ActorView.call(this, userInterface);
    
    this.name = name;
    this.actorInfo = actorInfo;
    
    var texture = THREE.ImageUtils.loadTexture(actorInfo.textureName);
    texture.anisotropy = userInterface.renderer.getMaxAnisotropy();
    
    if (actorInfo.castShadow || actorInfo.receiveShadow)
	    var material = new THREE.MeshLambertMaterial({ map: texture });
    else
	    var material = new THREE.MeshBasicMaterial( { map: texture } );
    
    var geometry = new THREE.SphereGeometry(actorInfo.radius);
    this.object = new THREE.Mesh( geometry, material );
    //this.object.useQuaternion = true;
    
    this.object.castShadow = actorInfo.castShadow;
    this.object.receiveShadow = actorInfo.receiveShadow;
    
    userInterface.scene.add(this.object);
};

niwa.SphereActorView.prototype = Object.create(niwa.ActorView.prototype);
niwa.SphereActorView.prototype.constructor = niwa.ActorView;

niwa.UserInterface.setCreator(
    niwa.SphereActorInfo.prototype.type, 
    function(name, actorInfo, userInterface) {
	    return new niwa.SphereActorView(name, actorInfo, userInterface);
    }
);
