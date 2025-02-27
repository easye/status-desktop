import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Profile.popups 1.0

Rectangle {
    id: root

    property var keyPair
    property var getNetworkShortNames: function(chainIds){}
    property string userProfilePublicKey
    property bool includeWatchOnlyAccount

    signal goToAccountView(var account)
    signal toggleIncludeWatchOnlyAccount()
    signal runRenameKeypairFlow()
    signal runRemoveKeypairFlow()

    QtObject {
        id: d
        readonly property var relatedAccounts: !!root.keyPair? root.keyPair.accounts : {}
        readonly property bool isWatchOnly: !!root.keyPair && root.keyPair.pairType === Constants.keypair.type.watchOnly
        readonly property bool isProfileKeypair: !!root.keyPair && root.keyPair.pairType === Constants.keypair.type.profile
    }

    implicitHeight: layout.height
    color: Theme.palette.baseColor4
    radius: 8

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        StatusListItem {
            Layout.fillWidth: true
            title: !!root.keyPair? d.isWatchOnly ? qsTr("Watched addresses") : root.keyPair.name : ""
            statusListItemSubTitle.textFormat: Qt.RichText
            titleTextIcon: !!root.keyPair && keyPair.migratedToKeycard ? "keycard": ""
            subTitle: Utils.getKeypairLocation(root.keyPair)
            statusListItemSubTitle.color: Utils.getKeypairLocationColor(root.keyPair)
            color: Theme.palette.transparent
            ringSettings {
                ringSpecModel: d.isProfileKeypair ? Utils.getColorHashAsJson(root.userProfilePublicKey) : []
                ringPxSize: Math.max(asset.width / 24.0)
            }
            asset {
                width: !!root.keyPair && keyPair.icon? Style.current.bigPadding : 40
                height: !!root.keyPair && keyPair.icon? Style.current.bigPadding : 40
                name: !!root.keyPair? !!root.keyPair.image? root.keyPair.image : root.keyPair.icon : ""
                isImage: !!root.keyPair && !!keyPair.image
                color: d.isProfileKeypair ? Utils.colorForPubkey(root.userProfilePublicKey) : Theme.palette.primaryColor1
                letterSize: Math.max(4, asset.width / 2.4)
                charactersLen: 2
                isLetterIdenticon: !!root.keyPair && !keyPair.icon && !asset.name.toString()
            }
            components: [
                StatusFlatRoundButton {
                    icon.name: "more"
                    icon.color: Theme.palette.directColor1
                    visible: !d.isWatchOnly
                    highlighted: menuLoader.item && menuLoader.item.opened
                    onClicked: {
                        menuLoader.active = true
                        menuLoader.item.popup(0, height)
                    }

                    Loader {
                        id: menuLoader
                        active: false
                        sourceComponent: WalletKeypairAccountMenu {
                            onClosed: {
                                menuLoader.active = false
                            }
                            keyPair: root.keyPair
                            onRunRenameKeypairFlow: root.runRenameKeypairFlow()
                            onRunRemoveKeypairFlow: root.runRemoveKeypairFlow()
                        }
                    }
                },
                StatusBaseText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Include in total balance")
                    visible: d.isWatchOnly
                },
                StatusSwitch {
                    visible: d.isWatchOnly
                    checked: root.includeWatchOnlyAccount
                    onClicked: root.toggleIncludeWatchOnlyAccount()
                }
            ]
        }
        StatusListView {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 1
            model: d.relatedAccounts
            delegate: WalletAccountDelegate {
                width: ListView.view.width
                account: model.account
                totalCount: ListView.view.count
                getNetworkShortNames: root.getNetworkShortNames
                onGoToAccountView: root.goToAccountView(model.account)
            }
        }
    }
}
