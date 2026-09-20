import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PageEnum 1.0
import "../Controls2"
import "../Components"
PageType {
 id: root
 property real downloadRate: 0
 property real uploadRate: 0
 property real previousReceived: 0
 property real previousSent: 0

 function formatBytes(value) {
  if (value < 1024) return value.toFixed(0) + " B"
  if (value < 1024 * 1024) return (value / 1024).toFixed(1) + " KB"
  if (value < 1024 * 1024 * 1024) return (value / (1024 * 1024)).toFixed(1) + " MB"
  return (value / (1024 * 1024 * 1024)).toFixed(2) + " GB"
 }
 function formatRate(value) { return value < 0.1 ? "0 Мбит/с" : value.toFixed(1) + " Мбит/с" }
 Timer {
  interval: 1000; repeat: true; running: true
  onTriggered: {
   var rx = ConnectionController.receivedBytes
   var tx = ConnectionController.sentBytes
   root.downloadRate = Math.max(0, (rx - root.previousReceived) * 8 / 1000000)
   root.uploadRate = Math.max(0, (tx - root.previousSent) * 8 / 1000000)
   root.previousReceived = rx
   root.previousSent = tx
  }
 }
 Rectangle { anchors.fill: parent; color: "#060B0E" }
 ScrollView {
  anchors.fill: parent; contentWidth: availableWidth; clip: true
  ColumnLayout {
   width: root.width; spacing: 18
   RowLayout {
    Layout.fillWidth: true; Layout.margins: 22; Layout.topMargin: 22 + PageController.safeAreaTopMargin
    AiosBrand {}
    Item { Layout.fillWidth: true }
    Button { flat: true; Accessible.name: qsTr("Открыть профиль"); contentItem: AiosIcon { name: "settings-2" } onClicked: PageController.goToPageSettings() }
   }
   Rectangle {
    Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; implicitHeight: 66; radius: 16
    color: ConnectionController.isConnected ? "#0A2418" : "#111A1F"; border.color: ConnectionController.isConnected ? "#236440" : "#273136"
    RowLayout {
     anchors.fill: parent; anchors.margins: 14; spacing: 12
     AiosIcon { name: ConnectionController.isConnected ? "check-circle" : "lock"; tint: ConnectionController.isConnected ? "#69E996" : "#E9BE76" }
     ColumnLayout {
      Layout.fillWidth: true; spacing: 4
      Text { text: ConnectionController.isConnectionInProgress ? qsTr("Подключаемся…") : ConnectionController.isConnected ? qsTr("Подключено") : qsTr("Вы не подключены"); color: "#F4F5F7"; font.pixelSize: 15; font.weight: Font.Medium }
      Text { text: ConnectionController.isConnected ? qsTr("Ваше соединение защищено") : qsTr("Ваше соединение не защищено"); color: "#A4AEBE"; font.pixelSize: 11 }
     }
    }
   }
   ConnectButton { Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 25; Layout.bottomMargin: 4 }
   Text { Layout.alignment: Qt.AlignHCenter; text: ConnectionController.isConnectionInProgress ? ConnectionController.connectionStateText : ConnectionController.isConnected ? qsTr("Нажмите, чтобы отключиться") : qsTr("Нажмите для подключения"); color: "#A4AEBE"; font.pixelSize: 12 }
   AiosAction {
    Layout.fillWidth: true; Layout.margins: 22; Layout.topMargin: 12; Layout.bottomMargin: 0
    text: qsTr("Мой сервер"); subtitle: ServersUiController.defaultServerName || qsTr("Добавьте ключ подключения"); symbol: "server"
    onClicked: PageController.goToPage(PageEnum.PageSettingsServersList)
   }
   Rectangle {
    Layout.fillWidth: true; Layout.margins: 22; Layout.topMargin: 0; implicitHeight: 86; radius: 16
    color: "#0E171C"; border.color: "#283136"
    ColumnLayout {
     anchors.fill: parent; anchors.margins: 14; spacing: 8
     Text { text: qsTr("Статистика соединения"); color: "#F0D49A"; font.pixelSize: 12; font.weight: Font.Medium }
     RowLayout {
      Layout.fillWidth: true; spacing: 8
      Text { Layout.fillWidth: true; text: qsTr("Загрузка") + "  " + root.formatRate(root.downloadRate) + "\n" + qsTr("Получено") + "  " + root.formatBytes(ConnectionController.receivedBytes); color: "#B9C4D2"; font.pixelSize: 10 }
      Text { Layout.fillWidth: true; text: qsTr("Отдача") + "  " + root.formatRate(root.uploadRate) + "\n" + qsTr("Отправлено") + "  " + root.formatBytes(ConnectionController.sentBytes); color: "#B9C4D2"; font.pixelSize: 10; horizontalAlignment: Text.AlignRight }
     }
    }
   }
   GridLayout {
    Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; columns: 2; columnSpacing: 12; rowSpacing: 12
    Repeater {
     model: [{ title: qsTr("Быстрый доступ"), icon: "gauge", page: PageEnum.PageSettingsServersList }, { title: qsTr("Безопасность данных"), icon: "lock", page: PageEnum.PageSettingsConnection }, { title: qsTr("Раздельное туннелирование"), icon: "globe-2", page: PageEnum.PageSettingsSplitTunneling }, { title: qsTr("Настройки подключения"), icon: "radio", page: PageEnum.PageSettingsConnection }]
     Button {
      required property var modelData
      Layout.fillWidth: true; Layout.preferredWidth: 1; implicitHeight: 98; padding: 16
      background: Rectangle { color: parent.down ? "#1A252B" : "#0E171C"; radius: 16; border.color: parent.activeFocus ? "#E9BE76" : "#283136" }
      contentItem: ColumnLayout {
       spacing: 9
       AiosIcon { name: modelData.icon; width: 22; height: 22 }
       Text { Layout.fillWidth: true; text: modelData.title; color: "#DDE2EB"; font.pixelSize: 12; wrapMode: Text.WordWrap }
      }
      onClicked: PageController.goToPage(modelData.page)
     }
    }
   }
   Text { Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 24; text: qsTr("Личный VPN · Один надёжный сервер"); color: "#72818D"; font.pixelSize: 11 }
  }
 }
}
