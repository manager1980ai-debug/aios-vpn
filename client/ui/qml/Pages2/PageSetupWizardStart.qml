import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PageEnum 1.0
import "../Controls2"
import "../Components"
PageType {
 id: root
 Rectangle { anchors.fill: parent; color: "#05090C" }
 ScrollView {
  anchors.fill: parent; contentWidth: availableWidth; clip: true
  ColumnLayout {
   width: root.width; spacing: 0
   Image {
    source: "qrc:/images/aios_logo.png"; sourceClipRect: Qt.rect(0,120,640,400); fillMode: Image.PreserveAspectFit
    Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 102; Layout.preferredHeight: 78; Layout.topMargin: 22 + PageController.safeAreaTopMargin
   }
   Text { text: "AIOS"; color: "#F2CC86"; font.pixelSize: 42; font.letterSpacing: 9; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 12 }
   Text { text: "VPN"; color: "#E9BE76"; font.pixelSize: 18; font.letterSpacing: 9; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 3 }
   Text {
    text: qsTr("Свобода в каждом\nсоединении"); color: "#F5DFB4"; font.pixelSize: 23; horizontalAlignment: Text.AlignHCenter
    Layout.fillWidth: true; Layout.topMargin: 22; Layout.leftMargin: 16; Layout.rightMargin: 16
   }
   Text { text: qsTr("Быстрый  •  Безопасный  •  Без границ"); color: "#A4AEBE"; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 12 }
   Item {
    Layout.fillWidth: true; Layout.preferredHeight: Math.min(root.width * 0.55, 260); Layout.topMargin: 14
    Image { anchors.fill: parent; source: "qrc:/images/aios_planet.jpg"; fillMode: Image.PreserveAspectCrop }
    Rectangle {
     anchors.fill: parent
     gradient: Gradient {
      GradientStop { position: 0; color: "#05090C" }
      GradientStop { position: 0.15; color: "transparent" }
      GradientStop { position: 0.72; color: "transparent" }
      GradientStop { position: 1; color: "#05090C" }
     }
    }
   }
   AiosGoldButton {
    objectName: "startButton"; text: qsTr("Начать")
    Layout.fillWidth: true; Layout.leftMargin: 38; Layout.rightMargin: 38; Layout.topMargin: 18; Layout.bottomMargin: 18 + PageController.safeAreaBottomMargin
    onClicked: PageController.goToPage(PageEnum.PageSetupWizardConfigSource)
   }
  }
 }
}
