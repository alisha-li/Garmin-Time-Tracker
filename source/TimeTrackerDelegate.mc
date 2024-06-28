import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Time.Gregorian;
import Toybox.Application.Storage;
import Toybox.StringUtil;

var buttonClicked;
var pid; //project id
var stopwatch;

const TOGGL_WORKSPACE_ID = ---;
const TOGGL_API_TOKEN = "---";
const WORK_PID = ---;
const ATHLETICS_PID = ---;
const LEISURE_PID = ---;
const LIFE_PID = ---;


class TimeTrackerDelegate extends WatchUi.BehaviorDelegate {
    var key;
    var timeEntries;
    var startTime;

    function initialize() {
        BehaviorDelegate.initialize();
        stopwatch = new Stopwatch();
        Storage.clearValues();
        key = "key";
        if(Storage.getValue(key) == null){
            Storage.setValue(key, []);
        }
        timeEntries = Storage.getValue(key);
    }

    function onKey(keyEvent){
        if (keyEvent.getKey() == 13 || keyEvent.getKey() == 8 || keyEvent.getKey() == 5 || keyEvent.getKey() == 4){
            var duration = stopwatch.getTime()/1000;

            timeEntries.add([startTime, duration, pid]);

            Storage.setValue(key, timeEntries);

            stopwatch.onReset();
            stopwatch.onStartOrStop();
            
            sendToToggle(startTime, duration, pid);
            WatchUi.requestUpdate();

            //startTime and pid assigned after sendToToggl since they apply to current task being tracked, not the one being sent

            var now = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT );
	        startTime = Lang.format( "$1$-$2$-$3$T$4$:$5$:$6$Z", [
                now.year.format("%04d"),
                now.month.format("%02d"),
                now.day.format("%02d"),
		        now.hour.format( "%02d" ),
		        now.min.format( "%02d" ),
                now.sec.format( "%02d" )] );

            if(keyEvent.getKey() == 13){
                pid = WORK_PID;
            }
            else if(keyEvent.getKey() == 8){
                pid = ATHLETICS_PID;
            }
            else if(keyEvent.getKey() == 5){
                pid = LEISURE_PID;
            }
            else if(keyEvent.getKey() == 4){
                pid = LIFE_PID;
            }

        }
        
        return true;
    }

    function sendToToggle(start, duration, pid) as Boolean {

        var message = {
            "duration" => duration,
            "start" => start,
            "project_id" => pid,
            "workspace_id" => TOGGL_WORKSPACE_ID,
            "created_with" => "MonkeyC TimeTracker"
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "Authorization" => "Basic " + StringUtil.encodeBase64(TOGGL_API_TOKEN + ":api_token")
             }
        };
        Communications.makeWebRequest("https://api.track.toggl.com/api/v9/workspaces/"+TOGGL_WORKSPACE_ID+"/time_entries", message, options, method(:onResponse));
        
        return true;
    }

    function onResponse(responseCode as Number, data as Dictionary?) as Void{
        System.println("Received response with status code: " + responseCode + " and data: " + data);
        if (responseCode == 200) {
            if(timeEntries[0][0] == null){ //to remove the very first invalid entry [null, 0, null]
                timeEntries.remove(timeEntries[0]);
            }
            timeEntries.remove(timeEntries[0]);
            System.println(timeEntries); //show the remaining entries in storage
            Storage.setValue(key, timeEntries);
            if (timeEntries.size() > 0){ //recursively send data to toggl until all entries are sent
                sendToToggle(timeEntries[0][0], timeEntries[0][1], timeEntries[0][2]);
             }
        } else {
            Storage.setValue(key, timeEntries);
        }
    }
}