#!/bin/csh -fx

#
# Migration for TR12349
#
# mgidbmigration : cvs/trunk
# pgmgddbschema : branch
# mirror_wget : trunk
# goload : trunk
# annotload : trunk
# assocload : trunk
# proisoformload : trunk
# ei : trunk
# qcreports_db : trunk : GO_GPI_verify.py
# reports_db : branch
# pgdbutilities : trunk : sp/VOC_Cache_Other_Markers.csh
# mgicacheload : trunk : inferredfrom.gomousenoctua : installed on production
# lib_py_report : cvs/trunk
# lib_py_dataload : cvs/trunk
#
# obsolete:
# gaf_fprocessor
#
# loadadmin
# remove as these are now called from goload/godaily.sh and goload/go.sh
# remove prod/dailytasks.csh:${MGICACHELOAD}/go_annot_extensions_display_load.csh
# remove prod/dailytasks.csh:${MGICACHELOAD}/go_isoforms_display_load.csh
# remove prod/sundaytasks.csh:${MGICACHELOAD}/go_annot_extensions_display_load.csh
# remove prod/sundaytasks.csh:${MGICACHELOAD}/go_isoforms_display_load.csh
# add: prod/dailytasks.csh: ${GOLOAD}/godaily.sh
#
# mirror_wget things to do:
#
# cd /data/downloads
# ln -s ./build.berkeleybop.org/job/export-lego-to-legacy/lastSuccessfulBuild/artifact/legacy/gpad/production/mgi.gpad go_noctua
#
# mirror_wget : ftp.geneontology.org.goload : remove goa_human
# change
# /data/downloads/goa -> ./ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
# to
# /data/downloads/goa -> ./ftp.ebi.ac.uk/pub/databases/GO/goa
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
${MIRROR_WGET}/download_package ftp.pir.georgetown.edu.proisoform | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package pir.georgetown.edu.proisoform | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package build.berkeleybop.org.goload | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package build.berkeleybop.org.gpad.goload | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package ftp.geneontology.org.goload | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'step 2 : orc ids' | tee -a $LOG || exit 1
./orcids.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

# do all schema/stored procedure changes before the loads are run
${PG_MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_alleleWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_deleteWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_mergeWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MRK_simpleWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/VOC_Allele_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/VOC_Annot_Count_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/VOC_Marker_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Allele_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Allele_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Annot_Count_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Annot_Count_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Marker_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Marker_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Allele_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Annot_Count_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Marker_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Allele_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Annot_Count_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Marker_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/VOC_Allele_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/VOC_Annot_Count_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/VOC_Marker_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/NOM_Marker_Valid_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/NOM_Marker_Valid_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/VOC_Allele_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/VOC_Annot_Count_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/VOC_Marker_Cache_create.object | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update MGI_dbinfo set schema_version = '6-0-6', public_version = 'MGI 6.06';

delete from VOC_Vocab where _Vocab_key = 111;
delete from ACC_LogicalDB where _LogicalDB_key = 182;
select distinct annottype from VOC_Marker_Cache order by annottype;

select * from ACC_insertNoChecks (1001,156949,'GO_REF:0000096',185,'Reference',-1,0,1);
select * from ACC_insertNoChecks (1001,162524,'GO_REF:0000033',185,'Reference',-1,0,1);
select * from ACC_insertNoChecks (1001,165659,'GO_REF:0000096',185,'Reference',-1,0,1);
select * from ACC_insertNoChecks (1001,61933,'GO_REF:0000004',185,'Reference',-1,0,1);
select * from ACC_insertNoChecks (1001,73197,'GO_REF:0000003',185,'Reference',-1,0,1);
select * from ACC_insertNoChecks (1001,73199,'GO_REF:0000002',185,'Reference',-1,0,1);
select * from ACC_insertNoChecks (1001,74017,'GO_REF:0000008',185,'Reference',-1,0,1);
select * from ACC_insertNoChecks (1001,74750,'GO_REF:0000015',185,'Reference',-1,0,1);

select * from VOC_Vocab where _Vocab_key = 112;
update VOC_Vocab set name = 'Proteoform' where _Vocab_key = 112;
select * from VOC_Vocab where _Vocab_key = 112;

select * from VOC_AnnotType where _annottype_key = 1019;
update VOC_AnnotType set name = 'Proteoform/Marker' where _annottype_key = 1019;
select * from VOC_AnnotType where _annottype_key = 1019;

insert into BIB_Dataset values(1012, 'PRO', 'PRO', 'BIB_PRO_Exists', 13, 0, 1000, 1000, now(), now());

-- move an 'In Progress' to 'Reserved' and remove 'In Progress'
select * from VOC_Term where _Vocab_key = 16;
select * from NOM_Marker where _NomenStatus_key = 166899;
update NOM_Marker set _NomenStatus_key = 166901 where _NomenStatus_key = 166899;
delete from VOC_Term where _Term_key = 166899;
select * from VOC_Term where _Vocab_key = 16;

EOSQL

date | tee -a ${LOG}
echo 'step 3 : goload (goamousenoctua)' | tee -a $LOG || exit 1
${GOLOAD}/go.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

# this will run MGI_deletePrivateData.csh
#date | tee -a ${LOG}
#echo 'step 4 : voc_cache_markers' | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Counts.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Markers.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/VOC_Cache_Allele.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 5 : qc reports' | tee -a $LOG || exit 1
./qcnightly_reports.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}


# final database check
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

echo "--- Finished" | tee -a ${LOG}

