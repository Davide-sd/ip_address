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
 
function getIPdata(successCallback, failureCallback) {
    // append /json to the end to force json data response
    var getUrl = "https://ipinfo.io/json"

    try {
        var request = new XMLHttpRequest()
        request.onreadystatechange = function () {
            if (request.readyState !== XMLHttpRequest.DONE) {
                return
            }

            if (request.status !== 200) {
                failureCallback(request)
                return
            }

            var jsonData = JSON.parse(request.responseText)
            successCallback(jsonData)
        }
        request.open('GET', getUrl)
        request.send()

        return request
    }
    catch (err) {
        return null
    }
}


function getIconSize(iconSize, compactRoot) {
    switch(iconSize) {
        case 1:
            return units.iconSizes.tiny
        case 2:
            return units.iconSizes.small
        case 3:
            return units.iconSizes.smallMedium
        case 4:
            return units.iconSizes.medium
        case 5:
            return units.iconSizes.large
        case 6:
            return units.iconSizes.huge
        case 7:
            return units.iconSizes.enormous
        default:
            return typeof(compactRoot) === "undefined" ? units.iconSizes.medium : compactRoot.height
    }
}
