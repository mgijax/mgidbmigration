#!/bin/csh -fx

#
# Migration for TR12223
#
# schema change
# schema migration
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

echo 'clipboard testing' | tee -a $LOG
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

--insert into MGI_Set values(1046, 13, 'EMAPA/Stage', 1, 1001, 1001, now(), now());

--insert into MGI_SetMember values(8587442, 1046, (select _Term_key from voc_term where _vocab_key = 90 and term = 'heart'), 1, 1001, 1001, now(), now());
--insert into MGI_SetMember values(8587443, 1046, (select _Term_key from voc_term where _vocab_key = 90 and term = 'eye'), 2, 1001, 1001, now(), now());

--insert into MGI_SetMember_EMAPA values(1, 8587442, 11, 1001, 1001, now(), now());
--insert into MGI_SetMember_EMAPA values(2, 8587442, 12, 1001, 1001, now(), now());
--insert into MGI_SetMember_EMAPA values(3, 8587442, 13, 1001, 1001, now(), now());
--insert into MGI_SetMember_EMAPA values(4, 8587442, 14, 1001, 1001, now(), now());
--insert into MGI_SetMember_EMAPA values(5, 8587443, 12, 1001, 1001, now(), now());
--insert into MGI_SetMember_EMAPA values(6, 8587443, 28, 1001, 1001, now(), now());

select t1.term, t2.stage 
from mgi_setmember s, mgi_setmember_emapa s2, voc_term t1, gxd_theilerstage t2
where s._set_key = 1046
and s._setmember_key = s2._setmember_key
and s._object_key = t1._term_key
and s2._Stage_key = t2._stage_key
order by s._set_key, s.sequenceNum, s2._Stage_key
;

select concat(s._Object_key||':'||s2._Stage_key), 'TS'||cast(t2.stage as varchar(5))||';'||t1.term as dbName
from mgi_setmember s, mgi_setmember_emapa s2, voc_term t1, gxd_theilerstage t2
where s._set_key = 1046
and s._setmember_key = s2._setmember_key
and s._object_key = t1._term_key
and s2._Stage_key = t2._stage_key
order by s._set_key, s.sequenceNum, s2._Stage_key
;

EOSQL
