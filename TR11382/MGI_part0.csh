#!/bin/csh -fx

#
# Migration for TR11382
# (part 0 - load Sybase 15 from Sybase 12
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh
source ${MGI_DBUTILS}/Configuration

env | grep MGD
env | grep RADAR

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

#
# load Sybase 15 from Sybase 12.5 backup
#
#date | tee -a ${LOG}
#${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd.postpart0.backup | tee -a ${LOG}
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /backups/rohan/scrum-dog/radar.postpart0.backup | tee -a ${LOG}
#date | tee -a ${LOG}

#
# or use BCP to copy data out of Sybase 12.5
#
date | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/all_create.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
cd ${MGD_DBSCHEMADIR}/table
foreach i (W*_create.object)
set i=`basename $i _create.object`
${MGI_DBUTILS}/bin/bcpout.csh DEV_MGI mgd_dev $i ${DATADIR}
end
date | tee -a ${LOG}
exit 0

#
# delete/re-load indexes
# update statistics
#
date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/index_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/index_create.csh | tee -a ${LOG}
${RADAR_DBSCHEMADIR}/index/index_drop.csh | tee -a ${LOG}
${RADAR_DBSCHEMADIR}/index/index_create.csh | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateStatisticsAll.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${MGD_DBSCHEMADIR} | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateStatisticsAll.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} ${RADAR_DBSCHEMADIR} | tee -a ${LOG}
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

