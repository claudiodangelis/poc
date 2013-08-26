#!/bin/bash

# Creazione profilo temporaneo
firefox -CreateProfile xxxeldozoxxx

BFOLDER=`ls -l /usr/bin | grep firefox | sed -nr 's|.* -> (.*)$|\1|p'`
BROWSER=`echo $BFOLDER | sed -nr 's|.*/(.*)$|\1|p'`

# Abilitazione del flag `browser.dom.window.dump.enabled`
echo 'user_pref("browser.dom.window.dump.enabled", true);' \
>>~/.mozilla/$BROWSER/*.xxxeldozoxxx/prefs.js

TMP_FILE="/tmp/$(tr -dc "[:alpha:]" < /dev/urandom | head -c 4)"
touch $TMP_FILE
if [[ $(ps cax | grep "$BROWSER") != "" ]]; then
    echo -e "$BROWSER e' in esecuzione.\nPremere [Invio] per chiudere" \
    "tutte le finestre, oppure [CTRL + C] per uscire"
    while [[ true ]]; do
        read INPUT_UTENTE
        if [[ $INPUT_UTENTE == "" ]]; then
            killall $BROWSER
            break;
        fi
    done
fi
firefox -P "xxxeldozoxxx" index.html > $TMP_FILE 2>&1 &
tail -f $TMP_FILE | grep -m 1 "EOF" | xargs echo "" >> $TMP_FILE \;
killall $BROWSER
IP=$(cat $TMP_FILE | grep -m 1 __IP__ | awk -F'=' '{print $2}')
ping -c 5  $IP
rm $TMP_FILE

# Distruzione profilo temporaneo
rm -rf ~/.mozilla/$BROWSER/*.xxxeldozoxxx
PROFILE_START=$(expr $(cat ~/.mozilla/$BROWSER/profiles.ini | \
    grep -n Name=xxxeldozoxxx | awk -F':' '{print $1}') - 1)

PROFILE_END=$(expr $PROFILE_START + 4)

sed -i".bak" "$PROFILE_START,$PROFILE_END d" ~/.mozilla/$BROWSER/profiles.ini

rm ~/.mozilla/$BROWSER/profiles.ini.bak
