import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
    id: root
    moduleName: "no.koka.quick-reminders"
    
    property var activeReminders: []
    property var doneReminders: []
    
    implicitWidth: reminderText.width + 8
    implicitHeight: reminderText.height
    
    readonly property bool opened: panelLoader.item
        ? panelLoader.item.opened === true
        : false
    
    function open() {
        if (panelLoader.item) panelLoader.item.open()
    }
    
    function close() {
        if (panelLoader.item) panelLoader.item.close()
    }
    
    function toggle() {
        if (panelLoader.item) panelLoader.item.toggle()
    }
    
    function injectPanel() {
        if (!panelLoader.item) return
        panelLoader.item.bar = root.bar
        panelLoader.item.anchorItem = root
        panelLoader.item.hostWidget = root
    }
    
    onBarChanged: injectPanel()
    
    Row {
        spacing: 4
        
        Text {
            text: "·"
            color: root.barForeground || "#f8f8f2"
            font.family: "monospace"
            font.pixelSize: 14
        }
        
        Text {
            id: reminderText
            text: root.activeReminders.length > 0 
                ? root.activeReminders[0].text
                : "no reminders"
            color: root.barForeground || "#f8f8f2"
            opacity: root.activeReminders.length > 0 ? 1.0 : 0.5
            font.family: "monospace"
            font.pixelSize: 14
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggle()
        }
    }
    
    // Storage backend
    QtObject {
        id: storage
        property var reminders: []
        
        function getDataDir() {
            return Quickshell.env("HOME") + "/.local/share/omarchy"
        }
        
        function getDataFile() {
            return getDataDir() + "/quick-reminders.json"
        }
        
        function loadData() {
            readProcess.running = true
        }
        
        function saveData() {
            mkdirProcess.running = true
        }
        
        function updateFilteredLists() {
            var active = []
            var done = []
            
            for (var i = 0; i < reminders.length; i++) {
                var reminder = reminders[i]
                if (reminder.done) {
                    done.push(reminder)
                } else {
                    active.push(reminder)
                }
            }
            
            root.activeReminders = active
            root.doneReminders = done
        }
        
        function addReminder(text) {
            if (text.trim() === "") return
            
            var reminder = {
                id: Date.now(),
                text: text,
                timestamp: new Date().toISOString(),
                done: false,
                archived: false
            }
            
            storage.reminders.push(reminder)
            storage.saveData()
        }
        
        function markDone(id) {
            for (var i = 0; i < storage.reminders.length; i++) {
                if (storage.reminders[i].id === id) {
                    storage.reminders[i].done = true
                    break
                }
            }
            storage.saveData()
        }
        
        function archiveReminder(id) {
            for (var i = 0; i < storage.reminders.length; i++) {
                if (storage.reminders[i].id === id) {
                    storage.reminders[i].archived = true
                    break
                }
            }
            storage.saveData()
        }
        
        function deleteReminder(id) {
            var newReminders = []
            for (var i = 0; i < storage.reminders.length; i++) {
                if (storage.reminders[i].id !== id) {
                    newReminders.push(storage.reminders[i])
                }
            }
            storage.reminders = newReminders
            storage.saveData()
        }
    }
    
    Process {
        id: mkdirProcess
        running: false
        command: ["mkdir", "-p", storage.getDataDir()]
        onExited: function(exitCode) {
            writeProcess.running = true
        }
    }
    
    Process {
        id: writeProcess
        running: false
        command: ["sh", "-c", "echo '" + JSON.stringify(storage.reminders) + "' > " + storage.getDataFile()]
        onExited: function(exitCode) {
            storage.loadData()
        }
    }
    
    Process {
        id: readProcess
        running: false
        command: ["cat", storage.getDataFile()]
        stdout: StdioCollector {
            id: stdoutCollector
        }
        onExited: function(exitCode) {
            if (exitCode === 0) {
                var data = stdoutCollector.data()
                try {
                    storage.reminders = JSON.parse(data)
                    storage.updateFilteredLists()
                } catch (e) {
                    storage.reminders = []
                    root.activeReminders = []
                    root.doneReminders = []
                }
            } else {
                // File doesn't exist yet, initialize empty
                storage.reminders = []
                root.activeReminders = []
                root.doneReminders = []
            }
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: storage.loadData()
    }
    
    Component.onCompleted: {
        storage.loadData()
    }
    
    // Panel loader
    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }
}
