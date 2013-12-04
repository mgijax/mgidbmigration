#!/bin/csh -f

#
###----------------------###
###--- initialization ---###
###----------------------###

setenv MGICONFIG /usr/local/mgi/live/mgiconfig
source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

echo "****MGD" | tee -a ${LOG}
foreach i (${MGD_DBSCHEMADIR}/table/*create.object)
setenv table `basename ${i} _create.object`
echo $table | tee -a ${LOG}
isql -SMGISYDEV01 -Umgd_dbo -Dmgd -w200 -Popenup <<EOSQL | tee -a ${LOG}
select count(*) from ${table}
go
EOSQL
psql -hmgi-testdb4 -dpub_dev -Umgd_dbo --command "select count(*) from mgd.${table}" | tee -a ${LOG}
end

echo "****RADAR" | tee -a ${LOG}
foreach i (${RADAR_DBSCHEMADIR}/table/*create.object)
setenv table `basename ${i} _create.object`
echo $table | tee -a ${LOG}
isql -SMGISYDEV01 -Umgd_dbo -Dradar -w200 -Popenup <<EOSQL | tee -a ${LOG}
select count(*) from ${table}
go
EOSQL
psql -hmgi-testdb4 -dpub_dev -Umgd_dbo --command "select count(*) from radar.${table}" | tee -a ${LOG}
end

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

