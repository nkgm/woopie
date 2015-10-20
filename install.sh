#!/bin/bash

WOOPIE_RAW_REPO="https://raw.githubusercontent.com/skwp/dotfiles"

woopie_partial () {
  PARTIAL=$1
  if [[ -e $PARTIAL ]]; then
    cat "$PARTIAL"
  else
    curl -fsSL "$WOOPIE_RAW_REPO/master/$PARTIAL"
  fi
}

SEARCHREPLACEDB="$(php -w searchreplacedb.php | perl -p -e 's/^\s*<\?php\s*//s' | perl -p -e 's/\s*\?>\s*$//s')"

read -r -d '' TEMPLATE << TEMPLATE
#!/bin/bash

read -r -d '' SEARCHREPLACEDB_PHP<<'EOF'
$SEARCHREPLACEDB
EOF

woopie_searchreplacedb () {
  php -r "\$SEARCHREPLACEDB_PHP" "\$@"
}

###########################################################
#################### start _woopie-env ####################
###########################################################

$(woopie_partial _woopie-env)

###########################################################
##################### end _woopie-env #####################
###########################################################

###########################################################
#################### start _woopie-db #####################
###########################################################

$(woopie_partial _woopie-db)

###########################################################
##################### end _woopie-db ######################
###########################################################

###########################################################
################### start _woopie-apache ##################
###########################################################

$(woopie_partial _woopie-apache)

###########################################################
#################### end _woopie-apache ###################
###########################################################

###########################################################
##################### start _woopie #######################
###########################################################

$(woopie_partial _woopie)

###########################################################
###################### end _woopie ########################
###########################################################

TEMPLATE

WOOPIE_REMOTE=$(lsb_release -a 2>/dev/null | grep -iq ubuntu && echo true)

if [[ -n $WOOPIE_REMOTE ]]; then
  if [[ $(id -u) -ne 0 ]]; then
    echo "woopie requires sudo to run or install on a remote - exiting"
    exit 1
  fi
fi

INSTALL_PATH="${1:-/usr/local/bin}/woopie"
echo "Installing to $INSTALL_PATH"

echo "$TEMPLATE" > "$INSTALL_PATH"

if [[ -n $WOOPIE_REMOTE ]]; then
  chmod 700 "$INSTALL_PATH"
else
  chmod +x "$INSTALL_PATH"
fi

