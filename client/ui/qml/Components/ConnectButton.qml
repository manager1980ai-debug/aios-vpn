import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
Button {
 id: root
 property bool isFocusable: true
 readonly property color ringColor: ConnectionController.isConnected ? "#5CE68A" : "#F4CC87"
 implicitWidth: 190; implicitHeight: 190
 Accessible.name: ConnectionController.isConnected ? qsTr("Отключить VPN") : qsTr("Подключить VPN")
 background: Item {
  Rectangle { id: halo; anchors.fill: parent; radius: width / 2; color: ConnectionController.isConnected ? "#0D241A" : "#272015"; border.color: root.ringColor; opacity: 0.7 }
  Glow { anchors.fill: halo; source: halo; radius: 22; samples: 45; color: root.ringColor; opacity: 0.22 }
  Rectangle {
   anchors.fill: parent; anchors.margins: 12; radius: width / 2
   border.width: root.activeFocus ? 4 : 3; border.color: root.ringColor
   gradient: Gradient {
    GradientStop { position: 0; color: ConnectionController.isConnected ? "#143524" : "#342B1E" }
    GradientStop { position: 0.5; color: "#080E10" }
    GradientStop { position: 1; color: "#0C1517" }
   }
   scale: root.down ? 0.96 : 1
   Behavior on scale { NumberAnimation { duration: 120 } }
  }
  Shape {
   anchors.fill: parent; visible: ConnectionController.isConnectionInProgress
   ShapePath {
    fillColor: "transparent"; strokeColor: "#FFEDCA"; strokeWidth: 4; capStyle: ShapePath.RoundCap
    PathAngleArc { centerX: root.width / 2; centerY: root.height / 2; radiusX: root.width / 2 - 4; radiusY: root.height / 2 - 4; startAngle: 0; sweepAngle: 85 }
   }
   RotationAnimator on rotation { from: 0; to: 360; duration: 1300; loops: Animation.Infinite; running: ConnectionController.isConnectionInProgress }
  }
 }
 contentItem: Item {
  Shape {
   anchors.centerIn: parent; width: 42; height: 42
   ShapePath { strokeColor: root.ringColor; strokeWidth: 3; fillColor: "transparent"; capStyle: ShapePath.RoundCap; PathAngleArc { centerX: 21; centerY: 23; radiusX: 16; radiusY: 16; startAngle: -55; sweepAngle: 290 } }
   ShapePath { strokeColor: root.ringColor; strokeWidth: 3; capStyle: ShapePath.RoundCap; startX: 21; startY: 3; PathLine { x: 21; y: 22 } }
  }
 }
 Connections { target: ConnectionController; function onPreparingConfig() { PageController.showNotificationMessage(qsTr("Подготавливаем подключение…")) } }
 onClicked: ConnectionController.connectButtonClicked()
 Keys.onReturnPressed: clicked()
 Keys.onEnterPressed: clicked()
}
