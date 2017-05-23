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
# mgicacheload  : on trunk: TR12520/inferredfrom.py
#
# rollupload (1005/1016, 1020/1023) : tr12540 : ready
# omim_hpoload (1018, 1024) : tr12540 : ready
# entrezgeneload (1006/1022) : tr12540 : ready
# vocload : tr12540 : ready
# doload : trunk : add genotype/note and edit reports
# targetedalleleload (see TR12083, branch)
# emalload (see TR12083, trunk)
# htmpload : tr12540 (Sharon)
# annotload : tr12540 (Sharon)
#
# qcreports_db : tr12540
# reports_db   : tr12540
# 
# loadadmin:
#
#	add:
#	prod/sundaytasks.csh: after ${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config
# 	${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config
#
#	replace:
#	prod/dailytasks.csh:${MRKCACHELOAD}/mrkomim.csh
#	prod/saturdaytasks.csh:${MRKCACHELOAD}/mrkomim.csh
#	prod/sundaytasks.csh:${MRKCACHELOAD}/mrkomim.csh
#	with:
#	${MRKCACHELOAD}/mrkdo.csh
#
#	remove:
#	prod/sundaytasks.csh:${DOLOAD}/bin/do.sh
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
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#date | tee -a ${LOG}
#echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
#scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology
#scp bhmgiapp01:/data/downloads/data.omim.org/omim.txt.gz /data/downloads/data.omim.org
#scp bhmgiapp01:/data/downloads/compbio.charite.de/jenkins/job/hpo.annotations/lastStableBuild/artifact/misc/phenotype_annotation.tab /data/downloads/compbio.charite.de/jenkins/job/hpo.annotations/lastStableBuild/artifact/misc
#scp bhmgiapp01:/data/downloads/dmdd.org.uk/DMDD_MP_annotations.tsv /data/downloads/dmdd.org.uk
#scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk
#scp /mgi/all/wts_projects/12200/12291/RelationshipVocab4_26_17b /data/loads/mgi/rvload/input/RelationshipVocab.obo
#scp /mgi/all/wts_projects/12200/12291/RNAI_load4_26_2017.txt /data/loads/mgi/fearload/input/fearload.txt

#
# update schema-version and public-version
#
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update MGI_dbinfo set schema_version = '6-0-10', public_version = 'MGI 6.010';

drop view if exists mgd.MGI_NoteType_Nomen_View;
drop view if exists mgd.MGI_Note_Nomen_View;
drop view if exists mgd.MGI_RefType_Nomen_View;
drop view if exists mgd.MGI_Reference_Nomen_View;
drop view if exists mgd.MGI_SynonymType_Nomen_View;
drop view if exists mgd.MGI_Synonym_Nomen_View;
drop view if exists mgd.VOC_Term_NomenStatus_View;

drop table MRK_OMIM_Cache;
DROP FUNCTION IF EXISTS ALL_postMP(int,int,varchar);

delete from BIB_DataSet_Assoc where _dataset_key = 1006;
delete from BIB_DataSet where _dataset_key = 1006;

update VOC_Vocab set name = 'DO Evidence Codes' where _Vocab_key = 43;
update VOC_Term set term = 'DOVocAnnot' where _Term_key = 6738026;

delete from ACC_Accession where _LogicalDB_key = 15 and prefixPart is null;

delete from MGI_Statistic where _Statistic_key in (15,16);

EOSQL

#
# do all of the varchar->text changes first
#
date | tee -a ${LOG}
echo 'step 2a : varchars/radar' | tee -a $LOG || exit 1
/mgi/all/wts_projects/12000/12083/varchars/varcharsradar.csh | tee -a $LOG || exit 1
echo 'step 2b : varchars/mgd' | tee -a $LOG || exit 1
/mgi/all/wts_projects/12000/12083/varchars/varcharsmgd.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 3 : vocload/OMIM.config' | tee -a $LOG || exit 1
echo 'OMIMtermcheck.current.rpt : only report 1' | tee -a $LOG || exit 1
echo 'OMIM.animalmodel : turned off' | tee -a $LOG || exit 1
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 4 : doload' | tee -a $LOG || exit 1
${DOLOAD}/bin/do.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

