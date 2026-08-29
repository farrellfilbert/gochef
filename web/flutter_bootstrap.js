{{flutter_js}}
{{flutter_build_config}}

// Add timestamp to bypass cache
_flutter.buildConfig.mainJsPath = _flutter.buildConfig.mainJsPath + "?v=" + Date.now();

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    // Hide the loading screen once Flutter has rendered its first frame
    var loader = document.getElementById('app-loader');
    if (loader) {
      loader.style.transition = 'opacity 0.3s ease';
      loader.style.opacity = '0';
      setTimeout(function() { loader.remove(); }, 350);
    }
  }
});
