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

/*
TODO:
1. After loading the widgets, go to settings -> Check "Show Hostname"
    -> Click OK -> The plugin freeze, no errors, no messages... WTF?
2. Center the map when opening full representation. As of now, if you scroll
	and move the minimap, then close the full representation, then reopen it,
	the map will be centered on the last known position, not in the marker
*/


import QtQuick 2.2
import QtQuick.Controls as QtControls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

import "js/index.js" as ExternalJS

PlasmoidItem {
	id: root

	readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

	readonly property int widgetIconSize: Plasmoid.configuration.widgetIconSize
	readonly property int updateIntervalMinutes: Plasmoid.configuration.updateInterval
	readonly property bool showFlagInCompact: Plasmoid.configuration.showFlagInCompact
	readonly property bool showVPNIcon: Plasmoid.configuration.showVPNIcon
	readonly property bool showIPInCompact: Plasmoid.configuration.showIPInCompact
	readonly property string globe_icon_path: "../icons/globe.svg"
	readonly property bool useLabelThemeColor: Plasmoid.configuration.useLabelThemeColor
    readonly property string labelColor: Plasmoid.configuration.labelColor
    readonly property string vpnKeywords: Plasmoid.configuration.vpnKeywords
    
	property real latitude: 0
	property real longitude: 0
	property var jsonData: {}

	property var request: null
	property string prevVPNstatus: "unknown"
	property string curVPNstatus: "unknown"

	property int countSeconds: 1
	property bool runTimer: true

	property bool debug: false

	// used to execute query commands for vpn checks
	Plasma5Support.DataSource {
		id: executable_vpn
		engine: "executable"
		connectedSources: []
		function exec(cmd) {
			connectSource(cmd)
		}
		onNewData: {
			var exitCode = data["exit code"]
			var exitStatus = data["exit status"]
			var stdout = data["stdout"]
			var stderr = data["stderr"]

			prevVPNstatus = curVPNstatus
			if (vpnKeywords !== ""){
				if (stdout === "") {
					vpn_svg.imagePath = Qt.resolvedUrl("../icons/vpn-shield-off.svg")
					curVPNstatus = "inactive"
				}
				else {
					vpn_svg.imagePath = Qt.resolvedUrl("../icons/vpn-shield-on.svg")
					curVPNstatus = "active"
				}
				
				if (stderr !== "") {
					vpn_svg.imagePath = Qt.resolvedUrl("../icons/question-mark.svg")
					curVPNstatus = "unknown"
				}
			}
			else {
				vpn_svg.imagePath = Qt.resolvedUrl("../icons/question-mark.svg")
				curVPNstatus = "unknown"
			}

			exited(exitCode, exitStatus, stdout, stderr)
			disconnectSource(sourceName) // cmd finished
		}
		signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }

	// used to send a request to ip-info
	Timer {
		id: timer
		interval: updateIntervalMinutes * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			debug_print("[timer.onTriggered]")
			reloadData()
			runTimer = false
		}
	}

	// used to check if the vpn is up/down
	Timer {
		id: timer_vpn
		interval: 1000
		running: showVPNIcon
		// running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			debug_print("[timer_vpn.onTriggered] vpnKeywords: " + vpnKeywords)
			executable_vpn.exec("nmcli c show --active | grep -E '" + vpnKeywords + "'")

			if (prevVPNstatus != curVPNstatus) {
				debug_print("[timer_vpn.onTriggered] detected change, sending request")
				setTimeout(reloadData(), 1000)
			}
		}
	}

	KSvg.Svg {
		id: vpn_svg
		imagePath: Qt.resolvedUrl("../icons/vpn-shield-off.svg")
	}

	function getIPdata(successCallback, failureCallback) {
		// append /json to the end to force json data response
		var getUrl = "https://ipinfo.io/json"
		debug_print("[getIPdata] attempting request")

		try {
			var request = new XMLHttpRequest()
			request.open('GET', getUrl)

			// QML XMLHttpRequest doesn't have ontimeout. Need to create a 
			// custom timer to simulate it.
			var myTimeoutTimer = Qt.createQmlObject("import QtQuick 2.2; Timer {interval: 5000; repeat: false; running: true;}",root,"MyTimeoutTimer");
			myTimeoutTimer.triggered.connect(function(){
				debug_print("[getIPdata] request TIMEOUT")
				request.responseText = "Timeout reached"
				request.abort()
				// often, just after a vpn change has been detected, the first 
				// requests are going to timeout. Keep sending them until one
				// is successful.
				// TODO: is there any better approach???
				getIPdata(successCallback, failureCallback)
			});
			
			request.onreadystatechange = function () {
				if (request.readyState !== XMLHttpRequest.DONE) {
					return
				}

				if (request.status !== 200) {
					failureCallback(request)
					return
				}

				var jsonData = JSON.parse(request.responseText)
				// remember to stop the timeout timer
				myTimeoutTimer.running = false
				successCallback(jsonData)
			}

			request.send()
			return request
		}
		catch (err) {
			debug_print("[getIPdata] Error" + JSON.stringify(err, null, 4))
			return null
		}
	}

	function successCallback(jsonData) {
		root.jsonData = jsonData
		var coords = jsonData.loc.split(",")
		root.latitude = parseFloat(coords[0])
		root.longitude = parseFloat(coords[1])
		debug_print("[successCallback]: " + JSON.stringify(jsonData, null, 4))
	}

	function failureCallback(request) {
		debug_print("[failureCallback] request.status: " + request.status + "; request.responseText: " + request.responseText)
	}

	function debug_print(msg) {
		if (debug)
			console.log("com.github.davide-sd.ip_address", msg)
	}

	function reloadData() {
		debug_print("[reloadData] Sending request")
		root.request = getIPdata(successCallback, failureCallback)
	}

	function getIconPath(isToolTipArea) {
		if (root.jsonData === undefined) {
			return Qt.resolvedUrl(globe_icon_path)
		}

		var country = root.jsonData.country.toLowerCase()
		if (isToolTipArea) {
			return Qt.resolvedUrl("../icons/1x1/" + country + ".svg")
		}

		if (!showFlagInCompact) {
			return Qt.resolvedUrl(globe_icon_path)
		}

		return Qt.resolvedUrl("../icons/1x1/" + country + ".svg")
	}

	compactRepresentation: MouseArea {
        id: compactRoot
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton

		// Taken from DigitalClock to ensure uniform sizing when next to each other
        readonly property bool tooSmall: Plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 5)) <= Kirigami.Theme.smallFont.pixelSize
		readonly property int fontSize: Plasmoid.configuration.fontSize
		readonly property bool showCountryLabel: Plasmoid.configuration.showCountryLabel

		Layout.minimumWidth: compactRow.implicitWidth
		Layout.maximumWidth: Layout.minimumWidth
		Layout.preferredWidth: Layout.minimumWidth

		onClicked: (mouse)=> {
			if (mouse.button == Qt.MiddleButton) {
                root.reloadData()
            } else {
                root.expanded = !root.expanded
            }
		}

		GridLayout {
			id: compactRow
			anchors.centerIn: parent
			flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

			KSvg.SvgItem {
				id: icon
				Layout.minimumWidth: Kirigami.Units.iconSizes.small
                Layout.minimumHeight: Kirigami.Units.iconSizes.small
                Layout.maximumWidth: Kirigami.Units.iconSizes.enormous
                Layout.maximumHeight: Kirigami.Units.iconSizes.enormous
                Layout.preferredWidth: ExternalJS.getIconSize(widgetIconSize, compactRoot)
                Layout.preferredHeight: Layout.preferredWidth
				svg: KSvg.Svg {
					id: svg
					imagePath: getIconPath(false)
				}
			}

			QtControls.Label {
				color: useLabelThemeColor ? Kirigami.Theme.textColor : labelColor
				text: {
					if (root.jsonData != undefined) {
						var country = root.jsonData.country.toUpperCase()
						if (showCountryLabel && showIPInCompact)
							return country + " " + root.jsonData.ip
						else if (showCountryLabel)
							return country
						else if (showIPInCompact)
							return root.jsonData.ip
						return ""
					}
					return ""
				}
				height: compactRoot.height
				fontSizeMode: isVertical ? Text.HorizontalFit : Text.FixedSize
				font.pixelSize: {
                    if (isVertical)
                        return undefined
                    else
                        return tooSmall ? Kirigami.Theme.defaultFont.pixelSize : Kirigami.Units.iconSizes.roundedIconSize(Kirigami.Units.gridUnit * 2) * fontSize / 100
                }
				visible: showCountryLabel || showIPInCompact
			}

			KSvg.SvgItem {
				id: vpn_icon
				Layout.minimumWidth: Kirigami.Units.iconSizes.small
                Layout.minimumHeight: Kirigami.Units.iconSizes.small
                Layout.maximumWidth: Kirigami.Units.iconSizes.enormous
                Layout.maximumHeight: Kirigami.Units.iconSizes.enormous
                Layout.preferredWidth: ExternalJS.getIconSize(widgetIconSize, compactRoot)
                Layout.preferredHeight: Layout.preferredWidth
				visible: showVPNIcon
				svg: vpn_svg
			}
		}

		PlasmaCore.ToolTipArea {
	        anchors.fill: parent
	        icon: getIconPath(true)
	        mainText: i18n('Public IP Address')
			subText: {
				var details = i18n("Public IP Address: ")
				if (root.jsonData !== undefined) {
					details += "<b>" + root.jsonData.ip + "</b>"
					details += "<br/>"
					details += i18n("Connected to: ")
					details += "<b>" + root.jsonData.country + ", " + root.jsonData.region + ", " + root.jsonData.city + "</b>"
				}
				else {
					details += details += "<b>N/A</b>"
				}
				return details
			}
	    }
	}

	fullRepresentation: FullRepresentation {}

}
