#!/bin/csh -fx

# Migration for TR12540/Disease Ontology
#
# mgidbmigration
# ei : tr12540 : ready
# mgipython : tr12540
#	: change 1005 -> 1020
#	: remove 1025
#	mgipython/model/mgd/all.py
#	mgipython/model/mgd/gxd.py
#
# pwi : tr12540
# pgmgddbschema : tr12450 : mrk_omim_cache is obsolete
# pgdbutilties  : tr12540 : sp/*OMIM* scripts are obsolete : ready
# mrkcacheload  : tr12540 : mrkomim is obsolete : ready
#
# rollupload (1005/1016, 1020/1023) : tr12540 : ready
# omim_hpoload (1018, 1024) : tr12540 : ready
# entrezgeneload (1006/1022) : tr12540 : ready
# vocload : tr12540 : ready
# doload : trunk : add genotype/note and edit reports
#
# qcreports_db : tr12540
# reports_db   : tr12540
# 
# loadadmin : add
# 	${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config
#	${MRKCACHELOAD}/mrkdo.csh
# loadadmin : remove
#	mrkcacheload/mrkomim.csh
#	doload
#
# migration to-do:
# existing data has migrated DO annotations
# delete existing OMIM annotations
# create "before" tab-delimited of existing DO annotations
# re-run the DO versions of annotation loads
# run cache tables
# run reports
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

#date | tee -a ${LOG}
#echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
#scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo
#scp bhmgiapp01:/data/downloads/data.omim.org/omim.txt.gz /data/downloads/data.omim.org
#scp bhmgiapp01:/data/downloads/compbio.charite.de/jenkins/job/hpo.annotations/lastStableBuild/artifact/misc

#
# update schema-version and public-version
#
#

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update MGI_dbinfo set schema_version = '6-0-10', public_version = 'MGI 6.010';

delete from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
delete from VOC_AnnotType where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
drop table MRK_OMIM_Cache;
update VOC_Vocab set name = 'DO Evidence Codes' where _Vocab_key = 43;


select count(*) from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
select count(*) from VOC_Annot where _AnnotType_key = 1020;
select count(*) from VOC_Annot where _AnnotType_key = 1021;
select count(*) from VOC_Annot where _AnnotType_key = 1022;
select count(*) from VOC_Annot where _AnnotType_key = 1023;
select count(*) from VOC_Annot where _AnnotType_key = 1024;
--select distinct _Term_key from VOC_Annot where _AnnotType_key = 1024;
select count(*) from MRK_DO_Cache;
select distinct annottype from VOC_Allele_Cache order by annottype;
select distinct annottype from VOC_Marker_Cache order by annottype;
select distinct annottype from VOC_Annot_Count_Cache order by annottype;

EOSQL

date | tee -a ${LOG}
echo 'step 1 : vocload/OMIM.config' | tee -a $LOG || exit 1
echo 'OMIMtermcheck.current.rpt : only report 1' | tee -a $LOG || exit 1
echo 'OMIM.animalmodel : turned off' | tee -a $LOG || exit 1
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a $LOG || exit 1
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 1a : doload (if not migrating on a Monday)' | tee -a $LOG || exit 1
#${DOLOAD}/bin/doload.sh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 2 : rollupload' | tee -a $LOG || exit 1
${ROLLUPLOAD}/bin/rollupload.sh | tee -a $LOG || exit 1
${ROLLUPLOAD}/bin/rollup_check.py ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 3 : omim_hpoload (OMIM format changes)' | tee -a $LOG || exit 1
${OMIMHPOLOAD}/bin/omim_hpoload.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 4 : entrezgeneload' | tee -a $LOG || exit 1
${ENTREZGENELOAD}/loadHuman.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 5 : mrkcacheload/mrkdo.csh' | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkdo.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 6 : qc reports' | tee -a $LOG || exit 1
#./qcnightly_reports.csh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 7 : VOC_Cache_Counts.csh/VOC_Cache_Markers.csh/VOC_Cache_Alleles.csh' | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Counts.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Markers.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Alleles.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#date | tee -a ${LOG}

${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Types_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Types_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/GXD_Genotype_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_create.object | tee -a $LOG || exit 1

# final database check
${PG_MGD_DBSCHEMADIR}/comments/comments.sh/ | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#
# create "after" tab-delimited files for each annotation type/without keys
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
select count(*) from VOC_Annot where _AnnotType_key = 1020;
select count(*) from VOC_Annot where _AnnotType_key = 1021;
select count(*) from VOC_Annot where _AnnotType_key = 1022;
select count(*) from VOC_Annot where _AnnotType_key = 1023;
select count(*) from VOC_Annot where _AnnotType_key = 1024;
--select distinct _Term_key from VOC_Annot where _AnnotType_key = 1024;
select distinct annottype from VOC_Allele_Cache order by annottype;
select distinct annottype from VOC_Marker_Cache order by annottype;
select distinct annottype from VOC_Annot_Count_Cache order by annottype;
EOSQL

echo "--- Finished" | tee -a ${LOG}

