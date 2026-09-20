import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Button {
 id: root
 property string subtitle: ""
 property string symbol: "server"
 property bool arrow: true
 implicitHeight: 74; padding: 16
 background: Rectangle {
  radius: 16; border.color: root.activeFocus ? "#E9BE76" : "#283136"
  gradient: Gradient {
   GradientStop { position: 0; color: root.down ? "#243039" : "#111B20" }
   GradientStop { position: 1; color: "#090E11" }
  }
 }
 contentItem: RowLayout {
  spacing: 13
  Rectangle {
   Layout.preferredWidth: 36; Layout.preferredHeight: 36; color: "#182024"; radius: 12; border.color: "#3A3730"
   AiosIcon { anchors.centerIn: parent; name: root.symbol; width: 21; height: 21 }
  }
  ColumnLayout {
   Layout.fillWidth: true; spacing: 4
   Text { Layout.fillWidth: true; text: root.text; color: "#F3F4F6"; font.pixelSize: 14; font.weight: Font.Medium; elide: Text.ElideRight }
   Text { Layout.fillWidth: true; visible: text.length > 0; text: root.subtitle; color: "#A4AEBE"; font.pixelSize: 11; wrapMode: Text.WordWrap }
  }
  AiosIcon { visible: root.arrow; name: "chevron-right"; tint: "#A4AEBE"; Layout.preferredWidth: 15; Layout.preferredHeight: 15 }
 }
}
