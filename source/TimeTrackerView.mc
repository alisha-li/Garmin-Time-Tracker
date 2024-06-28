import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Time.Gregorian;
import Toybox.Timer;

class TimeTrackerView extends WatchUi.View {

    private var clockElement;
    private var stopwatchElement;
    private var heartrateLabel;
    private var dateElement;
    private var caloriesElement;
    
    function initialize() {
        View.initialize();
        var timer = new Timer.Timer();
        timer.start( method(:onTimer), 1000, true );
    }

    function onTimer() as Void{
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        heartrateLabel = findDrawableById("heartrate");
        clockElement = findDrawableById("clock");
        dateElement = findDrawableById("date");
        caloriesElement = findDrawableById("calories");
        stopwatchElement = findDrawableById("stopwatch");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        heartrateLabel.setText(getHeartRate());
        clockElement.setText(getTime());
        dateElement.setText(getDate());
        caloriesElement.setText(getCalories());
        stopwatchElement.setText(getStopwatch());

        View.onUpdate(dc);

        if(pid == WORK_PID){
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
        }
        else if(pid == ATHLETICS_PID){
            dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_PURPLE);
        }
        else if(pid == LEISURE_PID){
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_YELLOW);
        }
        else if(pid == LIFE_PID){
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_GREEN);
        }
        else{
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        }
        dc.fillCircle(200,125,20);
        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    //from jim_m_58 @ Garmin Forums
    function toHM(millisecs) {
        var secs = millisecs/1000;
        var hr = secs/3600;
        var min = (secs-(hr*3600))/60;
        var sec = secs%60;
        return hr.format("%02d")+":"+min.format("%02d");
    }

    function getStopwatch(){
        return toHM(stopwatch.getTime());
    }

    function getHeartRate(){
        if (ActivityMonitor has :getHeartRateHistory) {
            var heartRate = Activity.getActivityInfo().currentHeartRate;
            if(heartRate==null) {
                var HRH=ActivityMonitor.getHeartRateHistory(1, true);
                var HRS=HRH.next();
                if(HRS!=null && HRS.heartRate!= ActivityMonitor.INVALID_HR_SAMPLE){
                    heartRate = HRS.heartRate;
                }
            }
            if(heartRate!=null) {
                heartRate = heartRate.toString();
            }
            else{
                heartRate = "--";
            }
            return heartRate;
        }
        return "no HR";
    }

    function getTime(){
        var today = Gregorian.info( Time.now(), Time.FORMAT_SHORT );
        var hourMod = today.hour % 12;
        if (hourMod == 0) {
            hourMod = 12;
        }
		return Lang.format( "$1$:$2$", [
			hourMod.format( "%02d" ),
			today.min.format( "%02d" ),
		] );
    }

    function getDate(){
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dayOfWeek = Gregorian.info(Time.now(), Time.FORMAT_LONG).day_of_week;
        var dayOfMonth = today.day.format("%02d");
        return Lang.format("$1$ $2$", [dayOfMonth, dayOfWeek]);
    }

    function getCalories(){
        return ActivityMonitor.getInfo().calories.toString();
    }
    

}
