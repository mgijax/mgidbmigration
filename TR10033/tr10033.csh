#!/bin/csh -f

#
# Template
#

source ../Configuration

cd `dirname $0`

setenv LOG $0.log.$$
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

drop table IMG_Image
go

sp_rename IMG_Image_Old, IMG_Image
go

sp_rename IMG_Image, IMG_Image_Old
go

checkpoint
go

end

EOSQL

###----------------------###
###--- add new tables ---###
###----------------------###

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/IMG_Image_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/IMG_Image_create.object | tee -a ${LOG}

# add defaults for new tables

date | tee -a ${LOG}
echo "--- Dropping/Adding defaults" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/default/IMG_Image_bind.object | tee -a ${LOG}

# drop/add keys and indexes for new tables

date | tee -a ${LOG}
echo "--- Dropping/Adding keys" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/IMG_Image_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Migrate data" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

declare @classKey integer
select @classKey = t._Term_key from VOC_Term t, VOC_Vocab v
where v.name = 'Image Class'
and v._Vocab_key = t._Vocab_key
and t.term = 'Expression'

insert into IMG_Image
select o._Image_key, o._MGIType_key, @classKey, o._ImageType_key, o._Refs_key,
o._ThumbnailImage_key, o.xDim, o.yDim, o.figureLabel,
o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
from IMG_IMage_Old o
where o._MGIType_key = 8
go

declare @classKey integer
select @classKey = t._Term_key from VOC_Term t, VOC_Vocab v
where v.name = 'Image Class'
and v._Vocab_key = t._Vocab_key
and t.term = 'Phenotypes'

insert into IMG_Image
select o._Image_key, o._MGIType_key, @classKey, o._ImageType_key, o._Refs_key,
o._ThumbnailImage_key, o.xDim, o.yDim, o.figureLabel,
o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
from IMG_IMage_Old o
where o._MGIType_key = 11
go

checkpoint
go

end

EOSQL

${MGD_DBSCHEMADIR}/index/IMG_Image_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding trigger" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/IMG_Image_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/IMG_Image_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding views" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/IMG_Image_Acc_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_Acc_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_Summary_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_Summary_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/VOC_Term_IMGClass_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/VOC_Term_IMGClass_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePane_Assoc_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePane_Assoc_View_create.object | tee -a ${LOG}

# add permissions

date | tee -a ${LOG}
echo "--- Adding perms" | tee -a ${LOG}

${MGD_DBPERMSDIR}/curatorial/table/IMG_Image_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/table/IMG_Image_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/IMG_Image_Acc_View_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/IMG_Image_Summary_View_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/IMG_Image_View_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/VOC_Term_IMGClass_View_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/IMG_ImagePane_Assoc_View_grant.object | tee -a ${LOG}

date |tee -a $LOG

