#!/bin/csh -fx

#
# Add synonyms to Partner of relationship terms
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
echo '--- starting part 2' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG
    echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- Partner of synonyms
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 111279238,   13,      1033,    null,    'partner of', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 111279238,   13,      1032,    null,    'partner of', 1001, 1001, now(), now())
;
select setval('mgi_synonym_seq', (select max(_Synonym_key) from mgi_synonym))
;

EOSQL
date | tee -a ${LOG}

