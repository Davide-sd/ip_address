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
import QtQuick.Dialogs

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: appearancePage

    Layout.minimumWidth: parent.width
    Layout.maximumWidth: parent.width
    Layout.preferredWidth: parent.width

    property alias cfg_mapSize: mapSizeSpin.value
    property alias cfg_mapZoomLevel: mapZoomLevelSpin.value
    property alias cfg_showHostname: showHostname.checked
    property alias cfg_layoutRow: layoutRow.checked
    property alias cfg_useLabelThemeColor: labelThemeColorCheckBox.checked
    property alias cfg_labelColor: labelColorRectangle.color
    property alias cfg_useLinkThemeColor: linkThemeColorCheckBox.checked
    property alias cfg_linkColor: linkColorRectangle.color

    Kirigami.FormLayout {

        QtControls.SpinBox {
            id: mapSizeSpin
            Kirigami.FormData.label: i18n("Map Size:")
            from: 50
            to: 500
            stepSize: 1
            textFromValue: function(value) {
                return qsTr("%1 px").arg(value)
            }
            valueFromText: function (text) {
                return parseInt(text)
            }
        }

        QtControls.SpinBox {
            id: mapZoomLevelSpin
            Kirigami.FormData.label: i18n("Map default zoom level:")
            from: 0
            to: 19
            stepSize: 1
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        QtControls.ButtonGroup {
            id: displayOrderGroup
        }

        QtControls.RadioButton {
            id: layoutRow
            Kirigami.FormData.label: i18n("Layout:")
            QtControls.ButtonGroup.group: displayOrderGroup
            text: i18n("horizontal layout")
        }
        QtControls.RadioButton {
            id: layoutColumn
            QtControls.ButtonGroup.group: displayOrderGroup
            text: i18n("vertical layout")
            checked: !layoutRow.checked
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        GridLayout {
            id: labelColorContainer
            flow: GridLayout.LeftToRight
            columns: 2
            Layout.minimumWidth: 300
            Layout.maximumWidth: 300
            Layout.preferredWidth: 300
            Kirigami.FormData.label: i18n("Label Color:")

            QtControls.CheckBox {
                id: labelThemeColorCheckBox
                text: i18n("Use Theme")
            }

            QtControls.Button {
                enabled: !labelThemeColorCheckBox.checked
                onClicked: labelColorDialog.open();

                Rectangle {
                    id: labelColorRectangle
                    x: 4
                    y: 4
                    width: parent.width - 8
                    height: parent.height - 8
                    color: cfg_labelColor
                    border.width: 0
                }
            }
        }

        GridLayout {
            id: linkColorContainer
            flow: GridLayout.LeftToRight
            columns: 2
            Layout.minimumWidth: 300
            Layout.maximumWidth: 300
            Layout.preferredWidth: 300
            Kirigami.FormData.label: i18n("Link Color:")

            QtControls.CheckBox {
                id: linkThemeColorCheckBox
                text: i18n("Use Theme")
            }

            QtControls.Button {
                enabled: !linkThemeColorCheckBox.checked
                onClicked: linkColorDialog.open();

                Rectangle {
                    id: linkColorRectangle
                    x: 4
                    y: 4
                    width: parent.width - 8
                    height: parent.height - 8
                    color: cfg_linkColor
                    border.width: 0
                }
            }
        }

        ColorDialog {
            id: labelColorDialog
            onAccepted: cfg_labelColor = selectedColor
        }

        ColorDialog {
            id: linkColorDialog
            onAccepted: cfg_linkColor = selectedColor
        }

        QtControls.CheckBox {
            id: showHostname
            Kirigami.FormData.label: i18n("Others:")
            text: i18n("Show host name")
        }

    }

    Item { // tighten layout
        Layout.fillHeight: true
    }
}
