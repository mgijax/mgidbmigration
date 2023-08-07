#!/bin/csh -fx

#
# (part 1 running schema changes)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump

#
# update schema-version and public-version
#
#06/14 done on production
#date | tee -a ${LOG}
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 >>& $LOG
#update MGI_dbinfo set schema_version = '6-0-20', public_version = 'MGI 6.13';
#drop sequence if exists gxd_antibodyclass_seq;
#drop sequence if exists gxd_embedding_seq;
#drop sequence if exists gxd_fixation_seq;
#drop sequence if exists gxd_gelcontrol_seq;
#drop sequence if exists gxd_label_seq;
#drop sequence if exists gxd_pattern_seq;
#drop sequence if exists gxd_visualization_seq;
#EOSQL
#date | tee -a ${LOG}

#
# update schema-version and public-version
# archive MRK_Alias 
#
rm -rf /mgi/all/wts2_projects/700/WTS2-765/*
rm -rf ${MGI_LIVE}/dbutils/mgidbmigration/fl2c/MRK_Alias.bcp
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MRK_Alias /mgi/all/wts2_projects/700/WTS2-795/MRK_Alias.bcp "|" >>& $LOG
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MRK_Alias ${MGI_LIVE}/dbutils/mgidbmigration/fl2c/MRK_Alias.bcp "|" >>& $LOG
./MRK_Alias.csh >>& $LOG
cp MRK_Alias.csh /mgi/all/wts2_projects/700/WTS2-765
cp MRK_Alias.csh.log /mgi/all/wts2_projects/700/WTS2-765

