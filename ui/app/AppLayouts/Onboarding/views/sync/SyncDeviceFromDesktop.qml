import QtQuick 2.14
import StatusQ.Controls 0.1

import shared.controls 1.0

Column {
    id: root

    property alias input: codeInput

    StatusSyncCodeInput {
        id: codeInput
        width: parent.width
        mode: StatusSyncCodeInput.WriteMode
    }
}
