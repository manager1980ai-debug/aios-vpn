import QtQuick
import QtQuick.Layouts
RowLayout {
 spacing: 8
 Image { source: "qrc:/images/aios_logo.png"; sourceClipRect: Qt.rect(0,120,640,400); Layout.preferredWidth: 43; Layout.preferredHeight: 33; fillMode: Image.PreserveAspectFit }
 ColumnLayout {
  spacing: 0
  Text { text: "AIOS"; color: "#F4D69C"; font.pixelSize: 22; font.letterSpacing: 4 }
  Text { text: "VPN"; color: "#E9BE76"; font.pixelSize: 9; font.letterSpacing: 5; Layout.alignment: Qt.AlignHCenter }
 }
}
