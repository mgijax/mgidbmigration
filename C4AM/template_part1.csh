#!/bin/csh -fx

#
# Migration for C4AM -- Sprint ????
# (part 1 - migration of existing data into new structures)

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration

setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

cd ${CWD}

###-------------------------------------------------###
###--- revisions to existing database components ---###
###-------------------------------------------------###

date | tee -a ${LOG}
echo "--- Table revisions" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* for tables with columns added or removed, we must:
 * 	1. rename the existing versions
 * 	2. create new versions
 * 	3. load data into new versions
 * 	4. drop renamed versions (from 1)
 * 	5. add indexes & keys to new versions
 */

/* rename tables which will have columns added or removed */

????

EOSQL

# create new versions of old tables
date | tee -a ${LOG}
echo "--- Adding new versions of old tables" | tee -a ${LOG}
${SCHEMA}/table/???? | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding permissions on re-created tables" | tee -a ${LOG}
${PERMS}/public/table/???? | tee -a ${LOG}
${PERMS}/curatorial/table/???? | tee -a ${LOG}

# create indexes and keys on re-created tables
date | tee -a ${LOG}
echo "--- indexes" | tee -a ${LOG}
${SCHEMA}/index/???? | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* populate new versions of tables */

update statistics ????
go

/* drop old versions of tables */

EOSQL

###------------------------------------------------------------------------###
###--- give up and re-do everything, since Sybase randomly loses pieces ---###
###------------------------------------------------------------------------###

date | tee -a ${LOG}
echo "--- Remove mgddbschema logs" | tee -a ${LOG}
${SCHEMA}/removelogs.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Run reconfig.csh" | tee -a ${LOG}
${SCHEMA}/reconfig.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Revoke perms" | tee -a ${LOG}
${PERMS}/all_revoke.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Grant perms" | tee -a ${LOG}
${PERMS}/all_grant.csh | tee -a ${LOG}

###----------------------------------###
###--- final datestamp and backup ---###
###----------------------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

#dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/sc/mgd.tr10273.backup | tee -a ${LOG}
#date | tee -a ${LOG}
#echo "--- Finished database dump" | tee -a ${LOG}
