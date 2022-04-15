#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/ALL_Cre_Cache_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Assay_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_create.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/ALL_Cre_Cache_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Assay_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/index/ALL_Cre_Cache_create.object | tee -a $LOG 

#${ALLCACHELOAD}/allelecrecache.csh | tee -a $LOG

date |tee -a $LOG

