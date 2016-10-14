#!/bin/csh -fx

#
# Migration for TR12427/Disease Ontology
#
# mgidbmigration : cvs/trunk : 
# pgmgddbschema : git tr12427
# vocload : git tr12427
# pgdbutilities : git tr12427
# mgicacheload : git tr12427
# ei : git tr12427
# reports_db : git need to make tr12427
# mirror_wget-6-0-6-4
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump

date | tee -a ${LOG}
echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package raw.githubusercontent.com.diseaseontology | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package data.omim.org.omim | tee -a $LOG || exit 1

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update MGI_dbinfo set schema_version = '6-0-8', public_version = 'MGI 6.08';

delete from MGI_Synonym where _synonymtype_key = 1031;
delete from MGI_SynonymType where _synonymtype_key = 1031;

--insert into VOC_AnnotType values (1020, 12, 125, 43, 53, 'DO/Genotype', now(), now());
--insert into VOC_AnnotType values (1021, 11, 125, 85, 84, 'DO/Allele', now(), now());
--insert into VOC_AnnotType values (1022, 2, 125, 43, 53, 'DO/Human Marker', now(), now());
--insert into VOC_AnnotType values (1023, 2, 125, 2, 53, 'DO/Marker (Derived)', now(), now());
--insert into VOC_AnnotType values (1024, 13, 106, 107, 108, 'HPO/DO', now(), now());

--insert into ACC_LogicalDB values (192, 'EFO', 'Environmental Factor Ontology', 1, 1001, 1001, now(), now());
--insert into ACC_LogicalDB values (193, 'KEGG', 'KEGG Pathway Database', 1, 1001, 1001, now(), now());
--insert into ACC_LogicalDB values (194, 'MESH', 'MESH (Medical Subject Headings)', 1, 1001, 1001, now(), now());
--insert into ACC_LogicalDB values (195, 'NCI', 'NCI Thesaurus', 1, 1001, 1001, now(), now());
--insert into ACC_LogicalDB values (196, 'ORDO', 'Orphan Disease Ontology', 1, 1001, 1001, now(), now());

update ACC_LogicalDB set name = 'HP' where _LogicalDB_key = 180;

--
-- non-preferred OMIM ids (44) can be deleted
--

select * from ACC_Accession 
where _MGIType_key = 13
and _LogicalDB_key = 15
and preferred = 0
;

delete from ACC_Accession 
where _MGIType_key = 13
and _LogicalDB_key = 15
and preferred = 0
;

select accID
from ACC_Accession
where _MGIType_key = 13
and _LogicalDB_key = 15
and accID not like 'OMIM:%'
;

update ACC_Accession
set accID = 'OMIM:' || accID, prefixPart = 'OMIM:'
where _MGIType_key = 13
and _LogicalDB_key = 15
and accID not like 'OMIM:%'
;

select accID
from ACC_Accession
where _MGIType_key = 13
and _LogicalDB_key = 15
and accID not like 'OMIM:%'
;

delete from VOC_Annot where _AnnotType_key in (1020, 1021, 1022, 1023, 1024);

EOSQL

#
# obsolete
#
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/OMIM/OMIM.clusters.*

date | tee -a ${LOG}
echo 'step 1 : vocload/OMIM.config' | tee -a $LOG || exit 1
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 2 : vocload/DO.config' | tee -a $LOG || exit 1
${VOCLOAD}/runOBOFullLoad.sh DO.config | tee -a $LOG || exit 1
#${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 3 : omim-to-DO annotation translation' | tee -a $LOG || exit 1
${DOLOAD}/bin/do.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 4 : run omim cache' | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkomim.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 5 : qc reports' | tee -a $LOG || exit 1
./qcnightly_reports.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 6 : adding cache key to cache tables (TR12083)' | tee -a $LOG || exit 1
/mgi/all/wts_projects/12000/12083/caches/caches.csh | tee -a $LOG || exit 1
# testing only : remove as ${PG_DBUTILS}/sp/MGI_deletePrivateData.csh runs this when running public migration
#${PG_DBUTILS}/sp/VOC_Cache_Counts.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG
#${PG_DBUTILS}/sp/VOC_Cache_Markers.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG
#${PG_DBUTILS}/sp/VOC_Cache_Alleles.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 7 : TR11083/nomenclature merge' | tee -a $LOG || exit 1
#/mgi/all/wts_projects/11000/11083/tr11083.csh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

# final database check
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#
#EOSQL

echo "--- Finished" | tee -a ${LOG}

