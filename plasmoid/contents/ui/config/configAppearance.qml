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

import QtQuick 2.0
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: appearancePage

    Layout.minimumWidth: parent.width
    Layout.maximumWidth: parent.width
    Layout.preferredWidth: parent.width

    // property alias cfg_widgetIconSize: widgetIconSizeCombo.currentIndex
    // property alias cfg_updateInterval: updateIntervalSpin.value
    // property alias cfg_layoutRow: layoutRow.checked
    // property alias cfg_showFlagInCompact: showFlagInCompact.checked
    property alias cfg_mapSize: mapSizeSpin.value
    property alias cfg_mapZoomLevel: mapZoomLevelSpin.value
    property alias cfg_showHostname: showHostname.checked
    property alias cfg_layoutRow: layoutRow.checked
    property alias cfg_useLabelThemeColor: labelThemeColorCheckBox.checked
    property alias cfg_labelColor: labelColorRectangle.color
    property alias cfg_useLinkThemeColor: linkThemeColorCheckBox.checked
    property alias cfg_linkColor: linkColorRectangle.color

    QtControls.GroupBox {
        Layout.fillWidth: true
        title: i18n("Map configurations")

        ColumnLayout {

            RowLayout {
                QtControls.Label {
                    text: i18n('Map Size:')
                }

                QtControls.SpinBox {
                    id: mapSizeSpin
                    minimumValue: 50
                    maximumValue: 500
                    decimals: 0
                    stepSize: 1
                    suffix: ' px'
                }
            }

            RowLayout {
                QtControls.Label {
                    text: i18n('Default zoom level:')
                }

                QtControls.SpinBox {
                    id: mapZoomLevelSpin
                    minimumValue: 0
                    maximumValue: 19
                    decimals: 0
                    stepSize: 1
                    suffix: ''
                }
            }
        }
    }

    QtControls.GroupBox {
        Layout.fillWidth: true
        title: i18n("Layout")

        ColumnLayout {
            QtControls.ExclusiveGroup { id: displayOrderGroup }
            QtControls.RadioButton {
                id: layoutRow
                text: i18n('Use horizontal layout')
                exclusiveGroup: displayOrderGroup
            }
            QtControls.RadioButton {
                id: layoutColumn
                text: i18n('Use vertical layout')
                checked: !layoutRow.checked
                exclusiveGroup: displayOrderGroup
            }
        }
    }

    QtControls.GroupBox {
        Layout.fillWidth: true
        title: i18n("Set Custom Colors")

        GridLayout {
            id: labelsContainer
            flow: GridLayout.LeftToRight
            columns: 2
            Layout.minimumWidth: 300
            Layout.maximumWidth: 300
            Layout.preferredWidth: 300

            QtControls.CheckBox {
                id: labelThemeColorCheckBox
                text: i18n("Use Label Theme Color")
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

            QtControls.CheckBox {
                id: linkThemeColorCheckBox
                text: i18n("Use Links Theme Color")
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
    }

    ColorDialog {
        id: labelColorDialog
        onAccepted: cfg_labelColor = this.color
    }

    ColorDialog {
        id: linkColorDialog
        onAccepted: cfg_linkColor = this.color
    }

    QtControls.GroupBox {
        Layout.fillWidth: true
        title: i18n("Others")

        QtControls.CheckBox {
            id: showHostname
            text: i18n("Show host name")
        }
    }

    Item { // tighten layout
        Layout.fillHeight: true
    }
}
