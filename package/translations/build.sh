# !/bin/sh
# Version: 5

# This script will convert the *.po files to *.mo files, rebuilding the package/contents/locale folder.
# Feature discussion: https://phabricator.kde.org/D5209
# Eg: contents/locale/fr_CA/LC_MESSAGES/plasma_applet_org.kde.plasma.eventcalendar.mo

if [ -z "$(which jq)" ]; then
	echo "[build] Error: jq command not found. Need to install jq"
	echo "[build] Running 'sudo apt install jq'"
	sudo apt install jq
	echo "[build] jq installation should be finished. Going back to installing translations."
fi

DIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
plasmoidName=`jq .KPlugin.Id $DIR/../metadata.json`
plasmoidName=$(echo "${plasmoidName:1:-1}")
website=`jq .KPlugin.Website $DIR/../metadata.json`
website=$(echo "${website:1:-1}")
bugAddress=$website
packageRoot=".." # Root of translatable sources

#---
if [ -z "$plasmoidName" ]; then
	echo "[build] Error: Couldn't read plasmoidName."
	exit
fi

if [ -z "$(which msgfmt)" ]; then
	echo "[build] Error: msgfmt command not found. Need to install gettext"
	echo "[build] Running 'sudo apt install gettext'"
	sudo apt install gettext
	echo "[build] gettext installation should be finished. Going back to installing translations."
fi

#---
echo "[build] Compiling messages"

catalogs=`find . -name '*.po'`
for cat in $catalogs; do
	echo "$cat"
	catLocale=`basename ${cat%.*}`
	msgfmt -o "${catLocale}.mo" "$cat"

	installPath="$DIR/../contents/locale/${catLocale}/LC_MESSAGES/${plasmoidName}.mo"

	echo "[build] Install to ${installPath}"
	mkdir -p "$(dirname "$installPath")"
	mv "${catLocale}.mo" "${installPath}"
done

echo "[build] Done building messages"

if [ "$1" = "--restartplasma" ]; then
	echo "[build] Restarting plasmashell"
	killall plasmashell
	kstart5 plasmashell
	echo "[build] Done restarting plasmashell"
else
	echo "[build] (re)install the plasmoid and restart plasmashell to test."
fi
