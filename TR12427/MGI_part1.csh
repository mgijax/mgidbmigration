#!/bin/csh -fx

#
# Migration for TR12427/Disease Ontology
#
# mgidbmigration : cvs/trunk : 
# pgmgddbschema : git
# mirror_wget : git 
# vocload : git
# mgicacheload : git : not using
# lib_py_vocload : cvs
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

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update MGI_dbinfo set schema_version = '6-0-8', public_version = 'MGI 6.08';

delete from MGI_Synonym where _synonymtype_key = 1031;
delete from MGI_SynonymType where _synonymtype_key = 1031;

insert into VOC_AnnotType values (1020, 12, 125, 43, 53, 'DO/Genotype', now(), now());
insert into VOC_AnnotType values (1021, 11, 125, 85, 84, 'DO/Allele', now(), now());
insert into VOC_AnnotType values (1022, 2, 125, 43, 53, 'DO/Human Marker', now(), now());
insert into VOC_AnnotType values (1023, 2, 125, 2, 53, 'DO/Marker (Dervied)', now(), now());
insert into VOC_AnnotType values (1024, 13, 106, 107, 108, 'HPO/DO', now(), now());

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
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 5 : qc reports' | tee -a $LOG || exit 1
#./qcnightly_reports.csh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

# final database check
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--select count(e.*) from VOC_Annot v, VOC_Evidence e where v._AnnotType_key = 1005 and v._Annot_key = e._Annot_key;
--select count(e.*) from VOC_Annot v, VOC_Evidence e where v._AnnotType_key = 1020 and v._Annot_key = e._Annot_key;

EOSQL

echo "--- Finished" | tee -a ${LOG}

