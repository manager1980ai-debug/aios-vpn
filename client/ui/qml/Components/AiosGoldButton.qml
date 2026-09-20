import QtQuick
import QtQuick.Controls
Button {
 id: root
 implicitHeight: 52; padding: 12
 background: Rectangle {
  radius: height / 2; border.width: root.activeFocus ? 3 : 1; border.color: "#FFE3A9"
  gradient: Gradient {
   GradientStop { position: 0; color: root.down ? "#B18137" : "#FFE1A0" }
   GradientStop { position: 0.45; color: "#D5A151" }
   GradientStop { position: 0.85; color: "#BF873C" }
   GradientStop { position: 1; color: "#EAC27D" }
  }
 }
 contentItem: Text { text: root.text; color: "#13110C"; font.pixelSize: 18; font.weight: Font.Medium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
}
