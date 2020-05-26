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
1. Custom Colors for text and links
    DONE, TESTED
2. Ip v6
3. Set a default value for what an IP address should be. Set a red
    icon if the actual IP is different from the default. Should we 
    send a notification too?
4. Button in the tooltip to send a new request to ip-info... An update
    button.
    DONE, UNTESTED. 
5. Update option in the context menu (right click menu)
    DONE, UNTESTED. 
6. After loading the widgets, go to settings -> Check "Show Hostname"
    -> Click OK -> The plugin freeze, no errors, no messages... WTF?

7. Notification when cliccking over an info and copying it into clipboard
    DONE, TESTED.
8. Add marker to the map when opening it on the browser
    DONE, TESTED.
9. Center the map when opening full representation
10. Add Marker to the center of the minimap
    DONE, PARTIALLY TESTED
11. Look for 'vpn' or 'tun' in the output of command nmcli c show --active, 
    verify that VPN is up.
    nmcli c show --active | grep -E "vpn|tun"
    DONE, partially tested

Dependencies:
    libnotify-bin: this is for showing notifications when clicking links, thus copying
        the content of the link to the clipboard.
        sudo apt install libnotify-bin
    
    nmcli: this is part of the network-manager package. It should already be
    installed in Ubuntu. Don't know about other distros (let me know in the comments).

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
    readonly property bool useLabelThemeColor: plasmoid.configuration.useLabelThemeColor
    readonly property string labelColor: plasmoid.configuration.labelColor
    readonly property bool useLinkThemeColor: plasmoid.configuration.useLinkThemeColor
    readonly property string linkColor: plasmoid.configuration.linkColor

    // property string mapLink: "https://www.openstreetmap.org/#map=" + mapZoomLevel + "/" + latitude + "/" + longitude
    property string mapLink: "https://www.openstreetmap.org/?mlat=" + latitude + "&mlon=" + longitude + "#map=" + mapZoomLevel + "/" + latitude + "/" + longitude

    function action_Update() {
        debug_print("### [action_Update]")
        reloadData()
        abortTooLongConnection()
        executable.exec("notify-send 'Done'")
    }

    function addMarker(latitude, longitude) {
        debug_print("### addMarker init")
        var component = Qt.createComponent("Marker.qml")
        if( component.status != Component.Ready )
        {
            if( component.status == Component.Error )
                debug_print("### Error creating Marker:"+ component.errorString() );
            return; // or maybe throw
        }
        // removing previous markers
        my_map.clearMapItems()
        var item = component.createObject(
                        grid, {
                            coordinate: QtPositioning.coordinate(latitude, longitude)
                        })
        my_map.addMapItem(item)
        debug_print("### Added Marker: lat=" + latitude + "; long=" + longitude)
    }

    Component.onCompleted: {
        debug_print("### [Component.onCompleted -> calling Update action")
        // init contextMenu
        // action_Update()
        plasmoid.setAction('Update', i18n('Update Infos'), 'reload')
        debug_print("### [Component.onCompleted -> added Update action")
        plasmoid.setActionSeparator("My Separato")
        debug_print("### [Component.onCompleted -> added Separator")
    }

    

    GridLayout {
        id: grid
        rowSpacing: 10
        columnSpacing: 10
        flow: layoutRow ? GridLayout.LeftToRight : GridLayout.TopToBottom

        Item {
            width: mapSize
            height: width
            // // Fix issue https://github.com/Davide-sd/ip_address/issues/8
            Layout.alignment: layoutRow ? undefined : Qt.AlignHCenter
            // anchors.horizontalCenter: layoutRow ? undefined : parent.horizontalCenter

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
                id: my_map
                anchors.fill: parent
                // width: mapSize
                // height: width
                plugin: mapPlugin
                // center: jsonData !== undefined ? QtPositioning.coordinate(latitude, longitude) : QtPositioning.coordinate(41.8902, 12.4922) // Rome
                center: {
                    if (jsonData !== undefined) {
                        addMarker(latitude, longitude)
                        return QtPositioning.coordinate(latitude, longitude)
                    }
                    addMarker(41.8902, 12.4922)
                    returnQtPositioning.coordinate(41.8902, 12.4922) // Rome
                }
                zoomLevel: mapZoomLevel

                // Component.onCompleted: addMarker(41.8902, 12.4922)
                // Component.onCompleted: jsonData !== undefined ? addMarker(latitude, longitude) : addMarker(41.8902, 12.4922) // Rome
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
                color: useLabelThemeColor ? theme.textColor : labelColor
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.ip : "N/A"
            }

            QtControls.Label {
                text: i18n("Country:")
                color: useLabelThemeColor ? theme.textColor : labelColor
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.country : "N/A"
            }

            QtControls.Label {
                text: i18n("Region:")
                color: useLabelThemeColor ? theme.textColor : labelColor
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.region : "N/A"
            }

            QtControls.Label {
                text: i18n("Postal Code:")
                color: useLabelThemeColor ? theme.textColor : labelColor
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.postal : "N/A"
            }

            QtControls.Label {
                text: i18n("City:")
                color: useLabelThemeColor ? theme.textColor : labelColor
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.city : "N/A"
            }

            QtControls.Label {
                text: i18n("Coordinates:")
                color: useLabelThemeColor ? theme.textColor : labelColor
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.loc : "N/A"
            }

            QtControls.Label {
                text: i18n("Hostname:")
                color: useLabelThemeColor ? theme.textColor : labelColor
                visible: showHostname
            }

            LabelDelegate {
                text: jsonData !== undefined ? jsonData.hostname : "N/A"
                visible: showHostname
            }

            QtControls.Label {
                Layout.columnSpan: 2
                // Fix issue https://github.com/Davide-sd/ip_address/issues/8
                Layout.alignment: Qt.AlignHCenter
                // anchors.horizontalCenter: parent.horizontalCenter
                color: useLinkThemeColor ? theme.highlightColor : linkColor
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

            QtControls.Button {
                Layout.columnSpan: 2
                // Fix issue https://github.com/Davide-sd/ip_address/issues/8
                Layout.alignment: Qt.AlignHCenter
                // anchors.horizontalCenter: parent.horizontalCenter
                Layout.preferredWidth: parent.width
                text: i18n("Update Infos")
                onClicked: {
                    debug_print("### ['Update Infos' onClicked]")
                    reloadData()
                    abortTooLongConnection()
                }
            }
        }
    }
}
