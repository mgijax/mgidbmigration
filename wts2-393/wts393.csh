#!/bin/csh -f

#
# wts2-393/Disease to reference annotation
#
# mgidbmigration
# pgmgddbschema
# pwi
# mgd_java_api
# curatorbulkindexload
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
 
# 09/19/2023: done
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#insert into MGI_RefAssocType values(1032, 13, 'Indexed', 1, 1000, 1000, now(), now());
#EOSQL

#${PG_MGD_DBSCHEMADIR}/view/MGI_Reference_DOID_View_create.object | tee -a $LOG
#${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG

#${CURATORBULKINDEXLOAD}/bin/curatorbulkindexload.sh | tee -a $LOG
$PYTHON wts393.py | tee -a $LOG

date |tee -a $LOG

