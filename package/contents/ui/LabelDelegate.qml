/*
 *  Copyright 2019 Davide Sandona' <sandona.davide@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

import QtQuick 2.2
import QtQuick.Controls 1.1 as QtControls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

QtControls.Label {

    id: label
    color: fullRoot.useLinkThemeColor ? theme.highlightColor : fullRoot.linkColor2
    font.bold: true
    Layout.fillWidth: true
    wrapMode: Text.Wrap

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: false
        onClicked: {
            debug_print("### [MouseArea onClicked -> Copying to clipboard]")
            executable.exec("qdbus org.kde.klipper /klipper setClipboardContents " + label.text)
            executable.exec("notify-send 'Copied " + label.text + " to clipboard' -a 'Public IP Address widget'")
            // executable.exec("notify-send 'Copied " + label.text + " to clipboard'")
        }
    }
}
