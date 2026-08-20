import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

Panel {
    id: root
    moduleName: "no.koka.quick-reminders"
    manageIpc: false
    
    property var hostWidget: null
    property var anchorItem: null
    
    function open() {
        root.controller.show()
    }
    
    function close() {
        root.controller.hide()
    }
    
    function switchPanel(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
            return root.bar.switchPanelFrom(root.hostWidget || root, direction)
        return false
    }
    
    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher
        contentWidth: panel.fittedContentWidth(Style.space(360))
        contentHeight: panel.fittedContentHeight(content.implicitHeight)
        
        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onCloseRequested: root.close()
            onTabRequested: function(direction) { root.switchPanel(direction) }
            
            Column {
                id: content
                width: parent.width
                spacing: Style.space(8)
                padding: Style.space(12)
                
                // Header
                Text {
                    text: "Quick Reminders"
                    color: root.barForeground
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.subtitle
                    font.bold: true
                }
                
                // Input row
                Row {
                    width: parent.width - parent.padding * 2
                    spacing: Style.space(4)
                    
                    Rectangle {
                        width: parent.width - 70
                        height: 32
                        color: "#44475a"
                        radius: 4
                        
                        TextInput {
                            id: reminderInput
                            anchors.fill: parent
                            anchors.margins: 8
                            color: "#f8f8f2"
                            font.pixelSize: 13
                            verticalAlignment: TextInput.AlignVCenter
                            
                            Text {
                                visible: !reminderInput.text && !reminderInput.focus
                                text: "Add a reminder..."
                                color: "#6272a4"
                                font.pixelSize: 13
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Keys.onReturnPressed: {
                                if (root.hostWidget && root.hostWidget.storage) {
                                    root.hostWidget.storage.addReminder(reminderInput.text)
                                    reminderInput.text = ""
                                }
                            }
                        }
                    }
                    
                    Rectangle {
                        id: addButton
                        width: 60
                        height: 32
                        color: addMouseArea.containsMouse ? "#50fa7b" : "#5af78e"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Add"
                            color: "#282a36"
                            font.pixelSize: 13
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: addMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.hostWidget && root.hostWidget.storage) {
                                    root.hostWidget.storage.addReminder(reminderInput.text)
                                    reminderInput.text = ""
                                }
                            }
                        }
                    }
                }
                
                // Tab buttons
                Row {
                    spacing: Style.space(4)
                    
                    Rectangle {
                        width: 90
                        height: 28
                        color: tabView.currentTab === "active" ? "#6272a4" : "#44475a"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Active (" + (root.hostWidget ? root.hostWidget.activeReminders.length : 0) + ")"
                            color: "#f8f8f2"
                            font.pixelSize: 11
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabView.currentTab = "active"
                        }
                    }
                    
                    Rectangle {
                        width: 90
                        height: 28
                        color: tabView.currentTab === "done" ? "#6272a4" : "#44475a"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Done (" + (root.hostWidget ? root.hostWidget.doneReminders.length : 0) + ")"
                            color: "#f8f8f2"
                            font.pixelSize: 11
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabView.currentTab = "done"
                        }
                    }
                    
                    Rectangle {
                        width: 90
                        height: 28
                        color: tabView.currentTab === "archived" ? "#6272a4" : "#44475a"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Archive (" + (root.hostWidget ? root.hostWidget.archivedReminders.length : 0) + ")"
                            color: "#f8f8f2"
                            font.pixelSize: 11
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabView.currentTab = "archived"
                        }
                    }
                }
                
                // Content area with tabs
                Item {
                    id: tabView
                    width: parent.width - parent.padding * 2
                    height: 350
                    
                    property string currentTab: "active"
                    
                    // Active reminders
                    ListView {
                        visible: tabView.currentTab === "active"
                        anchors.fill: parent
                        spacing: 6
                        clip: true
                        
                        model: root.hostWidget ? root.hostWidget.activeReminders : []
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: reminderTextItem.height + 16
                            color: "#44475a"
                            radius: 4
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                Text {
                                    id: reminderTextItem
                                    text: modelData.text
                                    color: "#f8f8f2"
                                    font.pixelSize: 12
                                    width: parent.width - doneBtn.width - 16
                                    wrapMode: Text.WordWrap
                                }
                                
                                Rectangle {
                                    id: doneBtn
                                    width: 50
                                    height: 22
                                    color: doneBtnMouse.containsMouse ? "#50fa7b" : "#5af78e"
                                    radius: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Done"
                                        color: "#282a36"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    
                                    MouseArea {
                                        id: doneBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.hostWidget && root.hostWidget.storage) {
                                                root.hostWidget.storage.markDone(modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Done reminders
                    ListView {
                        visible: tabView.currentTab === "done"
                        anchors.fill: parent
                        spacing: 6
                        clip: true
                        
                        model: root.hostWidget ? root.hostWidget.doneReminders : []
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: reminderTextItem.height + 16
                            color: "#44475a"
                            radius: 4
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                Text {
                                    id: reminderTextItem
                                    text: modelData.text
                                    color: "#6272a4"
                                    font.pixelSize: 12
                                    font.strikeout: true
                                    width: parent.width - archiveBtn.width - 16
                                    wrapMode: Text.WordWrap
                                }
                                
                                Rectangle {
                                    id: archiveBtn
                                    width: 60
                                    height: 22
                                    color: archiveBtnMouse.containsMouse ? "#8be9fd" : "#a0f0ff"
                                    radius: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Archive"
                                        color: "#282a36"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    
                                    MouseArea {
                                        id: archiveBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.hostWidget && root.hostWidget.storage) {
                                                root.hostWidget.storage.archiveReminder(modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Archived reminders
                    ListView {
                        visible: tabView.currentTab === "archived"
                        anchors.fill: parent
                        spacing: 6
                        clip: true
                        
                        model: root.hostWidget ? root.hostWidget.archivedReminders : []
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: reminderTextItem.height + 16
                            color: "#44475a"
                            radius: 4
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                Text {
                                    id: reminderTextItem
                                    text: modelData.text
                                    color: "#6272a4"
                                    font.pixelSize: 12
                                    font.strikeout: true
                                    width: parent.width - deleteBtn.width - 16
                                    wrapMode: Text.WordWrap
                                }
                                
                                Rectangle {
                                    id: deleteBtn
                                    width: 50
                                    height: 22
                                    color: deleteBtnMouse.containsMouse ? "#ff5555" : "#ff6e6e"
                                    radius: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Delete"
                                        color: "#282a36"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    
                                    MouseArea {
                                        id: deleteBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.hostWidget && root.hostWidget.storage) {
                                                root.hostWidget.storage.deleteReminder(modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
