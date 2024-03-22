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
import QtQuick.Controls as QtControls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

QtControls.Label {

    id: label
    color: fullRoot.useLinkThemeColor ? Kirigami.Theme.highlightColor : fullRoot.linkColor
    font.bold: true
    Layout.fillWidth: true
    wrapMode: Text.Wrap

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: false
        onClicked: {
            debug_print("[MouseArea onClicked -> Copying to clipboard]")
            executable.exec("qdbus org.kde.klipper /klipper setClipboardContents " + label.text)
            executable.exec("notify-send 'Copied " + label.text + " to clipboard' -a 'Public IP Address widget'")
        }
    }
}
