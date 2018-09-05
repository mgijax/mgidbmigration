#!/bin/csh -fx

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

cd ${DBUTILS}/mgidbmigration/genfevah

date | tee -a ${LOG}
echo '--- starting part 2' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

if ( ${INSTALL_TYPE} == "dev" ) then
cp biotypemapping.config ${GENEMODELLOAD}
else
cp biotypemap.txt /mgi/all/wts_projects/10300/10308/RawBioTypeEquivalence
endif

# only run if *not* running straingenemodelload
date | tee -a ${LOG}
echo '--- new mrk_biotypemapping ' | tee -a $LOG
${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from MRK_BiotypeMapping;
EOSQL

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
