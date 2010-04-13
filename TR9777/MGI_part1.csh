#!/bin/csh -fx

# Migration for TR9777 -- uniprot load

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
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
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.33" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-3-0" | tee -a ${LOG}

cd ${CWD}

###--------------------------------------------###
###--- run *old* egload/swissload deletions ---###
###--- change *swissload* login to *uniprotload* ---###
###--------------------------------------------###

date | tee -a ${LOG}
echo "--- Run *old* egload/swissload deletions" | tee -a ${LOG}
echo "--- Change login name *swissload* to *uniprotload*" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* see old egload/sql/MGDdelete.sql */

select r._Accession_key
into #toDeleteSP
from ACC_AccessionReference r, ACC_Accession a, MRK_Marker m
where r._Refs_key = 53672
and r._Accession_key = a._Accession_key
and a._LogicalDB_key = 9
and a._MGIType_key = 2
and a._Object_key = m._Marker_key
and m._Organism_key = 1
go

create index idx1 on #toDeleteSP(_Accession_key)
go

delete ACC_AccessionReference
from #toDeleteSP d, ACC_AccessionReference r
where d._Accession_key = r._Accession_key
go

delete ACC_Accession
from #toDeleteSP d, ACC_Accession r
where d._Accession_key = r._Accession_key
go

delete SEQ_Marker_Cache
from SEQ_Marker_Cache c
where c._Refs_key = 53672
and c._Organism_key = 1
go

/* MGI_User.login where _User_key = 1303, 1442 */

update MGI_User 
set login = 'uniprotload', 
    name = 'UniProt Assocation Load' 
where _User_key = 1303
go

update MGI_User 
set login = 'uniprotload_assocload', 
    name = 'UniProt Assocation Load' 
where _User_key = 1442
go

EOSQL

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
