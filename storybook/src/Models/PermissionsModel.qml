import QtQuick 2.0

import Models 1.0
import StatusQ.Core.Utils 0.1
import AppLayouts.Chat.controls.community 1.0

ListModel {
    id: root

    Component.onCompleted:
        append([
                   {
                       isPrivate: true,
                       holdingsListModel: root.createHoldingsModel1(),
                       permissionsObjectModel: {
                           key: 1,
                           text: "Become member",
                           imageSource: "in-contacts"
                       },
                       channelsListModel: root.createChannelsModel1()
                   },
                   {
                       isPrivate: false,
                       holdingsListModel: root.createHoldingsModel2(),
                       permissionsObjectModel: {
                           key: 2,
                           text: "View and post",
                           imageSource: "edit"
                       },
                       channelsListModel: root.createChannelsModel2()
                   }
               ])

    function createHoldingsModel1() {
        return [
            {
                operator: OperatorsUtils.Operators.None,
                type: HoldingTypes.Type.Asset,
                key: "SOCKS",
                name: "SOCKS",
                amount: 1.2,
                imageSource: ModelsData.assets.socks
            },
            {
                operator: OperatorsUtils.Operators.Or,
                type: HoldingTypes.Type.Asset,
                key: "ZRX",
                name: "ZRX",
                amount: 15,
                imageSource: ModelsData.assets.zrx
            },
            {
                operator: OperatorsUtils.Operators.And,
                type: HoldingTypes.Type.Collectible,
                key: "Furbeard",
                name: "Furbeard",
                amount: 12,
                imageSource: ModelsData.collectibles.kitty1
            }
        ]
    }

    function createHoldingsModel2() {
        return [
            {
                operator: OperatorsUtils.Operators.None,
                type: HoldingTypes.Type.Collectible,
                key: "Happy Meow",
                name: "Happy Meow",
                amount: 50.25,
                imageSource: ModelsData.collectibles.kitty3
            },
            {
                operator: OperatorsUtils.Operators.And,
                type: HoldingTypes.Type.Collectible,
                key: "AMP",
                name: "AMP",
                amount: 11,
                imageSource: ModelsData.assets.amp
            }
        ]
    }

    function createChannelsModel1() {
        return [
            {
                key: "general",
                text: "#general",
                color: "lightgreen",
                emoji: "👋"
            },
            {
                key: "faq",
                text: "#faq",
                color: "lightblue",
                emoji: "⚽"
            }
        ]
    }

    function createChannelsModel2() {
        return [
            {
                key: "socks",
                iconSource: ModelsData.icons.socks,
                text: "Socks"
            }
        ]
    }
}
