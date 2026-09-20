import QtQuick
import QtQuick.Controls
Item {
 id: root
 property string name: "lock"
 property color tint: "#E9BE76"
 implicitWidth: 24; implicitHeight: 24
 Button {
  anchors.fill: parent; enabled: false; padding: 0
  icon.source: "qrc:/images/controls/" + root.name + ".svg"
  icon.color: root.tint; icon.width: root.width; icon.height: root.height
  display: AbstractButton.IconOnly
  background: Item {}
  Accessible.ignored: true
 }
}
