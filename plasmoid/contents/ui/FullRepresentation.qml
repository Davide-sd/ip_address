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

import QtLocation 5.9
import QtPositioning 5.9

import "js/index.js" as ExternalJS


Item {
    id: fullRoot

    Layout.preferredWidth: grid.width
    Layout.preferredHeight: grid.height

    readonly property bool layoutRow: plasmoid.configuration.layoutRow
    readonly property bool showHostname: plasmoid.configuration.showHostname
    readonly property int mapSize: plasmoid.configuration.mapSize
    readonly property int mapZoomLevel: plasmoid.configuration.mapZoomLevel

    property string mapLink: "https://www.openstreetmap.org/#map=" + mapZoomLevel + "/" + latitude + "/" + longitude

    PlasmaCore.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		function exec(cmd) {
			connectSource(cmd)
		}
		signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }

    GridLayout {
        id: grid
        rowSpacing: 10
        columnSpacing: 10
        flow: layoutRow ? GridLayout.LeftToRight : GridLayout.TopToBottom

        Item {
            width: mapSize
            height: width
            anchors.horizontalCenter: layoutRow ? undefined : parent.horizontalCenter

            Plugin {
                id: mapPlugin
                name: "osm" // "mapboxgl", "esri", ...
                // locales: ["it_IT","en_US"]

                // PluginParameter { name: "osm.useragent"; value: "My great Qt OSM application" }
                // PluginParameter { name: "osm.mapping.host"; value: "http://osm.tile.server.address/" }
                // PluginParameter { name: "osm.mapping.copyright"; value: "All mine" }
                // PluginParameter { name: "osm.routing.host"; value: "http://osrm.server.address/viaroute" }
                // PluginParameter { name: "osm.geocoding.host"; value: "http://geocoding.server.address" }
            }

            Map {
                anchors.fill: parent
                // width: mapSize
                // height: width
                plugin: mapPlugin
                center: jsonData !== undefined ? QtPositioning.coordinate(latitude, longitude) : QtPositioning.coordinate(41.8902, 12.4922) // Rome
                zoomLevel: mapZoomLevel
            }
        }

        GridLayout {
            id: labelsContainer
            flow: GridLayout.LeftToRight
            columns: 2
            Layout.minimumWidth: 300
            Layout.maximumWidth: 300
            Layout.preferredWidth: 300

            QtControls.Label {
                text: i18n("IP address:")
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.ip : "N/A"
            }

            QtControls.Label {
                text: i18n("Country:")
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.country : "N/A"
            }

            QtControls.Label {
                text: i18n("Region:")
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.region : "N/A"
            }

            QtControls.Label {
                text: i18n("Postal Code:")
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.postal : "N/A"
            }

            QtControls.Label {
                text: i18n("City:")
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.city : "N/A"
            }

            QtControls.Label {
                text: i18n("Coordinates:")
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.loc : "N/A"
            }

            QtControls.Label {
                text: i18n("Hostname:")
                visible: showHostname
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.hostname : "N/A"
                visible: showHostname
            }

            QtControls.Label {
                Layout.columnSpan: 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: theme.highlightColor
                font.bold: true
                wrapMode: Text.Wrap
                text: jsonData !== undefined ? i18n("Open map in the browser") : "N/A"
                visible: jsonData !== undefined

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: false
                    onClicked: Qt.openUrlExternally(mapLink)
                }
            }
        }
    }
}
