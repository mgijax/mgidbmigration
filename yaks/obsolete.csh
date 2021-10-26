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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

drop view if exists mgd.ACC_LogicalDB_View CASCADE;
drop view if exists mgd.ALL_Annot_View CASCADE;
drop view if exists mgd.ALL_Derivation_Summary_View CASCADE;
drop view if exists mgd.BIB_All2_View CASCADE;
drop view if exists mgd.BIB_Summary_All_View CASCADE;
drop view if exists mgd.GO_Tracking_View CASCADE;
drop view if exists mgd.MGI_RoleTask_View CASCADE;
drop view if exists mgd.MGI_TranslationStrain_View CASCADE;
drop view if exists mgd.MGI_Translation_View CASCADE;

drop view if exists mgd.MLD_Acc_View CASCADE;
drop view if exists mgd.MLD_Concordance_View CASCADE;
drop view if exists mgd.MLD_FISH_View CASCADE;
drop view if exists mgd.MLD_Hybrid_View CASCADE;
drop view if exists mgd.MLD_InSitu_View CASCADE;
drop view if exists mgd.MLD_Matrix_View CASCADE;
drop view if exists mgd.MLD_MC2point_View CASCADE;
drop view if exists mgd.MLD_RI2Point_View CASCADE;
drop view if exists mgd.MLD_RIData_View CASCADE;
drop view if exists mgd.MLD_RI_View CASCADE;
drop view if exists mgd.MLD_Statistics_View CASCADE;
drop view if exists mgd.MLD_Summary_View CASCADE;
drop view if exists mgd.RI_RISet_View CASCADE;

EOSQL

date |tee -a $LOG

