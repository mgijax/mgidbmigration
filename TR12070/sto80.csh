#!/bin/csh -f

#
# pgmgddbschema-tr12070
# vocload (trunk)
# seqcacheload-tr12070
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#
# create 3 new biotype vocabularies
# Ensembl : J:91388 (92373)
# NCBI : J:90438 (91423)
# VEGA : J:109762 (110841)
#

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--added to production; comment out during next production load
--insert into ACC_LogicalDB values(174,'BioType Ensembl','BioType Ensembl',1,1001,1001,now(),now());
--insert into ACC_LogicalDB values(175,'BioType NCBI','BioType NCBI',1,1001,1001,now(),now());
--insert into ACC_LogicalDB values(176,'BioType VEGA','BioType VEGA',1,1001,1001,now(),now());

--insert into VOC_Vocab values(103,92373,174,1,0,'BioType Ensembl',now(),now());
--insert into VOC_Vocab values(104,91423,175,1,0,'BioType NCBI',now(),now());
--insert into VOC_Vocab values(105,110841,176,1,0,'BioType VEGA',now(),now());

-- this needs to run as part of the migration
-- remove existing raw biotype translation
delete from MGI_Translation where _translationtype_key = 1020;
delete from MGI_TranslationType where _translationtype_key = 1020;

-- incorrect name
DROP FUNCTION IF EXISTS VOC_AnnotHeaderMissing(int);

EOSQL

#
# new table : MRK_BiotypeMapping
#
${PG_MGD_DBSCHEMADIR}/table/MRK_BiotypeMapping_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MRK_BiotypeMapping_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MRK_BiotypeMapping_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_BiotypeMapping_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Vocab_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Vocab_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Types_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Types_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/ALL_postMP_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeaderMissing_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeader_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/PRB_Probe_create.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/index/index_drop.sh | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/index/index_create.sh | tee -a $LOG || exit 1

#
# the migration should *not* run this...for testing purposes only
#
# run the genemodelload
# 
rm -rf $DATALOADSOUTPUT/mgi/genemodelload/input/Ensembl.lastrun
echo "Running ${GENEMODELLOAD}/bin/genemodelload.sh ensembl"
${GENEMODELLOAD}/bin/genemodelload.sh ensembl | tee -a ${LOG} || exit 1
#
# run all cache loads (see wiki/section 11/Processing)
#
${SEQCACHELOAD}/seqcoord.csh || exit 1
${SEQCACHELOAD}/seqmarker.csh || exit 1
${MRKCACHELOAD}/mrklabel.csh || exit 1
${MRKCACHELOAD}/mrkref.csh || exit 1
${MRKCACHELOAD}/mrklocation.csh  || exit 1

date |tee -a $LOG

