#!/bin/bash

SEARCHREPLACEDB=$(cat searchreplacedb.php)

read -r -d '' TEMPLATE <<- 'TEMPLATE'
$SEARCHREPLACEDB
TEMPLATE

echo $TEMPLATE > woopie

