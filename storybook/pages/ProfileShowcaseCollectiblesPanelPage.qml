import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Popups {
        popupParent: root
        rootStore: QtObject {}
    }

    ListModel {
        id: collectiblesModel
        readonly property var data: [
            {
                uid: "123",
                name: "SNT",
                collectionName: "Super Nitro Toluen (with pink bg)",
                backgroundColor: "pink",
                imageUrl: ModelsData.collectibles.custom,
                isLoading: false
            },
            {
                uid: "34545656768",
                name: "Kitty 1",
                collectionName: "Kitties",
                backgroundColor: "",
                imageUrl: ModelsData.collectibles.kitty1Big,
                isLoading: false
            },
            {
                uid: "123456",
                name: "Kitty 2",
                collectionName: "",
                backgroundColor: "",
                imageUrl: ModelsData.collectibles.kitty2Big,
                isLoading: false
            },
            {
                uid: "12345645459537432",
                name: "",
                collectionName: "Super Kitties",
                backgroundColor: "oink",
                imageUrl: ModelsData.collectibles.kitty3Big,
                isLoading: false
            },
            {
                uid: "691",
                name: "KILLABEAR",
                collectionName: "KILLABEARS",
                backgroundColor: "#807c56",
                imageUrl: "https://assets.killabears.com/content/killabears/img/691-e81f892696a8ae700e0dbc62eb072060679a2046d1ef5eb2671bdb1fad1f68e3.png",
                isLoading: true
            },
            {
                uid: "8876",
                name: "AIORBIT",
                description: "",
                collectionName: "AIORBIT (Animated SVG)",
                backgroundColor: "",
                imageUrl: "https://dl.openseauserdata.com/cache/originImage/files/8b14ef530b28853445c27d6693c4e805.svg",
                isLoading: false
            }
        ]
        Component.onCompleted: append(data)
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        ProfileShowcaseCollectiblesPanel {
            id: showcasePanel
            width: 500
            baseModel: collectiblesModel
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Button {
            text: "Reset (clear settings)"
            onClicked: showcasePanel.settings.reset()
        }
    }
}

// category: Panels
