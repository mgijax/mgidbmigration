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

drop table DP_IMSR
go

drop table MGI_IMSR
go

drop table QC_IMSR_AllelesNotInMGI
go

drop table QC_IMSR_GenesNotInMGI
go

drop table QC_IMSR_MissingColumns
go

drop table QC_IMSR_StockIDsNotInMGI
go

drop table QC_IMSR_StrainNamesNotInMGI
go

drop table QC_IMSR_StrainsWithIllOrNoMut
go

drop table QC_IMSR_StrainsWithIllOrNoStat
go

drop table QC_IMSR_StrainsWithIllOrNoType
go

drop table WRK_IMSR_Alleles
go

drop table WRK_IMSR_Genes
go

drop table WRK_IMSR_Strains
go

drop table WRK_IMSR_Synonym
go

end

EOSQL
date | tee -a ${LOG}

${RADAR_DBSCHEMADIR}/procedure/APP_EIcheck_drop.object | tee -a ${LOG}
${RADAR_DBSCHEMADIR}/procedure/APP_EIcheck_create.object | tee -a ${LOG}

${RADAR_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${RADAR_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${RADAR_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

