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
        Qt.callLater(function() {
            reminderInput.forceActiveFocus()
        })
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
        focusTarget: reminderInput
        contentWidth: panel.fittedContentWidth(Style.space(400))
        contentHeight: panel.fittedContentHeight(content.implicitHeight)
        
        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onCloseRequested: root.close()
            onTabRequested: function(direction) { root.switchPanel(direction) }
            
            Column {
                id: content
                width: parent.width
                spacing: 0
                padding: Style.space(8)
                
                // Header line
                Row {
                    width: parent.width - parent.padding * 2
                    spacing: Style.space(12)
                    
                    Text {
                        text: ">"
                        color: root.barForeground
                        font.family: "monospace"
                        font.pixelSize: Style.font.body
                    }
                    
                    TextInput {
                        id: reminderInput
                        width: parent.width - 20
                        color: root.barForeground
                        font.family: "monospace"
                        font.pixelSize: Style.font.body
                        
                        Text {
                            visible: !reminderInput.text && !reminderInput.focus
                            text: "add reminder"
                            color: root.barForeground
                            opacity: 0.4
                            font.family: "monospace"
                            font.pixelSize: Style.font.body
                        }
                        
                        Keys.onReturnPressed: {
                            if (reminderInput.text.trim() !== "" && root.hostWidget && root.hostWidget.storage) {
                                root.hostWidget.storage.addReminder(reminderInput.text)
                                reminderInput.text = ""
                                reminderInput.forceActiveFocus()
                            }
                        }
                        
                        Keys.onEscapePressed: {
                            root.close()
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    width: parent.width - parent.padding * 2
                    height: 1
                    color: root.barForeground
                    opacity: 0.2
                    y: Style.space(8)
                }
                
                Item { height: Style.space(8); width: 1 }
                
                // Tab navigation
                Row {
                    width: parent.width - parent.padding * 2
                    spacing: Style.space(16)
                    
                    Text {
                        text: tabView.currentTab === "active" ? "[active]" : "active"
                        color: root.barForeground
                        opacity: tabView.currentTab === "active" ? 1.0 : 0.5
                        font.family: "monospace"
                        font.pixelSize: Style.font.body
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabView.currentTab = "active"
                        }
                    }
                    
                    Text {
                        text: tabView.currentTab === "done" ? "[done]" : "done"
                        color: root.barForeground
                        opacity: tabView.currentTab === "done" ? 1.0 : 0.5
                        font.family: "monospace"
                        font.pixelSize: Style.font.body
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabView.currentTab = "done"
                        }
                    }
                }
                
                Item { height: Style.space(4); width: 1 }
                
                // Content
                Item {
                    id: tabView
                    width: parent.width - parent.padding * 2
                    height: 400
                    
                    property string currentTab: "active"
                    
                    // Active reminders
                    ListView {
                        visible: tabView.currentTab === "active"
                        anchors.fill: parent
                        spacing: 0
                        clip: true
                        
                        model: root.hostWidget ? root.hostWidget.activeReminders : []
                        
                        delegate: Item {
                            width: ListView.view.width
                            height: reminderText.height + Style.space(4)
                            
                            Row {
                                width: parent.width
                                spacing: Style.space(8)
                                
                                Text {
                                    text: "·"
                                    color: root.barForeground
                                    font.family: "monospace"
                                    font.pixelSize: Style.font.body
                                }
                                
                                Text {
                                    id: reminderText
                                    text: modelData.text
                                    color: root.barForeground
                                    font.family: "monospace"
                                    font.pixelSize: Style.font.body
                                    width: parent.width - 80
                                    wrapMode: Text.WordWrap
                                }
                                
                                Text {
                                    text: "[x]"
                                    color: root.barForeground
                                    opacity: doneArea.containsMouse ? 1.0 : 0.5
                                    font.family: "monospace"
                                    font.pixelSize: Style.font.body
                                    
                                    MouseArea {
                                        id: doneArea
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
                        spacing: 0
                        clip: true
                        
                        model: root.hostWidget ? root.hostWidget.doneReminders : []
                        
                        delegate: Item {
                            width: ListView.view.width
                            height: reminderText.height + Style.space(4)
                            
                            Row {
                                width: parent.width
                                spacing: Style.space(8)
                                
                                Text {
                                    text: "✓"
                                    color: root.barForeground
                                    opacity: 0.5
                                    font.family: "monospace"
                                    font.pixelSize: Style.font.body
                                }
                                
                                Text {
                                    id: reminderText
                                    text: modelData.text
                                    color: root.barForeground
                                    opacity: 0.5
                                    font.family: "monospace"
                                    font.pixelSize: Style.font.body
                                    font.strikeout: true
                                    width: parent.width - 100
                                    wrapMode: Text.WordWrap
                                }
                                
                                Text {
                                    text: "[del]"
                                    color: root.barForeground
                                    opacity: deleteArea.containsMouse ? 1.0 : 0.4
                                    font.family: "monospace"
                                    font.pixelSize: Style.font.body
                                    
                                    MouseArea {
                                        id: deleteArea
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
