#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

--select r._Refs_key, r.jnumID from BIB_Citation_Cache r, BIB_Workflow_Status s
--where r._Refs_key = s._Refs_key
--and s._Group_key = 31576665
--and s._Status_key in (31576672)
--and r.jnumID like 'J:11%'
--;

--    111080 | J:110000
--    111081 | J:110001
--    111082 | J:110002
--    111083 | J:110003


select b.* FROM BIB_Workflow_Status b
WHERE b._Refs_key = 111080
AND b._Group_key = 31576665
AND b._Status_key in (31576669, 31576672)
AND b._AssayType_key in (1,2,3,4,5,6,8,9)
;

select r._Refs_key, r.jnumID, s.*, t.term
from BIB_Citation_Cache r, BIB_Workflow_Status s, VOC_Term t
where r._Refs_key = s._Refs_key
and s._Group_key = 31576665
and s._Status_key in (31576672)
and r._Refs_key in (111080,111081,111082,111083)
and s._Status_key = t._Term_key
;

EOSQL
