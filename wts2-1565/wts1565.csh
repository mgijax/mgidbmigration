#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--insert into mgi_user values(1667,316353,316350,'littriage_gxdht','littriage_gxdht',null,null,1000,1000,now(),now());

--15138501

SELECT distinct p.value
    FROM 
       GXD_HTExperiment e,
       ACC_Accession a,
       MGI_Property p
    WHERE e._curationstate_key = 20475421 /* Done */
    AND e._experiment_key = a._object_key
    AND a._mgitype_key = 42 /* ht experiment type */
    AND a.preferred = 1
    and e._experiment_key = p._object_key 
    and p._mgitype_key = 42
    and p._propertyterm_key = 20475430
    and not exists (select 1 from BIB_Citation_Cache c where p.value = c.pubmedid)
    order by p.value
;

EOSQL

$PYTHON download_pmc_papers.py | tee -a $LOG

date |tee -a $LOG

