#!/bin/csh -fx

#
# Add synonyms to QTL relationship terms
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

--Candidate gene
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105563920,   13,      1032,    null,    'has candidate', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105563920,   13,      1033,    null,    'is candidate for', 1001, 1001, now(), now())
;

--QTL-QTL
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741859, 13,      1032,    null,    'diverging genetic interaction', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741859, 13,      1033,    null,    'diverging genetic interaction', 1001, 1001, now(), now())
;

insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105813848, 13,      1032,    null,    'undefined genetic interaction', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105813848, 13,      1033,    null,    'undefined genetic interaction', 1001, 1001, now(), now())
;

insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741853, 13,      1032,    null,    'synthetic', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741853, 13,      1033,    null,    'synthetic', 1001, 1001, now(), now())
;

insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741854, 13,      1032,    null,    'enhancement', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741854, 13,      1033,    null,    'enhancement', 1001, 1001, now(), now())
;

insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741855, 13,      1032,    null,    'suppression', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741855, 13,      1033,    null,    'suppression', 1001, 1001, now(), now())
;

insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741856, 13,      1032,    null,    'neutral', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741856, 13,      1033,    null,    'neutral', 1001, 1001, now(), now())
;

insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741857, 13,      1032,    null,    'genetic epistasis (sensu Bateson)', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741857, 13,      1033,    null,    'genetic epistasis (sensu Bateson)', 1001, 1001, now(), now())
;

insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741858, 13,      1032,    null,    'converging genetic interaction', 1001, 1001, now(), now())
;
insert into mgi_synonym values(nextval('mgi_synonym_seq'), 105741858, 13,      1033,    null,    'converging genetic interaction', 1001, 1001, now(), now())
;

select setval('mgi_synonym_seq', (select max(_Synonym_key) from mgi_synonym))
;

EOSQL
date | tee -a ${LOG}

