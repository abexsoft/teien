var teien = teien || {}

function importJs() {
    var scripts = new Array(
        //'teien/ammo.js/builds/ammo.js',
        'teien/ammo.asm.js',
        'teien/utils.js',
        'teien/actor.js',
        'teien/actors/sphere_actor.js',
        'teien/actors/box_actor.js',
        'teien/actors/ghost_actor.js',        
        'teien/physics.js',        
        'teien/world.js',
        'teien/browser.js'
    );
    for (var i=0; i<scripts.length; i++) {
        document.write('<script type="text/javascript" src="' + scripts[i] + '"><\/script>');
    }
};
importJs();

