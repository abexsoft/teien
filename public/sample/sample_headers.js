(function() {
    var scripts = new Array(
        'teien/addons/threejs_ui/threejs_ui.js',
        'teien/addons/threejs_ui/three.js/examples/js/libs/stats.min.js'
    );
    for (var i=0; i<scripts.length; i++) {
        document.write('<script type="text/javascript" src="' + scripts[i] + '"><\/script>');
    }
})();

