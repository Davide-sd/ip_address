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

// fork by Marek M. Marecki marekmarecki2001g@gmail.com 2025

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
	readonly property bool useLabelThemeColor: Plasmoid.configuration.useLabelThemeColor
    readonly property string labelColor: Plasmoid.configuration.labelColor
    readonly property string vpnKeywords: Plasmoid.configuration.vpnKeywords

	property real latitude: 0
	property real longitude: 0
	property var jsonData: {}
	property string prevVPNstatus: "unknown"
	property string curVPNstatus: "unknown"
	property var reloadInProgress: false
	property var _pendingSuccessCallback: null
	property var _pendingFailureCallback: null

	property bool debug: false

	// used to execute query commands for vpn checks
	Plasma5Support.DataSource {
		id: executable_vpn
		engine: "executable"
		connectedSources: []
		function exec(cmd) {
			connectSource(cmd)
		}
		onNewData: function(sourceName, data) {
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
			disconnectSource(sourceName)
		}
		signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }

	// used to execute queries with curl
	// NOTE: why using Plasma5Support.DataSource with engine="executable"
	// instead of `XMLHttpRequest`? Because the latter stops working when
	// a VPN status change is detected. It is unreliable.
	Plasma5Support.DataSource {
		id: executable_curl
		engine: "executable"
		connectedSources: []
		function exec(cmd) {
			connectSource(cmd)
		}
        onNewData: function(sourceName, data) {
			debug_print("[executable_curl.onNewData]")
			let exitCode   = data["exit code"]
			let exitStatus = data["exit status"]
			let stdout     = data.stdout || ""
			let stderr     = data.stderr || ""

			disconnectSource(sourceName)

			if (exitStatus !== 0) {
            	var msg = "Process crashed or failed to start: " + sourceName +
						  ". Status: " + exitStatus + ". Stderr: " + stderr
				handleFailure(msg)
				return
			}

			if (exitCode !== 0) {
				var msg = "Command exited with error: " + sourceName +
						  ". Code: " + exitCode + ". Stderr: " + stderr
				handleFailure(msg)
				return
			}

			try {
				var json = JSON.parse(stdout)
				handleSuccess(json)
			} catch (e) {
				handleFailure("Invalid JSON: " + e)
			}
        }
	}

	function handleFailure(msg) {
		if (_pendingFailureCallback) {
			var fcb = _pendingFailureCallback
			_pendingSuccessCallback = null
			_pendingFailureCallback = null
			fcb(msg)
		} else {
			reloadInProgress = false
			failureCallback(msg)
		}
	}

	function handleSuccess(json) {
		if (_pendingSuccessCallback) {
			var cb = _pendingSuccessCallback
			_pendingSuccessCallback = null
			_pendingFailureCallback = null
			cb(json)
		} else {
			reloadInProgress = false
			successCallback(json)
		}
	}

	// timer for updating IP info
	Timer {
		id: timer
		interval: updateIntervalMinutes * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			debug_print("[timer.onTriggered]")
			reloadData()
		}
	}

	// used to check if the vpn is up/down
	Timer {
		id: timer_vpn
		interval: 1000
		running: showVPNIcon
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			debug_print("[timer_vpn.onTriggered] vpnKeywords: " + vpnKeywords)
			executable_vpn.exec("nmcli c show --active | grep -E '" + vpnKeywords + "'")

			if ((prevVPNstatus != "unknown") && (prevVPNstatus != curVPNstatus)) {
				var wait_for = 5000
				debug_print("[timer_vpn.onTriggered] detected change, scheduling reloadData()")
				reloadInProgress = false
				setTimeout(function() { reloadData() }, wait_for)
			}
		}
	}

	KSvg.Svg {
		id: vpn_svg
		imagePath: Qt.resolvedUrl("../icons/vpn-shield-off.svg")
	}

	function getIPdata(successCallback, failureCallback) {
		debug_print("[getIPdata] running curl")
        _pendingSuccessCallback = successCallback
        _pendingFailureCallback = failureCallback

		try {
			let cmd = "curl -s --max-time 5 https://ipinfo.io/json"
			executable_curl.exec(cmd)
			return true
		} catch (err) {
			debug_print("[getIPdata] Error " + err)
            _pendingSuccessCallback = null
            _pendingFailureCallback = null
			return false
		}
	}

	function successCallback(jsonData) {
		root.jsonData = jsonData
		var coords = jsonData.loc.split(",")
		root.latitude = parseFloat(coords[0])
		root.longitude = parseFloat(coords[1])
		debug_print("[successCallback]: " + JSON.stringify(jsonData, null, 4))
	}

	function failureCallback(reason) {
		debug_print("[failureCallback] " + reason)
	}

	function debug_print(msg) {
		if (debug)
			console.log("com.github.davide-sd.ip_address", msg)
	}

	function reloadData(attempt) {
		if (attempt === undefined) attempt = 1
		if (attempt === 1 && reloadInProgress) {
			debug_print("[reloadData] ignored new chain, already running")
			return
		}
		reloadInProgress = true

		debug_print("[reloadData] attempt " + attempt)
		let ok = getIPdata(
			function(jsonData) {
				debug_print("[reloadData] success")
				reloadInProgress = false
				successCallback(jsonData)
			},
			function(reason) {
				if (attempt < 5) {
					var delay = attempt * 2000
					debug_print("[reloadData] failed: " + reason + " retrying in " + delay + " ms")
					setTimeout(function() { reloadData(attempt + 1) }, delay)
				} else {
					debug_print("[reloadData] final failure: " + reason)
					reloadInProgress = false
					failureCallback(reason)
				}
			}
		)

		if (!ok) {
			debug_print("[reloadData] immediate failure (curl exec)")
			reloadInProgress = false
		}
	}

	function getIconPath(isToolTipArea) {
		if (root.jsonData === undefined) {
			return Qt.resolvedUrl("../icons/globe.svg")
		}

		var country = root.jsonData.country.toLowerCase()
		if (isToolTipArea || showFlagInCompact) {
			return Qt.resolvedUrl("../icons/1x1/" + country + ".svg")
		}

		return Qt.resolvedUrl("../icons/globe.svg")
	}

	function setTimeout(callback, delay) {
		var timer = Qt.createQmlObject('import QtQuick 2.0; Timer { repeat: false }', root)
		timer.interval = delay
		timer.triggered.connect(function() {
			callback()
			timer.destroy()
		})
		timer.start()
	}

	compactRepresentation: MouseArea {
        id: compactRoot
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton

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
				visible: showFlagInCompact
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
					details += "<b>N/A</b>"
				}
				return details
			}
	    }
	}

	fullRepresentation: FullRepresentation {}
}
