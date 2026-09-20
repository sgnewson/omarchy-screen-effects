import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import "Effects.js" as Effects

BarWidget {
  id: root
  moduleName: "scott.screen-effects"

  property string currentEffect: "off"
  property bool popupOpen: false

  readonly property var catalog: Effects.catalog
  readonly property bool effectOn: currentEffect !== "off"
  readonly property string currentIcon: effectOn ? Effects.iconFor(currentEffect) : "󰐾"
  readonly property string currentLabel: Effects.labelFor(currentEffect)

  function pluginFile(name) {
    return String(Qt.resolvedUrl(name)).replace(/^file:\/\//, "")
  }

  function close() {
    popupOpen = false
  }

  function togglePopup() {
    popupOpen = !popupOpen
  }

  function refreshCurrent() {
    currentFile.reload()
  }

  function applyCurrent() {
    runEffect("apply")
  }

  function choose(id) {
    var next = Effects.parseCurrent(id)
    if (next === currentEffect && next !== "off") next = "off"
    currentEffect = next
    runEffect(next)
    close()
  }

  function runEffect(arg) {
    if (applyProc.running) applyProc.running = false
    applyProc.command = ["bash", pluginFile("hypr-screen-effect"), arg]
    applyProc.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  FileView {
    id: currentFile
    path: Quickshell.env("HOME") + "/.config/hypr/shaders/current"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.currentEffect = Effects.parseCurrent(text())
    onLoadFailed: root.currentEffect = "off"
  }

  Process {
    id: applyProc
    onExited: root.refreshCurrent()
  }

  Component.onCompleted: {
    currentFile.reload()
    Qt.callLater(root.applyCurrent)
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.currentIcon
    active: root.effectOn
    slotSize: Style.bar.statusSlot
    tooltipText: root.effectOn ? ("Effects: " + root.currentLabel) : "Screen effects"
    onPressed: function(b) {
      if (b === Qt.MiddleButton || b === Qt.RightButton) root.choose("off")
      else root.togglePopup()
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(220))
    contentHeight: popup.fittedContentHeight(list.implicitHeight)

    Column {
      id: list
      width: parent.width
      spacing: Style.space(2)

      Repeater {
        model: root.catalog

        BorderSurface {
          id: row
          required property var modelData

          readonly property string effectId: modelData.id
          readonly property bool selected: root.currentEffect === effectId
          readonly property bool isOff: effectId === "off"

          width: list.width
          height: inner.implicitHeight + Style.space(10)
          radius: Style.spacing.labelGap
          color: selected ? Style.selectedFillFor(root.bar.foreground, Color.accent) : "transparent"
          borderSpec: selected ? Border.controlSpec("normal", root.bar.foreground, Color.accent) : Border.none()

          Row {
            id: inner
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: row.borderLeft + Style.space(8)
            anchors.rightMargin: row.borderRight + Style.space(8)
            spacing: Style.space(10)

            Text {
              textFormat: Text.PlainText
              text: row.modelData.icon
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              width: Style.space(18)
              horizontalAlignment: Text.AlignHCenter
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              textFormat: Text.PlainText
              text: row.modelData.label
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: row.selected
              elide: Text.ElideRight
              width: parent.width - Style.space(28)
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.choose(row.effectId)
          }
        }
      }
    }
  }
}
