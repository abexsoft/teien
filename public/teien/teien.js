var teien = teien || {};

function importJs() {
    var scripts = new Array(
        //"teien/ammo.asm.js",
        "teien/ammo.js/builds/ammo.fast.js",                
        //"teien/ammo.js/builds/ammo.js",        
        "teien/actor.js",
        "teien/actors/sphere_actor.js",
        "teien/actors/box_actor.js",
        "teien/actors/ghost_actor.js",
        "teien/physics.js",
        'teien/utils.js',                
        'teien/world.js',        
        'teien/browser.js'
    );
    for (var i=0; i<scripts.length; i++) {
        document.write('<script type="text/javascript" src="' + scripts[i] + '"><\/script>');
    }
};
importJs();
