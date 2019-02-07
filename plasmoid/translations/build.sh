#!/bin/sh

# This script will convert the *.po files to *.mo files, rebuilding the package/contents/locale folder.
# Feature discussion: https://phabricator.kde.org/D5209

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export METADATA="$DIR/../metadata.json"
# plasmoidName=`kreadconfig5 --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Name"`
plasmoidName=$(python -c "import os, json;print(json.load(open(os.environ['METADATA']))['KPlugin']['Id'])")
projectName="plasma_applet_${plasmoidName}" # project name

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

catalogs=`find po -name '*.po'`
for cat in $catalogs; do
	echo "$cat"
	catLocale=`basename ${cat%.*}`
	msgfmt -o "${catLocale}.mo" "$cat"

	installPath="$DIR/../contents/locale/${catLocale}/LC_MESSAGES/${projectName}.mo"

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
