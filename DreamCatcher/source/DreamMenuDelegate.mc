using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.SensorHistory;
using Toybox.Lang;

// --- CLASS 1: THE MENU HANDLER ---
class DreamMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var keyword = item.getId();
        
        if (keyword.equals("custom_input")) {
            // IF "Write Own..." is clicked -> Open the Keyboard
            var initialText = "";
            WatchUi.pushView(
                new WatchUi.TextPicker(initialText),
                new DreamTextPickerDelegate(), 
                WatchUi.SLIDE_LEFT
            );
        } else {
            // ELSE -> Send the saved word
            System.println("Selected: " + keyword);
            WatchUi.showToast("Generating...", null);
            
            // FIX 1: Create a NEW instance to call the function
            new DreamSender().uploadDream(keyword); 
        }
    }
}

// --- CLASS 2: THE KEYBOARD HANDLER ---
class DreamTextPickerDelegate extends WatchUi.TextPickerDelegate {

    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed) {
        System.println("Typed Dream: " + text);
        WatchUi.showToast("Generating...", null);
        
        // FIX 2: Create a NEW instance here too
        new DreamSender().uploadDream(text); 
        return true;
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

// --- CLASS 3: THE SHARED UPLOAD LOGIC ---
class DreamSender {
    
    // FIX 3: Removed 'static' from everything below
    // !!! PASTE YOUR NGROK URL HERE !!!
    var URL = "https://uncaptivative-unrifted-artie.ngrok-free.dev/generate"; 

    function uploadDream(dreamText) {
        System.println("Sending dream: " + dreamText);

        var payload = {
            "dream_text" => dreamText,
            "sleep_score" => getBodyBattery()
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        // Now 'method' works because we are inside an instance!
        Communications.makeWebRequest(URL, payload, options, method(:onReceive));
    }

    function onReceive(responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or Null) as Void {
        if (responseCode == 200) {
            System.println("Success! " + data);
            WatchUi.showToast("Check Email!", null);
        } else {
            System.println("Failed: " + responseCode);
            WatchUi.showToast("Error " + responseCode, null);
        }
    }

    function getBodyBattery() {
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            var bbIter = SensorHistory.getBodyBatteryHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            var sample = bbIter.next();
            if (sample != null && sample.data != null) { return sample.data; }
        }
        return 50; 
    }
}