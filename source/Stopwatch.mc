//Edited from Flowstate @ Garmin Developers Forum
import Toybox.Lang;

class Stopwatch {
    enum StopwatchState {
        STOPWATCH_STATE_RESET = 0,   // initial state
        STOPWATCH_STATE_STARTED = 1, // stopwatch is running
        STOPWATCH_STATE_STOPPED = 2  // stopwatch is paused after being started
    }

    // The system uptime (in ms) when the stopwatch was last started
    protected var uptimeAtStart as Number or Null = null;
    // The stopwatch time (in ms) accumulated before the stopwatch was last stopped 
    // (this is required to handle multiple starts/stops)
    protected var stopwatchTimeBeforeStop as Number = 0;
    protected var state as StopwatchState = STOPWATCH_STATE_RESET;

    public function initialize() {
        onReset();
    }

    // reset the stopwatch (e.g. in response to the press of the LAP button while the stopwatch is stopped)
    public function onReset() as Void {
        uptimeAtStart = null;
        stopwatchTimeBeforeStop = 0;
        state = STOPWATCH_STATE_RESET;
    }

    // start or stop the stopwatch (e.g. in response to the press of the START button)
    public function onStartOrStop() as Void {
        if (state != STOPWATCH_STATE_STARTED) {
            uptimeAtStart = System.getTimer();
            state = STOPWATCH_STATE_STARTED;
        } else {
            stopwatchTimeBeforeStop = getTime();
            state = STOPWATCH_STATE_STOPPED;
        }
    }

    public function getState() as StopwatchState {
        return state;
    }

    // get stopwatch time in milliseconds
    // (this would be typically called from a timer - e.g. 50 ms for fast updates, 1 second for slow updates)
    public function getTime() as Number {
        var start = uptimeAtStart;
        var timeSinceStart = 0;
        if (start != null) {
            timeSinceStart = System.getTimer() - start;
        }
        return timeSinceStart + stopwatchTimeBeforeStop;
    }
}