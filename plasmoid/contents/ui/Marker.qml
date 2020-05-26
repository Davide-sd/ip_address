import QtQuick 2.2
import QtLocation 5.9

MapQuickItem{
    id: marker
    anchorPoint.x: marker.width / 4
    anchorPoint.y: marker.height
    z: my_map.z + 1
    sourceItem: Image{
        id: icon
        source: "../icons/marker.png"
        sourceSize.width: 40
        sourceSize.height: 40
    }
}