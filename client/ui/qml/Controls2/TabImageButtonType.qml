import QtQuick
import QtQuick.Controls

import Style 1.0
import "../Components"

TabButton {
    id: root

    property string hoveredColor: AmneziaStyle.color.richBrown
    property string defaultColor: AmneziaStyle.color.paleGray
    property string selectedColor: AmneziaStyle.color.goldenApricot

    property string image
    property string iconName: "home"

    property bool isSelected: false

	property bool isFocusable: true

    Keys.onTabPressed: {
        FocusController.nextKeyTabItem()
    }

    Keys.onBacktabPressed: {
        FocusController.previousKeyTabItem()
    }

    Keys.onUpPressed: {
        FocusController.nextKeyUpItem()
    }
    
    Keys.onDownPressed: {
        FocusController.nextKeyDownItem()
    }
    
    Keys.onLeftPressed: {
        FocusController.nextKeyLeftItem()
    }

    Keys.onRightPressed: {
        FocusController.nextKeyRightItem()
    }
    
    property string borderFocusedColor: AmneziaStyle.color.paleGray
    property int borderFocusedWidth: 1

    property var clickedFunc

    hoverEnabled: true

    display: AbstractButton.TextUnderIcon
    font.pixelSize: 10
    palette.buttonText: isSelected ? "#F4CC87" : "#8794A5"
    icon.width: 22
    icon.height: 22
    spacing: 5
    icon.source: image
    icon.color: isSelected ? selectedColor : defaultColor

    contentItem: Column {
        spacing: 5
        anchors.fill: parent
        anchors.topMargin: 6
        anchors.bottomMargin: 4
        AiosIcon {
            name: root.iconName
            width: 22
            height: 22
            anchors.horizontalCenter: parent.horizontalCenter
            tint: root.isSelected ? root.selectedColor : root.defaultColor
        }
        Text {
            width: parent.width
            text: root.text
            color: root.isSelected ? "#F4CC87" : "#D6DEE8"
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: AmneziaStyle.color.transparent
        radius: 10

        border.color: root.activeFocus ? root.borderFocusedColor : AmneziaStyle.color.transparent
        border.width: root.activeFocus ? root.borderFocusedWidth : 0

    }

    MouseArea {
        anchors.fill: background
        cursorShape: Qt.PointingHandCursor
        enabled: false
    }
    
    Keys.onEnterPressed: {
        if (root.clickedFunc && typeof root.clickedFunc === "function") {
            root.clickedFunc()
        }
    }

    Keys.onReturnPressed: {
        if (root.clickedFunc && typeof root.clickedFunc === "function") {
            root.clickedFunc()
        }
    }

    onClicked: {
        if (root.clickedFunc && typeof root.clickedFunc === "function") {
            root.clickedFunc()
        }
    }
}
