#!/bin/csh -fx

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
echo '--- starting part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

#
# download the latest geo experiment and sample files
#
date | tee -a ${LOG}
echo "downloading the latest geo experiment files" | tee -a ${LOG}
${GXDHTLOAD}/bin/mirror_geo_exp.sh

date | tee -a ${LOG}
echo "updating evaluation state of experiments that have no raw samples" | tee -a ${LOG}

#
# update experiment evaluation state to 'Not Evaluated' for all
# experiments loaded since 2/19/2022
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
-- get all GEO experiments created on or after 2/19/2022
select e._experiment_key
    into temporary table toUpdate
    from gxd_htexperiment e, acc_accession a
    where e.creation_date >= '2/19/2022'
    and e._experiment_key = a._object_key
    and a._logicaldb_key = 190 -- GEO Series
    and a._mgitype_key = 42 -- HT Experiment
;

create index idx2 on toUpdate(_experiment_key)
;

-- log what we are updating
select * from toUpdate;
;

update gxd_htexperiment 
    set _evaluationstate_key = 100079348 -- 'Not Evaluated'
from toUpdate u
    where gxd_htexperiment._experiment_key = u._experiment_key
;

-- select the 'Not Evaluated' count now in the database
select count(*)
from gxd_htexperiment
where _evaluationstate_key = 100079348
;

EOSQL
date | tee -a ${LOG}

