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
    id: configPage

    Layout.minimumWidth: parent.width
    Layout.maximumWidth: parent.width
    Layout.preferredWidth: parent.width

    property alias cfg_widgetIconSize: widgetIconSizeCombo.currentIndex
    property alias cfg_updateInterval: updateIntervalSpin.value
    property alias cfg_fontSize: fontSizeSpin.value
    property alias cfg_showCountryLabel: showCountryLabel.checked
    property alias cfg_showFlagInCompact: showFlagInCompact.checked
    property alias cfg_showIPInCompact: showIPInCompact.checked
    property alias cfg_showVPNIcon: showVPNIcon.checked
    property alias cfg_vpnKeywords: vpnKeywordsEdit.text
    property alias cfg_sendNotifOnIPChange: sendNotificationOnIpChange.checked
    property alias cfg_triggerFile: triggerFileEdit.text

    Kirigami.FormLayout {

        QtControls.SpinBox {
            id: updateIntervalSpin
            Kirigami.FormData.label: i18n("Update Interval:")
            from: 2
            to: 60
            stepSize: 1
            textFromValue: function(value) {
                return qsTr("%1 min").arg(value)
            }
            valueFromText: function (text) {
                return parseInt(text)
            }
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        QtControls.ComboBox {
            id: widgetIconSizeCombo
            Kirigami.FormData.label: i18n("Icon size:")
            model: ["Default", "Small", "Small-Medium", "Medium", "Large", "Huge", "Enormous"]
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        QtControls.SpinBox {
            id: fontSizeSpin
            Kirigami.FormData.label: i18n("Font size:")
            from: 10
            to: 200
            stepSize: 5
            textFromValue: function(value) {
                return qsTr("%1 %").arg(value)
            }
            valueFromText: function (text) {
                return parseInt(text)
            }
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        QtControls.CheckBox {
            Kirigami.FormData.label: i18n("Show on widget:")
            id: showFlagInCompact
            text: i18n("Country flag")
        }

        QtControls.CheckBox {
            id: showCountryLabel
            text: i18n("Country label")
        }

        QtControls.CheckBox {
            id: showIPInCompact
            text: i18n("IP address")
        }

        QtControls.CheckBox {
            id: showVPNIcon
            text: i18n("VPN status icon")
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        QtControls.TextField {
            id: vpnKeywordsEdit
            Kirigami.FormData.label: i18n("VPN keywords for nmcli (use\npipe character as separator):")
            width: 300
            focus: false
            selectByMouse: true
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        QtControls.Label {
            Kirigami.FormData.label: i18n("Explanation for VPN icon:")
            text: i18n("Red shield: VPN is not active;")
        }

        QtControls.Label {
            text: i18n("Green shield: VPN is active;")
        }

        QtControls.Label {
            text: i18n("Orange disk: some error happened.")
        }

        QtControls.CheckBox {
            id: sendNotificationOnIpChange
            text: i18n("Send notification on IP change")
        }

        Item { // tighten layout
            Layout.fillHeight: true
        }

        QtControls.TextField {
            id: triggerFileEdit
            Kirigami.FormData.label: i18n("Trigger file (optional):")
            placeholderText: "~/.cache/ip_address_refresh"
        }

        QtControls.Label {
            text: i18n("Touch this file to trigger a refresh")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }
    }

}
