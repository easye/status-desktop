pragma Singleton

import QtQuick 2.13

import "../../../assets/twemoji/twemoji.js" as Twemoji
import "./emojiList.js" as EmojiJSON

QtObject {
    readonly property var size: {
        "veryBig": "86x86",
        "big": "72x72",
        "middle": "32x32",
        "small": "18x18",
        "verySmall": "16x16"
    }
    readonly property var format: {
        "png": "png",
        "svg": "svg"
    }
    readonly property string base: Qt.resolvedUrl("../../../assets/twemoji/")
    property var emojiJSON: EmojiJSON

    function parse(text, renderSize = size.small, renderFormat = format.svg) {
        const renderSizes = renderSize.split("x");
        if (!renderSize.includes("x") || renderSizes.length !== 2) {
            throw new Error("Invalid value for 'renderSize' parameter: ", renderSize);
        }

        const path = renderFormat == format.svg ? "svg/" : "72x72/"
        Twemoji.twemoji.base = base + path
        Twemoji.twemoji.ext = `.${renderFormat}`

        return Twemoji.twemoji.parse(text, {
            callback: (iconId, options) => {
                return options.base + iconId + options.ext;
            },
            attributes: function() {
              return {
                width: renderSizes[0],
                height: renderSizes[1],
                style: "vertical-align: top"
              }
            }
        })
    }
    function iconSource(text) {
        const parsed = parse(text);
        const match = parsed.match('src="(.*\.svg).*"');
        return (match && match.length >= 2) ? match[1] : undefined;
    }
    function svgImage(unicode) {
        return `${base}/svg/${unicode}.svg`
    }
    function iconId(text) {
        const parsed = parse(text);
        const match = parsed.match('src=".*\/(.+?).svg');
        return (match && match.length >= 2) ? match[1] : undefined;
    }
    // NOTE: doing the same thing as iconId but without checking Twemoji internal checks
    function iconHex(text) {
        return text.codePointAt(0).toString(16);
    }
    function fromCodePoint(value) {
        return Twemoji.twemoji.convert.fromCodePoint(value)
    }
    
    // This regular expression looks for html tag `img` with following attributes in any order:
    //  - `src` containig with "/assets/twemoji/" substring
    //  - `alt` (this one is captured)
    readonly property var emojiRegexp: /<img(?=[^>]*\balt="([^"]*)")(?=[^>]*\bsrc="[^>]*\/assets\/twemoji\/[^>]*")[^>]*>/g

    function deparse(value) {
        return value.replace(emojiRegexp, "$1");
    }
    function hasEmoji(value) {
        let match = value.match(emojiRegexp)
        return match && match.length > 0
    }
    function nbEmojis(value) {
        let match = value.match(emojiRegexp)
        return match ? match.length : 0
    }
    function getEmojis(value) {
        return value.match(emojiRegexp, "$1");
    }
    function getEmojiUnicode(shortname) {

        const _emoji = EmojiJSON.emoji_json.find(function(emoji) {
            return (emoji.shortname === shortname)
        })

        if (_emoji !== undefined)
            return _emoji.unicode;
        return undefined;
    }

    function getEmojiCodepoint(iconCodePoint) {
        // Split the codepoint to get all the parts and then encode them from hex to utf8
        const splitCodePoint = iconCodePoint.split('-')
        let codePointParts = []
        splitCodePoint.forEach(function (codePoint) {
            codePointParts.push(`0x${codePoint}`)
        })
        return String.fromCodePoint(...codePointParts);
    }

    function getShortcodeFromId(emojiId) {
        switch (emojiId) {
            case 1: return ":heart:"
            case 2: return ":thumbsup:"
            case 3: return ":thumbsdown:"
            case 4: return ":laughing:"
            case 5: return ":cry:"
            case 6: return ":angry:"
            default: return undefined
        }
    }

    function getEmojiFromId(emojiId) {
        let shortcode = Emoji.getShortcodeFromId(emojiId)
        let emojiUnicode = Emoji.getEmojiUnicode(shortcode)
        if (emojiUnicode) {
            return Emoji.fromCodePoint(emojiUnicode)
        }
        return undefined
    }

    function getRandomEmoji(size) {
        var randomEmoji = EmojiJSON.emoji_json[Math.floor(Math.random() * EmojiJSON.emoji_json.length)]

        const extenstionIndex = randomEmoji.unicode.lastIndexOf('.');
        let iconCodePoint = randomEmoji.unicode
        if (extenstionIndex > -1) {
            iconCodePoint = iconCodePoint.substring(0, extenstionIndex)
        }

        // Split the unicode to get all the parts and then encode them from hex to utf8
        const splitCodePoint = iconCodePoint.split('-')
        let codePointParts = []
        splitCodePoint.forEach(function (codePoint) {
            codePointParts.push(`0x${codePoint}`)
        })
        const encodedIcon = String.fromCodePoint(...codePointParts);

        // Adding a space because otherwise, some emojis would fuse since emoji is just a string
        return Emoji.parse(encodedIcon, size || undefined) + ' '
    }
}
