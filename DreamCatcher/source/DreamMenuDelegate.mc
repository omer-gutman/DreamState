using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.SensorHistory;
// 1. THIS IS THE CRITICAL FIX (Importing Lang)
using Toybox.Lang; 

class DreamMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var keyword = item.getId();
        System.println("Selected: " + keyword);
        WatchUi.showToast("Generating...", null);
        uploadDream(keyword);
    }

    function uploadDream(dreamText) {
        // 2. PASTE YOUR NGROK URL HERE (Keep the /generate part!)
        var url = "https://uncaptivative-unrifted-artie.ngrok-free.dev/generate"; 
        
        System.println("Sending to URL: " + url); // This will print in the debug console

        var payload = {
            "dream_text" => dreamText,
            "sleep_score" => getBodyBattery()
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        // 3. This line was failing before, now it will work
        Communications.makeWebRequest(url, payload, options, method(:onReceive));
    }

    // 4. THIS IS THE OTHER CRITICAL FIX (Explicit Types)
    function onReceive(responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or Null) as Void {
        if (responseCode == 200) {
            System.println("Success! " + data);
            WatchUi.showToast("Sent!", null);
        } else {
            System.println("Failed: " + responseCode);
            WatchUi.showToast("Error " + responseCode, null);
        }
    }

    function getBodyBattery() {
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            var bbIter = SensorHistory.getBodyBatteryHistory({
                :period => 1, 
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            var sample = bbIter.next();
            if (sample != null && sample.data != null) { return sample.data; }
        }
        return 50; 
    }
}