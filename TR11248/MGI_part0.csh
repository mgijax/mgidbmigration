#!/bin/csh -fx

#
# Migration for TR11248
# (part 0 - load new SNP vocabularies/translations into MGD/Sybase
#
# on Sybase: load new vocabularies
# dbsnpload/bin/loadTranslations.sh
# dbsnpload/bin/loadVoc.sh
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    #${MGI_DBUTILS}/bin/loadDB.csh ${MGD_DBSERVER} ${MGD_DBNAME} ...
    date | tee -a ${LOG}
else
    echo "--- Using existing database:  ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

cat - <<EOSQL | ${MGD_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}

EOSQL

date | tee -a ${LOG}

${DBSNPLOAD}/bin/loadVoc.sh | tee -a ${LOG}
${DBSNPLOAD}/bin/loadTranslations.sh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

