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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_InSituResultImage ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_InSituResultImage.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/GXD_InSituResultImage_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_InSituResultImage DROP CONSTRAINT GXD_InSituResultImage_pkey CASCADE;
ALTER TABLE mgd.GXD_InSituResultImage DROP CONSTRAINT GXD_InSituResultImage__Result_key_fkey CASCADE;
ALTER TABLE mgd.GXD_InSituResultImage DROP CONSTRAINT GXD_InSituResultImage__ImagePane_key_fkey CASCADE;
ALTER TABLE GXD_InSituResultImage RENAME TO GXD_InSituResultImage_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_InSituResultImage
select nextval('gxd_insituresultimage_seq'), m._Result_key, m._ImagePane_key, m.creation_date, m.modification_date
from GXD_InSituResultImage_old m
;

ALTER TABLE mgd.GXD_InSituResultImage ADD PRIMARY KEY (_InSituResultImage_key);

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResultImage_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/IMG_ImagePane_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResultImage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/IMG_ImagePane_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_InSituResultImage_old;

select count(*) from GXD_InSituResultImage;

drop table mgd.GXD_InSituResultImage_old;

EOSQL

date |tee -a $LOG

