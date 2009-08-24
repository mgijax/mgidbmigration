#!/bin/csh -fx

#
# TR 9300/add _ConditionalMutant_key
#

source ./Configuration

setenv LOG	`basename $0`.log
rm -rf $LOG
touch $LOG

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename GXD_Index, GXD_Index_Old
go

quit

EOSQL

${newmgddbschema}/table/GXD_Index_create.object | tee -a ${LOG}
${newmgddbschema}/default/GXD_Index_bind.object | tee -a ${LOG}
${newmgddbschema}/key/GXD_Index_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* vocabulary was added via /mgi/all/wts_projects/9300/9300/tr9300.csh */
/* set existing key to... */

declare @conditionalKey integer
select @conditionalKey = _Term_key from VOC_Vocab v, VOC_Term t
where v.name = 'GXD Conditional Mutants'
and v._Vocab_key = t._Vocab_key
and t.term = 'Not Specified'

insert into GXD_Index
select _Index_key, _Refs_key, _Marker_key, _Priority_key, @conditionalKey, comments,
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from GXD_Index_Old
go

quit

EOSQL

${newmgddbschema}/index/GXD_Index_create.object | tee -a ${LOG}

${newmgddbschema}/trigger/GXD_Index_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/GXD_Index_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/VOC_Term_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/VOC_Term_create.object | tee -a ${LOG}

${newmgddbschema}/view/GXD_Index_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/GXD_Index_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/VOC_Term_GXDIndexCondMut_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/VOC_Term_GXDIndexCondMut_View_create.object | tee -a ${LOG}

${newmgddbschema}/procedure/MRK_updateKeys_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_updateKeys_create.object | tee -a ${LOG}

${newmgddbperms}/curatorial/procedure/MRK_updateKeys_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/table/GXD_Index_grant.object | tee -a ${LOG}
${newmgddbperms}/public/table/GXD_Index_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/GXD_Index_View_grant.object | tee -a ${LOG}

date | tee -a ${LOG}

