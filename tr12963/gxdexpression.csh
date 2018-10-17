#!/bin/csh -f

#
# 12904/add GXD_InSituResult.resultNote to GXD_Expression table
#
# verify that the number of rows in previous GXD_Expression.bcp is same as new version
#
# pgmgddbschema/table/GXD_Expression*
# mgicacheload/gxdexpression.py
# mgipython
# pwi
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
 
# run/save current bcp
#source ${MGICACHELOAD}/Configuration
#setenv TABLE GXD_Expression
#setenv OBJECTKEY 0
#${MGICACHELOAD}/gxdexpression.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -K${OBJECTKEY} | tee -a $LOG
#cp ${DATALOADSOUTPUT}/mgi/mgicacheload/output/GXD_Expression.bcp ${DATALOADSOUTPUT}/mgi/mgicacheload/output/GXD_Expression.bcp.previous
#ls -l ${DATALOADSOUTPUT}/mgi/mgicacheload/output/GXD*

${PG_MGD_DBSCHEMADIR}/table/GXD_Expression_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/GXD_Expression_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/GXD_replaceGenotype_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/PRB_getStrainByReference_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/BIB_AssociatedData_View_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_AssayType_key) REFERENCES mgd.GXD_AssayType DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Assay_key) REFERENCES mgd.GXD_Assay ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD PRIMARY KEY (_Expression_key);
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_GelLane_key) REFERENCES mgd.GXD_GelLane ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Genotype_key) REFERENCES mgd.GXD_Genotype DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Specimen_key) REFERENCES mgd.GXD_Specimen ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Stage_key) REFERENCES mgd.GXD_TheilerStage ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker DEFERRABLE;
ALTER TABLE mgd.GXD_Expression ADD FOREIGN KEY (_EMAPA_Term_key) REFERENCES mgd.VOC_Term ON DELETE CASCADE DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

# full table load
${MGICACHELOAD}/gxdexpression.csh | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from GXD_Expression;
EOSQL

#wc -l ${DATALOADSOUTPUT}/mgi/mgicacheload/output/GXD*

# run single assay (as in EI)
#${MGICACHELOAD}/gxdexpression.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -K90730  | tee -a $LOG

date |tee -a $LOG

