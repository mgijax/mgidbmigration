#!/bin/csh -fx

#
# Migration for TR11248
# (part 0 - load new SNP vocabularies/translations into MGD/Sybase
#
# on Sybase: load new vocabularies
# dbsnpload/bin/loadTranslations.sh
# dbsnpload/bin/loadVoc.sh
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

#
# make any necessary changes to the MGD/SNP Sybase databases on production
# make copies to /backups/rohan/scrum-dog
#
# only fxnClass will need to be re-loaded
# needs to run on Sybase only
#
# Determine whether to source the new common cshrc files based on the server.
#
switch (`uname -n`)
    case rohan:
    case firien:
	set doSybase="yes"
        breaksw
    default:
	set doSybase="no"
        breaksw
endsw

if ( ${doSybase} == "yes" ) then

#
# may need to load Sybase/MGD backup into scrum-dog
# may need to load Sybase/SNP backup into scrum-dog
#
date | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} /backups/rohan/scrum-dog/mgd.backup
#${MGI_DBUTILS}/bin/load_db.csh ${SNPEXP_DBSERVER} ${SNPEXP_DBNAME} /backups/rohan/scrum-dog/snp.backup
date | tee -a ${LOG}

# load new SNP Function Class
# load new SNP handler
date | tee -a ${LOG}
${DBSNPLOAD}/bin/loadVoc.sh | tee -a ${LOG}
date | tee -a ${LOG}

# load new Translations (fxnClass.goodbad)
date | tee -a ${LOG}
${DBSNPLOAD}/bin/loadTranslations.sh | tee -a ${LOG}
date | tee -a ${LOG}

# make backup of mgd with snp changes
date | tee -a ${LOG}
${MGI_DBUTILS}/bin/dump_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} /backups/rohan/scrum-dog/mgd-TR11248.backup
date | tee -a ${LOG}

echo "--- Finished Sybase" | tee -a ${LOG}
exit 0

endif

#
# Export Sybase SNP database to Postgres.
# uses SNPEXP variables
#
date | tee -a ${LOG}
${EXPORTER}/bin/exportDB.sh snp postgres | tee -a ${LOG}
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${LOG}
date | tee -a ${LOG}

# can do this manually using ei/translation module
${DBSNPLOAD}/bin/loadTranslations.sh | tee -a ${LOG}

# this runs on postgres; snp_population, snp_subsnp_strainallele
${DBSNPLOAD}/bin/snpPopulation.sh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

