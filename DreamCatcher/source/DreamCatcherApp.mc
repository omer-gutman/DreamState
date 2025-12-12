using Toybox.Application;
using Toybox.WatchUi;

// Renamed from DreamApp to DreamCatcherApp to match your project
class DreamCatcherApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    // Return the initial view and delegate
    function getInitialView() {
        return [ new DreamView(), new DreamDelegate() ];
    }
}