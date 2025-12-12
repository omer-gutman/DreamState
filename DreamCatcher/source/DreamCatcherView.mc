using Toybox.WatchUi;
using Toybox.Graphics;

class DreamView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Update the view
    function onUpdate(dc) {
        // Set background color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Set text color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Get screen center
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Draw the instruction text
        dc.drawText(
            width / 2, 
            height / 2, 
            Graphics.FONT_MEDIUM, 
            "Tap to Record\nYour Dream", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}