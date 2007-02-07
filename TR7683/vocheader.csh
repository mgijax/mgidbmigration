#!/bin/csh -f

#
# TR 7342
#
# Usage:  vocheader.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename VOC_AnnotHeader, VOC_AnnotHeader_Old
go

quit

EOSQL

${MGD_DBSCHEMADIR}/table/VOC_AnnotHeader_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_AnnotHeader_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into VOC_AnnotHeader
select _AnnotHeader_key, _AnnotType_key, _Object_key, _Term_key,
sequenceNum, 0, _CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key,
approval_date, creation_date, modification_date
from VOC_AnnotHeader_Old
go

quit

EOSQL

${MGD_DBSCHEMADIR}/index/VOC_AnnotHeader_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/VOC_AnnotType_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/VOC_AnnotHeader_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/VOC_AnnotHeader_View_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeader_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeaderAll_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeaderMissing_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeader_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeaderAll_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeaderMissing_create.object | tee -a ${LOG}

#cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
#
#use ${MGD_DBNAME}
#go
#
#drop table VOC_AnnotHeader_Old
#go
#
#quit
#
#EOSQL

date >> ${LOG}

