#!/bin/csh -fx

#
# TR12172 - migration for moving slim terms from VOC_Term.abbreviation
#	to MGI_Set tables. Set VOC_Term.abbreviation and VOC_Term.sequencNum
#	to null
#	EMAPA _Vocab_key = 169
#	GO _Vocab_key = 31
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting TR12172 migration' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update VOC_Term
set sequenceNum = null, abbreviation = null
where _vocab_key = 90
and abbreviation is not null
;

update VOC_Term
set sequenceNum = null, abbreviation = null
where _vocab_key = 4
and abbreviation is not null
;

EOSQL

echo '---Running slim term loads ---'
${SLIMTERMLOAD}/bin/slimtermload.sh emapslimload.config
${SLIMTERMLOAD}/bin/slimtermload.sh goslimload.config
${SLIMTERMLOAD}/bin/slimtermload.sh mpslimload.config

date | tee -a ${LOG}

echo '--- finished TR12172 migration' | tee -a ${LOG}