#
# pre-processing reports
#
foreach i (omim*sh)
$i
end
foreach i (omim*log)
rm -rf $i.pre
mv $i $i.pre
end

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
select count(*) from VOC_Annot where _AnnotType_key = 1020;
select count(*) from VOC_Annot where _AnnotType_key = 1021;
select count(*) from VOC_Annot where _AnnotType_key = 1022;
select count(*) from VOC_Annot where _AnnotType_key = 1023;
select count(*) from VOC_Annot where _AnnotType_key = 1024;
--select distinct _Term_key from VOC_Annot where _AnnotType_key = 1024;
select count(*) from MRK_DO_Cache;
select count(*) from ACC_Accession where _LogicalDB_key = 15 and prefixPart is null;
--select distinct annottype from VOC_Allele_Cache order by annottype;
--select distinct annottype from VOC_Marker_Cache order by annottype;
--select distinct annottype from VOC_Annot_Count_Cache order by annottype;
EOSQL

#
# per Sharon
#
date | tee -a ${LOG}
echo 'step 5a : rvload' | tee -a $LOG || exit 1
echo 'step 5b : fearload' | tee -a $LOG || exit 1
${RVLOAD}/bin/rvload.sh | tee -a $LOG || exit 1
${FEARLOAD}/bin/fearload.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 6 : htmpload (sharon)' | tee -a $LOG || exit 1
${HTMPLOAD}/bin/runMpLoads.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

#
# note that ROLLUP load is skipped/not run in the DOLOAD
# this version is the DO version (no OMIM version)
date | tee -a ${LOG}
echo 'step 7 : rollupload' | tee -a $LOG || exit 1
${ROLLUPLOAD}/bin/rollupload.sh | tee -a $LOG || exit 1
${ROLLUPLOAD}/bin/rollup_check.py ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 8 : omim_hpoload (OMIM format changes)' | tee -a $LOG || exit 1
${OMIMHPOLOAD}/bin/omim_hpoload.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 9 : entrezgeneload' | tee -a $LOG || exit 1
${ENTREZGENELOAD}/loadHuman.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

#
# must be run *after* doload and omim_hpoload
#
date | tee -a ${LOG}
echo 'step 10 : mrkcacheload/mrkdo.csh' | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkdo.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 11 : ${ALLCACHELOAD}/allelecombination.csh' | tee -a $LOG || exit 1
${ALLCACHELOAD}/allelecombination.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 11 : qc reports' | tee -a $LOG || exit 1
#./qcnightly_reports.csh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 12 : VOC_Cache_Counts.csh/VOC_Cache_Markers.csh/VOC_Cache_Alleles.csh' | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Counts.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Markers.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Alleles.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#date | tee -a ${LOG}

#
# create "after" tab-delimited files for each annotation type/without keys
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
delete from VOC_AnnotType where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
select count(*) from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
select count(*) from VOC_Annot where _AnnotType_key = 1020;
select count(*) from VOC_Annot where _AnnotType_key = 1021;
select count(*) from VOC_Annot where _AnnotType_key = 1022;
select count(*) from VOC_Annot where _AnnotType_key = 1023;
select count(*) from VOC_Annot where _AnnotType_key = 1024;
--select distinct _Term_key from VOC_Annot where _AnnotType_key = 1024;
select count(*) from MRK_DO_Cache;
select count(*) from ACC_Accession where _LogicalDB_key = 15 and prefixPart is null;
--select distinct annottype from VOC_Allele_Cache order by annottype;
--select distinct annottype from VOC_Marker_Cache order by annottype;
--select distinct annottype from VOC_Annot_Count_Cache order by annottype;
EOSQL

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

echo 'step 13 : run statistics' | tee -a $LOG
${PG_DBUTILS}/bin/measurements/addMeasurements.csh | tee -a $LOG || exit 1

#
# post-processing reports
#
foreach i (omim*sh)
$i
end
foreach i (omim*log)
rm -rf $i.diff
diff $i $i.pre > $i.diff
end

# obsolete reports
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/OMIM/OMIM.animalmodel
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/OMIM/OMIM.clusters
rm -rf ${PUBREPORTDIR}/output/MGI_Geno_Disease.rpt
rm -rf ${PUBREPORTDIR}/output/MGI_Geno_NotDisease.rpt
rm -rf ${PUBREPORTDIR}/output/MGI_GeneOMIM.rpt
rm -rf ${PUBREPORTDIR}/output/mgimarkerfeed/*
rm -rf ${QCREPORTDIR}/output/ALL_OMIMNoMP.rpt
rm -rf ${QCREPORTDIR}/output/VOC_OMIMObsolete.sql.rpt

echo "--- Finished" | tee -a ${LOG}

