#!/bin/csh -f

#
# TR 7710/Images
#
# Usage:  images.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename IMG_Image, IMG_Image_Old
go

quit

EOSQL

${MGD_DBSCHEMADIR}/table/IMG_Image_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/IMG_Image_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/IMG_Image_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* allele images have thumbnails */

insert into IMG_Image
select o._Image_key, 11, o._ImageType_key, o._Refs_key, o._ThumbnailImage_key, o.xDim, o.yDim,
o.figureLabel, o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
from IMG_Image_Old o
where o._ThumbnailImage_key is not null
go

/* gxd images do not (currently) have thumbnails */

insert into IMG_Image
select o._Image_key, 8, o._ImageType_key, o._Refs_key, o._ThumbnailImage_key, o.xDim, o.yDim,
o.figureLabel, o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
from IMG_Image_Old o
where o._ThumbnailImage_key is null
go

quit

EOSQL

#
# add indexes;permissions;etc.
#

${MGD_DBSCHEMADIR}/index/IMG_Image_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/ACC_MGIType_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ACC_MGIType_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/ACC_Accession_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ACC_Accession_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ACC_MGIType_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ACC_MGIType_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/BIB_Refs_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/BIB_Refs_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/IMG_Image_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/IMG_Image_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_Summary_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_Summary_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_Image_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePaneGXD_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePaneGXD_View_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/IMG_setPDO_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/IMG_setPDO_create.object | tee -a ${LOG}

${MGD_DBPERMSDIR}/public/table/IMG_Image_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/IMG_grant.logical | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/procedure/IMG_setPDO_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/IMG_Image_grant.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

drop table IMG_Image_Old
go

drop view IMG_ImagePaneRef_View
go

EOSQL

date >> ${LOG}

