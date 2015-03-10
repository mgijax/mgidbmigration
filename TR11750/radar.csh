#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
       setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

# COMMENT OUT BEFORE RUNNING ON PRODUCTION
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /backups/rohan/scrum-dog/radar.backup

date | tee -a ${LOG}

/usr/local/mgi/live/dbutils/radar/radardbschema/objectCounter.sh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $RADAR_DBSERVER $RADAR_DBNAME $0 | tee -a ${LOG}

use $RADAR_DBNAME
go

-- obsolete

drop procedure APP_EIcheck
go

drop index MGI_Columns.index_modification_date
go

drop index MGI_Columns.index_creation_date
go

drop index MGI_Tables.index_modification_date
go

drop index MGI_Tables.index_creation_date
go

end

EOSQL
date | tee -a ${LOG}

${RADAR_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${RADAR_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${RADAR_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

