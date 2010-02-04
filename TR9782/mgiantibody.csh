#!/bin/csh -fx

#
# TR8156
#
#  remove GXD_Antibody._Refs_key
#  move data to MGI_Reference_Assoc
#  add new MGI_ReferenceType:  "Primary", "Related" for _MGIType_key = 6
#
# remove GXD_AntibodyRef_View
# new MGI_Reference_Antibody_View
# new MGI_RefType_Antibody_View
# modify MGI_insertReferenceAssoc
# modify MGI_Reference_Assoc trigger
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go


/* create new reference types */

declare @nextType integer
select @nextType = max(_RefAssocType_key) + 1 from MGI_RefAssocType

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType, allowOnlyOne)
values (@nextType, 6, "Primary", 1)

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType, allowOnlyOne)
values (@nextType + 1, 6, "Related", 0)

go

/* move current references into MGI_Reference_Assoc */

select seq = identity(5), _Antibody_key, _Refs_key
into #toAdd
from GXD_Antibody
go

declare @nextAssoc integer
select @nextAssoc = max(_Assoc_key) from MGI_Reference_Assoc

declare @mgiType integer
select @mgiType = _RefAssocType_key from MGI_RefAssocType
    where _MGIType_key = 6 and assocType = "Primary"

insert MGI_Reference_Assoc
(_Assoc_key, _Refs_key, _Object_key, _MGIType_key, _RefAssocType_key, 
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date)
select @nextAssoc + seq, _Refs_key, _Antibody_key, 6, @mgiType, 1000, 1000, getdate(), getdate()
from #toAdd
go

sp_dropkey foreign, GXD_Antibody, BIB_Refs
go

drop index GXD_Antibody.idx_Refs_key
go

alter table GXD_Antibody drop _Refs_key
go

drop view GXD_AntibodyRef_View
go

quit

EOSQL

${MGD_DBSCHEMADIR}/trigger/GXD_Antibody_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/GXD_Antibody_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_Antibody_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_Reference_Antibody_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_RefType_Antibody_View_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/MGI_insertReferenceAssoc_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_insertReferenceAssoc_create.object | tee -a ${LOG}

${MGD_DBPERMSDIR}/public/table/GXD_Antibody_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/GXD_Antibody_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/procedure/MGI_insertReferenceAssoc_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/GXD_Antibody_View_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/MGI_Reference_Antibody_View_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/MGI_RefType_Antibody_View_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}

