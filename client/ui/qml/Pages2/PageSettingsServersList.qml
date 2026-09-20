import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PageEnum 1.0
import "../Controls2"
import "../Components"
PageType {
 id: root
 readonly property bool hasServer: ServersUiController.defaultServerId !== ""
 function openServer() {
  if (!hasServer) { PageController.goToPage(PageEnum.PageSetupWizardConfigSource); return }
  ServersUiController.setProcessedServerId(ServersUiController.defaultServerId)
  if (ServersUiController.isDefaultServerFromApi) {
   PageController.showBusyIndicator(true)
   var ok = SubscriptionUiController.getAccountInfo(ServersUiController.defaultServerId, false)
   PageController.showBusyIndicator(false)
   if (ok) PageController.goToPage(PageEnum.PageSettingsApiServerInfo)
  } else PageController.goToPage(PageEnum.PageSettingsServerInfo)
 }
 Rectangle { anchors.fill: parent; color: "#060B0E" }
 ScrollView {
  anchors.fill: parent; contentWidth: availableWidth; clip: true
  ColumnLayout {
   width: root.width; spacing: 16
   Text { text: qsTr("Мой сервер"); color: "#F3F4F6"; font.pixelSize: 24; font.weight: Font.Medium; Layout.margins: 22; Layout.topMargin: 28 + PageController.safeAreaTopMargin }
   AiosAction {
    Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22
    text: root.hasServer ? (ServersUiController.defaultServerName || qsTr("Личный сервер")) : qsTr("Добавить мой сервер")
    subtitle: root.hasServer ? (ConnectionController.isConnected ? qsTr("Подключено · соединение защищено") : qsTr("Готов к подключению")) : qsTr("Импортируйте ваш ключ или конфигурацию")
    symbol: "server"; onClicked: root.openServer()
   }
   Rectangle {
    Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.preferredHeight: serverNotes.implicitHeight + 40
    radius: 16; color: "#0E171C"; border.color: "#283136"
    ColumnLayout {
     id: serverNotes; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 14
     AiosIcon { name: "lock" }
     Text { text: qsTr("Только ваш сервер"); color: "#F2D49C"; font.pixelSize: 18 }
     Text { Layout.fillWidth: true; text: qsTr("Личное подключение без выбора стран. Ключ хранится на вашем устройстве и используется для подключения к вашему VPN."); color: "#A4AEBE"; font.pixelSize: 13; wrapMode: Text.WordWrap; lineHeight: 1.35 }
    }
   }
   AiosGoldButton {
    Layout.fillWidth: true; Layout.margins: 22; text: root.hasServer ? qsTr("Настроить сервер") : qsTr("Добавить ключ")
    onClicked: root.openServer()
   }
  }
 }
}
