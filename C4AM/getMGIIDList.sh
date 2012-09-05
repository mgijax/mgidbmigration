#!/bin/sh

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

cd `dirname $0`

echo "MGICONFIG: $MGICONFIG"
RPTFILE=MGIID_Symbol.txt

export RPTFILE

./getMGIIDList.py
