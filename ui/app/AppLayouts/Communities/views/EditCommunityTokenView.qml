import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Wallet.controls 1.0
import shared.panels 1.0
import shared.popups 1.0

import SortFilterProxyModel 0.2

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property bool isAssetView: false
    property int validationMode: StatusInput.ValidationMode.OnlyWhenDirty
    property var tokensModel
    property var tokensModelWallet

    property TokenObject collectible: TokenObject {
        type: Constants.TokenType.ERC721
    }

    property TokenObject asset: TokenObject{
        type: Constants.TokenType.ERC20
    }

    // Used for reference validation when editing a failed deployment
    property string referenceName: ""
    property string referenceSymbol: ""

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var enabledNetworks
    property var allNetworks

    // Account expected roles: address, name, color, emoji, walletType
    property var accounts

    property string feeText
    property string feeErrorText
    property bool isFeeLoading

    readonly property string feeLabel:
        isAssetView ? qsTr("Mint asset on %1").arg(asset.chainName)
                    : qsTr("Mint collectible on %1").arg(collectible.chainName)

    signal chooseArtWork
    signal previewClicked
    signal deployFeesRequested

    QtObject {
        id: d

        readonly property bool isFullyFilled: dropAreaItem.artworkSource.toString().length > 0
                                              && nameInput.valid
                                              && descriptionInput.valid
                                              && symbolInput.valid
                                              && (unlimitedSupplyChecker.checked || (!unlimitedSupplyChecker.checked && parseInt(supplyInput.text) > 0))
                                              && (!root.isAssetView  || (root.isAssetView && assetDecimalsInput.valid))
                                              && !root.isFeeLoading && root.feeErrorText === "" && !requestFeeDelayTimer.running

        readonly property int imageSelectorRectWidth: root.isAssetView ? 128 : 290

        function hasEmoji(text) {
            return SQUtils.Emoji.hasEmoji(SQUtils.Emoji.parse(text));
        }
    }

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    Component.onCompleted: {
        if(root.isAssetView)
            networkSelector.setChain(asset.chainId)
        else
            networkSelector.setChain(collectible.chainId)
    }

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        StatusBaseText {
            elide: Text.ElideRight
            font.pixelSize: Theme.primaryTextFontSize
            text: root.isAssetView ? qsTr("Icon") : qsTr("Artwork")
        }

        DropAndEditImagePanel {
            id: dropAreaItem

            Layout.fillWidth: true
            Layout.preferredHeight: d.imageSelectorRectWidth
            dataImage: root.isAssetView ? asset.artworkSource : collectible.artworkSource
            artworkSource: root.isAssetView ? asset.artworkSource : collectible.artworkSource
            editorAnchorLeft: false
            editorRoundedImage: root.isAssetView
            uploadTextLabel.uploadText: root.isAssetView ? qsTr("Upload") : qsTr("Drag and Drop or Upload Artwork")
            uploadTextLabel.additionalText: qsTr("Images only")
            uploadTextLabel.showAdditionalInfo: !root.isAssetView
            editorTitle: root.isAssetView ? qsTr("Asset icon") : qsTr("Collectible artwork")
            acceptButtonText: root.isAssetView ? qsTr("Upload asset icon") : qsTr("Upload collectible artwork")

            onArtworkSourceChanged: {
                if(root.isAssetView)
                    asset.artworkSource = artworkSource
                else
                    collectible.artworkSource = artworkSource
            }
            onArtworkCropRectChanged: {
                if(root.isAssetView)
                    asset.artworkCropRect = artworkCropRect
                else
                    collectible.artworkCropRect = artworkCropRect
            }
        }

        CustomStatusInput {
            id: nameInput

            label: qsTr("Name")
            text: root.isAssetView ? asset.name : collectible.name
            charLimit: 15
            placeholderText: qsTr("Name")
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please name your token name (use A-Z and 0-9, hyphens and underscores only)")
            regexValidator.errorMessage: d.hasEmoji(text) ?
                                         qsTr("Your token name is too cool (use A-Z and 0-9, hyphens and underscores only)") :
                                         qsTr("Your token name contains invalid characters (use A-Z and 0-9, hyphens and underscores only)")
            extraValidator.validate: function (value) {
                // If minting failed, we can retry same deployment, so same name allowed
                const allowRepeatedName = (root.isAssetView ? asset.deployState : collectible.deployState) === Constants.ContractTransactionStatus.Failed
                if(allowRepeatedName)
                    if(nameInput.text === root.referenceName)
                        return true

                // Otherwise, no repeated names allowed:
                return !SQUtils.ModelUtils.contains(root.tokensModel, "name", nameInput.text, Qt.CaseInsensitive)
            }
            extraValidator.errorMessage: qsTr("You have used this token name before")

            onTextChanged: {
                if(root.isAssetView)
                    asset.name = text
                else
                    collectible.name = text
            }
        }

        CustomStatusInput {
            id: descriptionInput

            label: qsTr("Description")
            text: root.isAssetView ? asset.description : collectible.description
            charLimit: 280
            placeholderText: root.isAssetView ? qsTr("Describe your asset") : qsTr("Describe your collectible")
            input.multiline: true
            input.verticalAlignment: Qt.AlignTop
            input.placeholder.verticalAlignment: Qt.AlignTop
            minimumHeight: 108
            maximumHeight: minimumHeight
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please enter a token description")
            regexValidator.regularExpression: Constants.regularExpressions.ascii
            regexValidator.errorMessage: qsTr("Only A-Z, 0-9 and standard punctuation allowed")

            onTextChanged: {
                if(root.isAssetView)
                    asset.description = text
                else
                    collectible.description = text
            }
        }

        CustomStatusInput {
            id: symbolInput

            label: qsTr("Symbol")
            text: root.isAssetView ? asset.symbol : collectible.symbol
            charLimit: 6
            placeholderText: root.isAssetView ? qsTr("e.g. ETH"): qsTr("e.g. DOODLE")
            validationMode: root.validationMode
            minLengthValidator.errorMessage: qsTr("Please enter your token symbol (use A-Z only)")
            regexValidator.errorMessage: d.hasEmoji(text) ? qsTr("Your token symbol is too cool (use A-Z only)") :
                qsTr("Your token symbol contains invalid characters (use A-Z only)")
            regexValidator.regularExpression: Constants.regularExpressions.capitalOnly
            extraValidator.validate: function (value) {
                // If minting failed, we can retry same deployment, so same symbol allowed
                const allowRepeatedName = (root.isAssetView ? asset.deployState : collectible.deployState) === Constants.ContractTransactionStatus.Failed
                if(allowRepeatedName)
                    if(symbolInput.text.toUpperCase() === root.referenceSymbol.toUpperCase())
                        return true

                // Otherwise, no repeated names allowed:
                return (!SQUtils.ModelUtils.contains(root.tokensModel, "symbol", symbolInput.text) &&
                       !SQUtils.ModelUtils.contains(root.tokensModelWallet, "symbol", symbolInput.text))
            }
            extraValidator.errorMessage: SQUtils.ModelUtils.contains(root.tokensModelWallet, "symbol", symbolInput.text) ?
                qsTr("This token symbol is already in use") : qsTr("You have used this token symbol before")

            onTextChanged: {
                const cursorPos = input.edit.cursorPosition
                const upperSymbol = text.toUpperCase()
                if(root.isAssetView)
                    asset.symbol = upperSymbol
                else
                    collectible.symbol = upperSymbol
                text = upperSymbol // breaking the binding on purpose but so does validate() and onTextChanged() internal handler
                input.edit.cursorPosition = cursorPos
            }
        }

        CustomNetworkFilterRowComponent {
            id: networkSelector

            label: qsTr("Select network")
            description: qsTr("The network on which this token will be minted")
        }

        CustomSwitchRowComponent {
            id: unlimitedSupplyChecker

            label: qsTr("Unlimited supply")
            description: qsTr("Enable to allow the minting of additional tokens in the future. Disable to specify a finite supply")
            checked: root.isAssetView ? asset.infiniteSupply : collectible.infiniteSupply

            onCheckedChanged: {
                if(!checked) supplyInput.forceActiveFocus()

                if(root.isAssetView)
                    asset.infiniteSupply = checked
                else
                    collectible.infiniteSupply = checked
            }
        }

        CustomStatusInput {
            id: supplyInput

            visible: !unlimitedSupplyChecker.checked
            label: qsTr("Total finite supply")
            text: root.isAssetView ? asset.supply : collectible.supply
            placeholderText: qsTr("e.g. 300")
            minLengthValidator.errorMessage: qsTr("Please enter a total finite supply")
            regexValidator.errorMessage: d.hasEmoji(text) ? qsTr("Your total finite supply is too cool (use 0-9 only)") :
                qsTr("Your total finite supply contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical
            extraValidator.validate: function (value) { return parseInt(value) > 0 && parseInt(value) <= 999999999 }
            extraValidator.errorMessage: qsTr("Enter a number between 1 and 999,999,999")

            onTextChanged: {
                const amount = parseInt(text)
                if (Number.isNaN(amount) || Object.values(errors).length)
                    return

                if(root.isAssetView)
                    asset.supply = amount
                else
                    collectible.supply = amount
            }
        }

        CustomSwitchRowComponent {
            id: transferableChecker

            visible: !root.isAssetView
            label: checked ? qsTr("Not transferable (Soulbound)") : qsTr("Transferable")
            description: qsTr("If enabled, the token is locked to the first address it is sent to and can never be transferred to another address. Useful for tokens that represent Admin permissions")
            checked: !collectible.transferable

            onCheckedChanged: collectible.transferable = !checked
        }

        CustomSwitchRowComponent {
            id: remotelyDestructChecker

            visible: !root.isAssetView
            label: qsTr("Remotely destructible")
            description: qsTr("Enable to allow you to destroy tokens remotely. Useful for revoking permissions from individuals")
            checked: !!collectible ? collectible.remotelyDestruct : true
            onCheckedChanged: collectible.remotelyDestruct = checked
        }

        CustomStatusInput {
            id: assetDecimalsInput

            visible: root.isAssetView
            label: qsTr("Decimals (DP)")
            charLimit: 2
            charLimitLabel: qsTr("Max 10")
            placeholderText: "2"
            text: !!asset ? asset.decimals : ""
            validationMode: StatusInput.ValidationMode.Always
            minLengthValidator.errorMessage: qsTr("Please enter how many decimals your token should have")
            regexValidator.errorMessage: d.hasEmoji(text) ? qsTr("Your decimal amount is too cool (use 0-9 only)") :
                qsTr("Your decimal amount contains invalid characters (use 0-9 only)")
            regexValidator.regularExpression: Constants.regularExpressions.numerical
            extraValidator.validate: function (value) { return parseInt(value) > 0 && parseInt(value) <= 10 }
            extraValidator.errorMessage: qsTr("Enter a number between 1 and 10")
            onTextChanged: asset.decimals = parseInt(text)
        }

        FeesBox {
            id: feesBox

            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            accountErrorText: root.feeErrorText
            implicitWidth: 0

            model: QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                      "" : root.feeText
                readonly property bool error: root.feeErrorText !== ""
            }

            Timer {
                id: requestFeeDelayTimer

                interval: 500
                onTriggered: root.deployFeesRequested()
            }

            readonly property bool triggerFeeReevaluation: {
                dropAreaItem.artworkSource
                nameInput.text
                descriptionInput.text
                symbolInput.text
                supplyInput.text
                unlimitedSupplyChecker.checked
                transferableChecker.checked
                remotelyDestructChecker.checked
                feesBox.accountsSelector.currentIndex
                asset.chainId
                collectible.chainId

                requestFeeDelayTimer.restart()
                return true
            }

            accountsSelector.model: SortFilterProxyModel {
                sourceModel: root.accounts
                proxyRoles: [
                    ExpressionRole {
                        name: "color"

                        function getColor(colorId) {
                            return Utils.getColorForId(colorId)
                        }

                        // Direct call for singleton function is not handled properly by
                        // SortFilterProxyModel that's why helper function is used instead.
                        expression: { return getColor(model.colorId) }
                    }
                ]
                filters: ValueFilter {
                    roleName: "walletType"
                    value: Constants.watchWalletType
                    inverted: true
                }
            }

            readonly property TokenObject token: root.isAssetView ? root.asset
                                                                  : root.collectible

            // account can be changed also on preview page and it should be
            // reflected in the form after navigating back
            Connections {
                target: feesBox.token

                function onAccountAddressChanged() {
                    const idx = SQUtils.ModelUtils.indexOf(
                                        feesBox.accountsSelector.model, "address",
                                        feesBox.token.accountAddress)

                    feesBox.accountsSelector.currentIndex = idx
                }
            }

            accountsSelector.onCurrentIndexChanged: {
                if (accountsSelector.currentIndex < 0)
                    return

                const item = SQUtils.ModelUtils.get(
                               accountsSelector.model, accountsSelector.currentIndex)
                token.accountAddress = item.address
                token.accountName = item.name
            }
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            Layout.bottomMargin: Style.current.padding
            text: qsTr("Preview")
            enabled: d.isFullyFilled

            onClicked: root.previewClicked()
        }
    }

    // Inline components definition:
    component CustomStatusInput: StatusInput {
        id: customInput

        property alias minLengthValidator: minLengthValidatorItem
        property alias regexValidator: regexValidatorItem
        property alias extraValidator: extraValidatorItem

        Layout.fillWidth: true
        validators: [
            StatusMinLengthValidator {
                id: minLengthValidatorItem
                minLength: 1
            },
            StatusRegularExpressionValidator {
                id: regexValidatorItem
                regularExpression: Constants.regularExpressions.alphanumericalExpanded
                onErrorMessageChanged: {
                    customInput.validate();
                }
            },
            StatusValidator {
                id: extraValidatorItem
                onErrorMessageChanged: {
                    customInput.validate();
                }
            }
        ]
    }

    component CustomLabelDescriptionComponent: ColumnLayout {
        id: labelDescComponent

        property string label
        property string description

        Layout.fillWidth: true

        StatusBaseText {
            text: labelDescComponent.label
            color: Theme.palette.directColor1
            font.pixelSize: Theme.primaryTextFontSize
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: labelDescComponent.description
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }
    }

    component CustomSwitchRowComponent: RowLayout {
        id: rowComponent

        property string label
        property string description
        property alias checked: switch_.checked

        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        spacing: 64

        CustomLabelDescriptionComponent {
            label: rowComponent.label
            description: rowComponent.description
        }

        StatusSwitch {
            id: switch_
        }
    }

    component CustomNetworkFilterRowComponent: RowLayout {
        id: networkComponent

        property string label
        property string description

        function setChain(chainId) { netFilter.setChain(chainId) }

        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        spacing: 32

        CustomLabelDescriptionComponent {
            label: networkComponent.label
            description: networkComponent.description
        }

        NetworkFilter {
            id: netFilter

            Layout.preferredWidth: 160

            allNetworks: root.allNetworks
            layer1Networks: root.layer1Networks
            layer2Networks: root.layer2Networks
            enabledNetworks: root.enabledNetworks

            multiSelection: false

            onToggleNetwork: (network) => {
                if(root.isAssetView) {
                    asset.chainId = network.chainId
                    asset.chainName = network.chainName
                    asset.chainIcon = network.iconUrl
                } else {
                    collectible.chainId = network.chainId
                    collectible.chainName = network.chainName
                    collectible.chainIcon = network.iconUrl
                }
            }
        }
    }
}
