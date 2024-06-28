import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;

var delegate = null;

class TimeTrackerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        delegate = new TimeTrackerDelegate();
        
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new TimeTrackerView(), delegate ];
    }

}

function getApp() as TimeTrackerApp {
    return Application.getApp() as TimeTrackerApp;
}