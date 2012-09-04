#!/bin/sh

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

echo "MGICONFIG: $MGICONFIG"
RPTFILE=MGIID_Symbol.txt

export RPTFILE

./getMGIIDList.py
