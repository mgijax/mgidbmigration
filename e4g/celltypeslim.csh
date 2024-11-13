#!/bin/csh -fx

#
# cell type slim
# slimtermload
# loadadmin : add to daily/sunday tasks?
#

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select t._term_key, t.term, a.accid
from voc_term t, acc_accession a
where t._vocab_key = 102
and t.isobsolete = 0
and t._term_key = a._object_key
and a._logicaldb_key = 173
limit 5
;

insert into MGI_Set values(1060, 13, 'Cell Type Slim', 1, 1001, 1001, now(), now());

EOSQL

${SLIMTERMLOAD}/bin/slimtermload.sh celltypeslimload.config | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select u.login, t._term_key, t.term, a.accid
from mgi_setmember s, voc_term t, mgi_user u, acc_accession a
where s._set_key = 1060
and s._object_key = t._term_key
and s._createdby_key = u._user_key
and t._term_key = a._object_key
and a._logicaldb_key = 173
;
EOSQL

