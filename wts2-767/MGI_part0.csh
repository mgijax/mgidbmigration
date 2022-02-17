#!/bin/csh -fx

#
# (part 0 running data cleanup)
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
echo '--- starting part 0' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- bad data in the presaturday backup being loaded into the test server
update GXD_GelLane set agemin = -1, agemax = -1 where agemin is null;

-- 130232 | \x13
update PRB_Strain set strain = 'Not Specified' where _strain_key = 130232;

-- for testing part 2
--Delete all but the desired experiment(s) from 'RNA Seq Load Experiment' MGI_Set. This sql deletes all experiment except for'E-ERAD-169'
delete from MGI_Setmember
where _Set_key = 1057
and _object_key != 6078

EOSQL
date | tee -a ${LOG}
