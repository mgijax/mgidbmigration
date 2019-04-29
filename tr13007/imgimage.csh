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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd IMG_Image ${MGI_LIVE}/dbutils/mgidbmigration/tr10307/IMG_Image.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/IMG_Image_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/IMG_Image_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/IMG_Image_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.IMG_Image DROP CONSTRAINT IMG_Image__MGIType_key_fkey CASCADE;
ALTER TABLE mgd.IMG_Image DROP CONSTRAINT IMG_Image__Refs_key_fkey CASCADE;
ALTER TABLE mgd.IMG_Image DROP CONSTRAINT IMG_Image__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.IMG_Image DROP CONSTRAINT IMG_Image__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.IMG_Image DROP CONSTRAINT IMG_Image__ImageClass_key_fkey CASCADE;
ALTER TABLE mgd.IMG_Image DROP CONSTRAINT IMG_Image__ImageType_key_fkey CASCADE;
ALTER TABLE IMG_Image RENAME TO IMG_Image_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/IMG_Image_create.object | tee -a $LOG || exit 1

#
# re-add Image without _mgitype_key
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into IMG_Image
select i._image_key, i._imageclass_key, i._imagetype_key, i._refs_key,
i._thumbnailimage_key, i.xdim, i.ydim, i.figurelabel,
i._CreatedBy_key, i._ModifiedBy_key, i.creation_date, i.modification_date
from IMG_Image_old i
;

ALTER TABLE mgd.IMG_Image ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs DEFERRABLE;
ALTER TABLE mgd.IMG_Image ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.IMG_Image ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.IMG_Image ADD FOREIGN KEY (_ImageType_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.IMG_Image ADD FOREIGN KEY (_ImageClass_key) REFERENCES mgd.VOC_Term DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/IMG_Image_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/IMG_Image_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/IMG_Image_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/IMG_Image_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/IMG_ImagePane_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from IMG_Image_old;

select count(*) from IMG_Image;

drop table mgd.IMG_Image_old;

EOSQL

date |tee -a $LOG

