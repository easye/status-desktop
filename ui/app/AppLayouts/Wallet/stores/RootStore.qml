pragma Singleton

import QtQuick 2.13

import utils 1.0
import SortFilterProxyModel 0.2
import StatusQ.Core.Theme 0.1

QtObject {
    id: root

    readonly property string defaultSelectedKeyUid: userProfile.keyUid
    readonly property bool defaultSelectedKeyUidMigratedToKeycard: userProfile.isKeycardUser

    property string backButtonName: ""
    property var overview: walletSectionOverview
    property var assets: walletSectionAssets.assets
    property bool assetsLoading: walletSectionAssets.assetsLoading
    property var accounts: walletSectionAccounts.accounts
    property var receiveAccounts: walletSectionSend.accounts
    property var selectedReceiveAccount: walletSectionSend.selectedReceiveAccount
    property var appSettings: localAppSettings
    property var accountSensitiveSettings: localAccountSensitiveSettings
    property bool hideSignPhraseModal: accountSensitiveSettings.hideSignPhraseModal

    property var walletSectionInst: walletSection
    property var totalCurrencyBalance: walletSection.totalCurrencyBalance
    property var activityController: walletSection.activityController
    property var tmpActivityController: walletSection.tmpActivityController
    property string signingPhrase: walletSection.signingPhrase
    property string mnemonicBackedUp: walletSection.isMnemonicBackedUp

    property CollectiblesStore collectiblesStore: CollectiblesStore {}

    property var areTestNetworksEnabled: networksModule.areTestNetworksEnabled

    property var savedAddresses: SortFilterProxyModel {
        sourceModel: walletSectionSavedAddresses.model
        filters: [
            ValueFilter {
                roleName: "isTest"
                value: networksModule.areTestNetworksEnabled
            }
        ]
    }

    readonly property var currentActivityFiltersStore: {
        const address = root.overview.mixedcaseAddress
        if (address in d.activityFiltersStoreDictionary) {
            return d.activityFiltersStoreDictionary[address]
        }
        let store = d.activityFilterStoreComponent.createObject(root)
        d.activityFiltersStoreDictionary[address] = store
        return store
    }

    property QtObject _d: QtObject {
        id: d

        property var activityFiltersStoreDictionary: ({})
        readonly property Component activityFilterStoreComponent: ActivityFiltersStore{}

        property var chainColors: ({})

        function initChainColors(model) {
            for (let i = 0; i < model.count; i++) {
                chainColors[model.rowData(i, "shortName")] = model.rowData(i, "chainColor")
            }
        }

        readonly property Connections walletSectionConnections: Connections {
            target: root.walletSectionInst
            function onWalletAccountRemoved(address) {
                address = address.toLowerCase();
                for (var addressKey in d.activityFiltersStoreDictionary){
                    if (address === addressKey.toLowerCase()){
                        delete d.activityFiltersStoreDictionary[addressKey]
                        return
                    }
                }
            }
        }
    }

    function colorForChainShortName(chainShortName) {
        return d.chainColors[chainShortName]
    }

    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all
    onAllNetworksChanged: {
        d.initChainColors(allNetworks)
    }

    property var cryptoRampServicesModel: walletSectionBuySellCrypto.model

    // This should be exposed to the UI via "walletModule", WalletModule should use
    // Accounts Service which keeps the info about that (isFirstTimeAccountLogin).
    // Then in the View of WalletModule we may have either QtProperty or
    // Q_INVOKABLE function (proc marked as slot) depends on logic/need.
    // The only need for onboardingModel here is actually to check if an account
    // has been just created or an old one.

    //property bool firstTimeLogin: onboardingModel.isFirstTimeLogin

    // example wallet model
    property ListModel exampleWalletModel: ListModel {
        ListElement {
            name: "Status account"
            address: "0xcfc9f08bbcbcb80760e8cb9a3c1232d19662fc6f"
            balance: "12.00 USD"
            color: "#7CDA00"
        }

        ListElement {
            name: "Test account 1"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            color: "#FA6565"
        }
        ListElement {
            name: "Status account"
            address: "0x2Ef1...E0Ba"
            balance: "12.00 USD"
            color: "#7CDA00"
        }
    }

    property ListModel exampleAssetModel: ListModel {
        ListElement {
            name: "Ethereum"
            symbol: "ETH"
            balance: "3423 ETH"
            address: "token-icons/eth"
            currencyBalance: "123 USD"
        }
    }

    function setHideSignPhraseModal(value) {
        localAccountSensitiveSettings.hideSignPhraseModal = value;
    }

    function getLatestBlockNumber(chainId) {
        return walletSection.getLatestBlockNumber(chainId)
    }

    function setFilterAddress(address) {
        walletSection.setFilterAddress(address)
    }

    function setFillterAllAddresses() {
        walletSection.setFillterAllAddresses()
    }

    function deleteAccount(address) {
        return walletSectionAccounts.deleteAccount(address)
    }

    function updateCurrentAccount(address, accountName, colorId, emoji) {
        return walletSectionAccounts.updateAccount(address, accountName, colorId, emoji)
    }

    function updateCurrency(newCurrency) {
        walletSection.updateCurrency(newCurrency)
    }

    function getQrCode(address) {
        return globalUtils.qrCode(address)
    }

    function hex2Dec(value) {
        return globalUtils.hex2Dec(value)
    }

    function getNameForSavedWalletAddress(address) {
        return walletSectionSavedAddresses.getNameByAddress(address)
    }

    function getNameForWalletAddress(address) {
        return walletSectionAccounts.getNameByAddress(address)
    }

    function getNameForAddress(address) {
        var name = getNameForWalletAddress(address)
        if (name.length === 0) {
            name = getNameForSavedWalletAddress(address)
        }
        return name
    }

    function isOwnedAccount(address) {
        return walletSectionAccounts.isOwnedAccount(address)
    }

    function getEmojiForWalletAddress(address) {
        return walletSectionAccounts.getEmojiByAddress(address)
    }

    function getColorForWalletAddress(address) {
        return walletSectionAccounts.getColorByAddress(address)
    }

    function createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens) {
        return walletSectionSavedAddresses.createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens)
    }

    function deleteSavedAddress(address, ens) {
        return walletSectionSavedAddresses.deleteSavedAddress(address, ens)
    }

    function toggleNetwork(chainId) {
        networksModule.toggleNetwork(chainId)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function runAddAccountPopup() {
        walletSection.runAddAccountPopup(false)
    }

    function runAddWatchOnlyAccountPopup() {
        walletSection.runAddAccountPopup(true)
    }

    function runEditAccountPopup(address) {
        walletSection.runEditAccountPopup(address)
    }

    function switchReceiveAccount(index) {
        walletSectionSend.switchReceiveAccount(index)
    }

    function toggleWatchOnlyAccounts() {
        walletSection.toggleWatchOnlyAccounts()
    }

    function getAllNetworksChainIds() {
        return networksModule.getAllNetworksChainIds()
    }

    function getNetworkShortNames(chainIds) {
       return networksModule.getNetworkShortNames(chainIds)
    }

    function updateWalletAccountPreferredChains(address, preferredChainIds) {
        if(areTestNetworksEnabled) {
            walletSectionAccounts.updateWalletAccountTestPreferredChains(address, preferredChainIds)
        }
        else {
            walletSectionAccounts.updateWalletAccountProdPreferredChains(address, preferredChainIds)
        }
    }

    function processPreferredSharingNetworkToggle(preferredSharingNetworks, toggledNetwork) {
        let prefChains = preferredSharingNetworks
        if(prefChains.length === allNetworks.count) {
            prefChains = [toggledNetwork.chainId.toString()]
        }
        else if(!prefChains.includes(toggledNetwork.chainId.toString())) {
            prefChains.push(toggledNetwork.chainId.toString())
        }
        else {
            if(prefChains.length === 1) {
                prefChains = getAllNetworksChainIds().split(":")
            }
            else {
                for(var i = 0; i < prefChains.length;i++) {
                    if(prefChains[i] === toggledNetwork.chainId.toString()) {
                        prefChains.splice(i, 1)
                    }
                }
            }
        }
        return prefChains
    }
}
