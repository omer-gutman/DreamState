using Toybox.WatchUi;
using Toybox.System;

class DreamDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        openMenu();
        return true;
    }
    
    function onKey(keyEvent) {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            openMenu();
            return true;
        }
        return false;
    }

    function openMenu() {
        // 1. Create the Menu
        var menu = new WatchUi.Menu2({:title=>"I dreamt about..."});

        // 2. Add your Keywords here!
        // format: MenuItem( Label, SubLabel, ID, options )
        menu.addItem(new WatchUi.MenuItem("Flying", "Soaring high", "flying", null));
        menu.addItem(new WatchUi.MenuItem("Falling", "Scary drop", "falling", null));
        menu.addItem(new WatchUi.MenuItem("Chasing", "Running away", "chasing", null));
        menu.addItem(new WatchUi.MenuItem("Water", "Ocean/River", "water", null));
        menu.addItem(new WatchUi.MenuItem("Family", "Parents/Kids", "family", null));
        menu.addItem(new WatchUi.MenuItem("Work", "Office stress", "work", null));

        // 3. Push the Menu View
        WatchUi.pushView(menu, new DreamMenuDelegate(), WatchUi.SLIDE_UP);
    }
}