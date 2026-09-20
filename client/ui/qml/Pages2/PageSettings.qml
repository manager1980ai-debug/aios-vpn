import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PageEnum 1.0
import "../Controls2"
import "../Components"
PageType {
 id: root
 Rectangle { anchors.fill: parent; color: "#060B0E" }
 ScrollView {
  anchors.fill: parent; contentWidth: availableWidth; clip: true
  ColumnLayout {
   width: root.width; spacing: 12
   RowLayout {
    Layout.fillWidth: true; Layout.margins: 22; Layout.topMargin: 28 + PageController.safeAreaTopMargin
    Text { text: qsTr("Профиль"); color: "#F3F4F6"; font.pixelSize: 24; font.weight: Font.Medium; Layout.fillWidth: true }
    AiosBrand {}
   }
   Rectangle {
    Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.bottomMargin: 14; implicitHeight: 116; radius: 18
    color: "#10181C"; border.color: "#3A3931"
    RowLayout {
     anchors.fill: parent; anchors.margins: 20; spacing: 16
     Rectangle {
      width: 58; height: 58; radius: 29; color: "#25251F"; border.color: "#BA945B"
      AiosIcon { anchors.centerIn: parent; width: 30; height: 30; name: "lock" }
     }
     ColumnLayout {
      Layout.fillWidth: true; spacing: 7
      Text { Layout.fillWidth: true; text: AiosProfileController.hasProfile && AiosProfileController.owner !== "" ? AiosProfileController.owner : qsTr("Мой AIOS VPN"); color: "#F3F4F6"; font.pixelSize: 17; elide: Text.ElideRight }
      Text { text: qsTr("Личное пространство"); color: "#A4AEBE"; font.pixelSize: 12 }
      Text { text: qsTr("ЛИЧНЫЙ СЕРВЕР"); color: "#E9BE76"; font.pixelSize: 9; font.letterSpacing: 1.5 }
     }
    }
   }
   Repeater {
    model: [{title:qsTr("Мой сервер"),detail:qsTr("Ваше личное подключение"),icon:"server",page:PageEnum.PageSettingsServersList},
     {title:qsTr("Устройства"),detail:qsTr("Управление доступом"),icon:"monitor",page:PageEnum.PageAiosDevices},
     {title:qsTr("Безопасность"),detail:qsTr("VPN и параметры подключения"),icon:"lock",page:PageEnum.PageSettingsConnection},
     {title:qsTr("Настройки"),detail:qsTr("Язык, запуск и поведение приложения"),icon:"settings",page:PageEnum.PageSettingsApplication},
     {title:qsTr("Резервная копия"),detail:qsTr("Сохранение и восстановление ключей"),icon:"save",page:PageEnum.PageSettingsBackup},
     {title:qsTr("О приложении"),detail:"AIOS VPN",icon:"info",page:PageEnum.PageSettingsAbout}]
    AiosAction {
     required property var modelData
     Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22
     text: modelData.title; subtitle: modelData.detail; symbol: modelData.icon
     onClicked: PageController.goToPage(modelData.page)
    }
   }
   Text { Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 16; Layout.bottomMargin: 28; text: qsTr("Свобода в каждом соединении"); color: "#8C795B"; font.pixelSize: 11 }
  }
 }
 Component.onCompleted: AiosProfileController.refresh()
}
