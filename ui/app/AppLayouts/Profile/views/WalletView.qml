import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import "../controls"
import "../popups"
import "../panels"
import "./wallet"

SettingsContentBase {
    id: root

    property var emojiPopup
    property var rootStore
    property var walletStore

    readonly property int mainViewIndex: 0;
    readonly property int networksViewIndex: 1;
    readonly property int editNetworksViewIndex: 2;
    readonly property int accountOrderViewIndex: 3;
    readonly property int accountViewIndex: 4;

    Component.onCompleted: {
        root.titleRowComponentLoader.sourceComponent = addNewAccountButtonComponent
    }

    function resetStack() {
        if(stackContainer.currentIndex === root.editNetworksViewIndex) {
            stackContainer.currentIndex = root.networksViewIndex
        }
        else {
            stackContainer.currentIndex = mainViewIndex;
        }
    }

    StackLayout {
        id: stackContainer

        width: root.contentWidth
        height: stackContainer.currentIndex === root.mainViewIndex ? main.height:
                stackContainer.currentIndex === root.networksViewIndex ? networksView.height:
                stackContainer.currentIndex === root.editNetworksViewIndex ? editNetwork.height:
                stackContainer.currentIndex === root.accountOrderViewIndex ? accountOrderView.height: accountView.height
        currentIndex: mainViewIndex

        onCurrentIndexChanged: {
            root.rootStore.backButtonName = ""
            root.sectionTitle = qsTr("Wallet")
            root.titleRowComponentLoader.sourceComponent = undefined
            root.titleRowLeftComponentLoader.sourceComponent = undefined
            root.titleRowLeftComponentLoader.visible = false
            root.titleLayout.spacing = 5

            if (currentIndex == root.mainViewIndex) {
                root.titleRowComponentLoader.sourceComponent = addNewAccountButtonComponent
            }

            if(currentIndex == root.networksViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = qsTr("Networks")
            }
            if(currentIndex == root.editNetworksViewIndex) {
                root.rootStore.backButtonName = qsTr("Networks")
                root.sectionTitle = qsTr("Edit %1").arg(!!editNetwork.combinedNetwork.prod && !!editNetwork.combinedNetwork.prod.chainName ? editNetwork.combinedNetwork.prod.chainName: "")
                root.titleRowLeftComponentLoader.visible = true
                root.titleRowLeftComponentLoader.sourceComponent = networkIcon
                root.titleLayout.spacing = 12
            }
            else if(currentIndex == root.accountViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = ""
            }
            else if(currentIndex == root.accountOrderViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = qsTr("Edit account order")
            }
        }

        MainView {
            id: main

            Layout.fillWidth: true
            Layout.fillHeight: false

            walletStore: root.walletStore
            emojiPopup: root.emojiPopup

            onGoToNetworksView: {
                stackContainer.currentIndex = networksViewIndex
            }

            onGoToAccountView: {
                root.walletStore.selectedAccount = account
                accountView.keyPair = keypair
                stackContainer.currentIndex = accountViewIndex
            }

            onGoToAccountOrderView: {
                stackContainer.currentIndex = accountOrderViewIndex
            }
            onRunRenameKeypairFlow: {
                renameKeypairPopup.keyUid = model.keyPair.keyUid
                renameKeypairPopup.name = model.keyPair.name
                renameKeypairPopup.accounts = model.keyPair.accounts
                renameKeypairPopup.active = true
            }
            onRunRemoveKeypairFlow: {
                removeKeypairPopup.keyUid = model.keyPair.keyUid
                removeKeypairPopup.name = model.keyPair.name
                removeKeypairPopup.active = true
            }
        }

        NetworksView {
            id: networksView
            Layout.fillWidth: true
            Layout.fillHeight: false

            walletStore: root.walletStore

            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }

            onEditNetwork: {
                editNetwork.combinedNetwork = network
                stackContainer.currentIndex = editNetworksViewIndex
            }
        }

        EditNetworkView {
            id: editNetwork
            Layout.fillHeight: true
            Layout.fillWidth: true
            networksModule: root.walletStore.networksModule
            onEvaluateRpcEndPoint: root.walletStore.evaluateRpcEndPoint(url)
            onUpdateNetworkValues: root.walletStore.updateNetworkValues(chainId, newMainRpcInput, newFailoverRpcUrl)
        }

        AccountOrderView {
            id: accountOrderView
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            walletStore: root.walletStore
            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }
        }

        AccountView {
            id: accountView
            account: root.walletStore.selectedAccount
            walletStore: root.walletStore
            emojiPopup: root.emojiPopup
            userProfilePublicKey: walletStore.userProfilePublicKey
            onGoBack: stackContainer.currentIndex = mainViewIndex
            onVisibleChanged: if(!visible) root.walletStore.selectedAccount = null
            onRunRenameKeypairFlow: {
                renameKeypairPopup.keyUid = keyPair.keyUid
                renameKeypairPopup.name = keyPair.name
                renameKeypairPopup.accounts = keyPair.accounts
                renameKeypairPopup.active = true
            }
            onRunRemoveKeypairFlow: {
                removeKeypairPopup.keyUid = keyPair.keyUid
                removeKeypairPopup.name = keyPair.name
                removeKeypairPopup.active = true
            }
        }

        DappPermissionsView {
            walletStore: root.walletStore
        }

        Component {
            id: addNewAccountButtonComponent
            StatusButton {
                objectName: "settings_Wallet_MainView_AddNewAccountButton"
                text: qsTr("Add new account")
                onClicked: root.walletStore.runAddAccountPopup()
            }
        }

        Component {
            id: networkIcon
            StatusRoundedImage {
                width: 28
                height: 28
                image.source: Style.svg(!!editNetwork.combinedNetwork.prod && !!editNetwork.combinedNetwork.prod.iconUrl ? editNetwork.combinedNetwork.prod.iconUrl: "")
                image.fillMode: Image.PreserveAspectCrop
            }
        }

        Loader {
            id: renameKeypairPopup
            active: false

            property string keyUid
            property string name
            property var accounts

            sourceComponent: RenameKeypairPopup {
                accountsModule: root.walletStore.accountsModule
                keyUid: renameKeypairPopup.keyUid
                name: renameKeypairPopup.name
                accounts: renameKeypairPopup.accounts

                onClosed: {
                    renameKeypairPopup.active = false
                }
            }

            onLoaded: {
                renameKeypairPopup.item.open()
            }
        }

        Loader {
            id: removeKeypairPopup
            active: false

            property string keyUid
            property string name

            sourceComponent: ConfirmationDialog {
                headerSettings.title: qsTr("Confirm %1 Removal").arg(removeKeypairPopup.name)

                confirmationText: qsTr("You will not be able to restore viewing access to any account of this keypair in the future unless you import this keypair again.")
                confirmButtonLabel: qsTr("Remove keypair")
                onConfirmButtonClicked: {
                    root.walletStore.deleteKeypair(removeKeypairPopup.keyUid)
                    removeKeypairPopup.active = false
                }
            }

            onLoaded: {
                removeKeypairPopup.item.open()
            }
        }
    }
}
