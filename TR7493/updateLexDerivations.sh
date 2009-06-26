#!/bin/sh

#
#  If the MGICONFIG environment variable does not have a local override,
#  use the default "live" settings.
#

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

#  establish name of master config and source it
CONFIG_MASTER=${MGICONFIG}/master.config.sh

export CONFIG_MASTER

. ${CONFIG_MASTER}

cd `dirname $0`
LOG=`pwd`/updateLexDerivations.log
rm -f ${LOG}

echo ${MGD_DBSERVER} >>  ${LOG} 2>&1
echo ${MGD_DBNAME} >>  ${LOG} 2>&1

./updateLexDerivations.py >>  ${LOG} 2>&1

exit 0
