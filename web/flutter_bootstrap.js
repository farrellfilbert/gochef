{{flutter_js}}
{{flutter_build_config}}

// Add timestamp to bypass cache
_flutter.buildConfig.mainJsPath = _flutter.buildConfig.mainJsPath + "?v=" + Date.now();

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  }
});
