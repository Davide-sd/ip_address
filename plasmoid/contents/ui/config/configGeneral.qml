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
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

ColumnLayout {
    id: configPage

    Layout.minimumWidth: parent.width
    Layout.maximumWidth: parent.width
    Layout.preferredWidth: parent.width

    property alias cfg_widgetIconSize: widgetIconSizeCombo.currentIndex
    property alias cfg_updateInterval: updateIntervalSpin.value
    property alias cfg_fontSize: fontSizeSpin.value
    property alias cfg_showWidgetLabel: showWidgetLabel.checked
    property alias cfg_showFlagInCompact: showFlagInCompact.checked
    property alias cfg_showIPInCompact: showIPInCompact.checked

    QtControls.GroupBox {
        Layout.fillWidth: true
        title: i18n("Widget configuration")
        // flat: true

        ColumnLayout {
            RowLayout {
                QtControls.Label {
                    text: i18n('Update Interval:')
                }

                QtControls.SpinBox {
                    id: updateIntervalSpin
                    minimumValue: 2
                    maximumValue: 60
                    decimals: 0
                    stepSize: 1
                    suffix: ' min'
                }
            }

            RowLayout {
                QtControls.Label {
                    text: i18n("Icon size shown in the widget:")
                }

                QtControls.ComboBox {
                    id: widgetIconSizeCombo
                    model: ["Default", "Tiny", "Small", "Small-Medium", "Medium", "Large", "Huge", "Enormous"]
                }
            }

            RowLayout {
                QtControls.Label {
                    text: i18n('Widget Font size:')
                }

                QtControls.SpinBox {
                    id: fontSizeSpin
                    minimumValue: 10
                    maximumValue: 200
                    decimals: 0
                    stepSize: 5
                    suffix: ' %'
                }
            }

            QtControls.CheckBox {
                id: showWidgetLabel
                text: i18n("Display the label alongside the widget icon")
            }

            QtControls.CheckBox {
                id: showFlagInCompact
                text: i18n("Display Country flag in widget icon")
            }

            QtControls.CheckBox {
                id: showIPInCompact
                text: i18n("Display IP address next to widget icon")
            }
        }
    }

    Item { // tighten layout
        Layout.fillHeight: true
    }
}
