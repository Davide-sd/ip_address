> Inspired by [Zren's plasma-applet-dailyforecast](https://github.com/Zren/plasma-applet-dailyforecast/tree/master/package/translate)

With KDE Frameworks v5.37 and above, translations are bundled with the *.plasmoid file downloaded from the store.

## Install Translations

Go to `~/.local/share/plasma/plasmoids/com.github.davide-sd.ip_address/translate/` and run `sh ./build --restartplasma`.

## New Translations

1. Copy the `po/template.pot` file and name it your locale's code (Eg: `de.po`) with the extension `.po`.
2. Fill out all the `msgstr ""`.
3. Make a pull request.

## Scripts

* `./merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `./build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the *.plasmoid without needing the user to manually install them.

## Links

* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems

## Status

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |      27 |       |
| en       |   27/27 |  100% |
| it       |   27/27 |  100% |
| nl_NL | 27/27 | 100% |
