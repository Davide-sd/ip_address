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


function getIconSize(iconSize, compactRoot) {
    switch(iconSize) {
        case 1:
            return Kirigami.Units.iconSizes.small
        case 2:
            return Kirigami.Units.iconSizes.smallMedium
        case 3:
            return Kirigami.Units.iconSizes.medium
        case 4:
            return Kirigami.Units.iconSizes.large
        case 5:
            return Kirigami.Units.iconSizes.huge
        case 6:
            return Kirigami.Units.iconSizes.enormous
        default:
            return typeof(compactRoot) === "undefined" ? Kirigami.Units.iconSizes.medium : compactRoot.height
    }
}
