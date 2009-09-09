#!/bin/csh -f

#
# tr9164 - new creating new ALL_Cre_Cache Table 
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

#
# Steps
#   1) Create the new ALL_Cre_Cache
#   2) Insert Alleles that have positive or negative expression
#   3) Insert Alleles that have no expression
#   4) Add perms



####
#### Create New Table (and indexes) ###
####
echo "Creating New Table"

${MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_create.object | tee -a ${LOG}


#### 
#### Populate New Table
####
echo "Populating New Table"

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
use ${MGD_DBNAME}
go

insert into ALL_Cre_Cache(
    _Allele_key,
    _Allele_Type_key,
    _Structure_key,
    _System_key,
    _Assay_key,
    symbol,
    name,
    driver,
    structure,
    system,
    expressed)
select 
    ag._Allele_key, 
    aa._Allele_Type_key,
    e._Structure_key,
    s._System_key,
    e._Assay_key,
    aa.symbol,
    aa.name,
    nc.note,
    sn.structure,
    vt.term,
    e.expressed
from 
    GXD_Expression e, 
    GXD_AlleleGenotype ag, 
    GXD_Structure s, 
    GXD_StructureName sn, 
    VOC_Term vt,
    MGI_Note n,
    MGI_NoteChunk nc,
    ALL_Allele aa
where 
    e._GenoType_key = ag._GenoType_key
    and e._AssayType_key in (9,10,11)
    and e._Marker_key = ag._Marker_key
    and ag._Allele_key = aa._Allele_key
    and e._Structure_key = s._Structure_key
    and s._StructureName_key = sn._StructureName_key
    and s._System_key = vt._Term_key
    and ag._Allele_key = n._Object_key
    and n._Note_key = nc._Note_key
    and n._NoteType_key = 
      (
      select _NoteType_key 
      from MGI_NoteType
      where noteType = 'Driver'
      )
    and ag._Allele_key in 
      (
      select aa._Allele_key
      from ALL_Allele aa, MGI_Note n
      where aa._Allele_key = n._Object_key
      and _NoteType_key = 
        (
        select _NoteType_key 
        from MGI_NoteType
        where noteType = 'Driver'
        )
      )
go

select count(*) from ALL_Cre_Cache
go


insert into ALL_Cre_Cache(_Allele_key, _Allele_Type_key, symbol, name, driver)
select aa._Allele_key, aa._Allele_Type_key, aa.symbol, aa.name, nc.note
from ALL_Allele aa, MGI_Note n, MGI_NoteChunk nc
where aa._Allele_key = n._Object_key
  and aa._Allele_key = n._Object_key
  and n._Note_key = nc._Note_key
  and n._NoteType_key = 
    (
    select _NoteType_key 
    from MGI_NoteType
    where noteType = 'Driver'
    )
  and _NoteType_key = 
  (
    select _NoteType_key 
    from MGI_NoteType
    where noteType = 'Driver'
  )
  and aa._Allele_key not in
  (
    select distinct _Allele_key
    from ALL_Cre_Cache
  )
go

select count(*) from ALL_Cre_Cache
go


quit
EOSQL

#
# 4) keys, defaults, permissions ### 
#
echo "Adding Permissions"

${MGD_DBPERMSDIR}/public/table/ALL_Cre_Cache_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/ALL_Cre_Cache_grant.object | tee -a ${LOG}

