import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    property alias title: titleComponent.text
    property alias text: textComponent.text
    property string icon
    property int iconType: StatusInfoBoxPanel.Type.Info
    property alias buttonText: button.text
    property alias buttonVisible: button.visible

    enum Type {
        Info,
        Danger,
        Success,
        Warning
    }

    signal clicked

    verticalPadding: 40
    horizontalPadding: 56

    QtObject {
        id: d
        property color bgColor
        property color fgColor
    }

    states: [
        State {
            when: root.iconType === StatusInfoBoxPanel.Type.Info
            PropertyChanges { target: d; bgColor: Theme.palette.primaryColor3; fgColor: Theme.palette.primaryColor1 }
        },
        State {
            when: root.iconType === StatusInfoBoxPanel.Type.Danger
            PropertyChanges { target: d; bgColor: Theme.palette.dangerColor3; fgColor: Theme.palette.dangerColor1 }
        },
        State {
            when: root.iconType === StatusInfoBoxPanel.Type.Success
            PropertyChanges { target: d; bgColor: Theme.palette.successColor2; fgColor: Theme.palette.successColor1 }
        },
        State {
            when: root.iconType === StatusInfoBoxPanel.Type.Warning
            PropertyChanges { target: d; bgColor: Theme.palette.warningColor3; fgColor: Theme.palette.warningColor1 }
        }
    ]

    background: Rectangle {
        color: Theme.palette.statusListItem.backgroundColor
        radius: 8
        border.color: Theme.palette.baseColor2
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        StatusRoundIcon {
            id: iconComponent
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignCenter
            Layout.bottomMargin: 12
            visible: !!root.icon
            asset.name: root.icon
            asset.color: d.fgColor
            asset.bgColor: d.bgColor
        }

        StatusBaseText {
            id: titleComponent

            Layout.fillWidth: true

            wrapMode: Text.Wrap
            font.pixelSize: 17
            font.weight: Font.Bold

            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor1
        }

        StatusBaseText {
            id: textComponent

            Layout.fillWidth: true

            wrapMode: Text.Wrap
            font.pixelSize: 15
            lineHeight: 1.2

            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.baseColor1
        }

        StatusButton {
            id: button

            Layout.alignment: Qt.AlignHCenter

            visible: true

            onClicked: root.clicked()
        }
    }
}
