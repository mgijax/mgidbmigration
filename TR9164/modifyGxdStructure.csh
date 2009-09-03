#!/bin/csh -f

#
# tr9164 - new column in GXD_Structure for roll-up AD System of the term
# tr9797 - backend
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

#
# Steps
#   1)Rename existing GXD_Structure table (GXD_Structure_Old)
#   2)Create new GXD_Structure table with new column (_System_key)
#   3)Use old table to populate new, inserting default (-1) into new column
#   4)Drop old table
#   5)Add keys, defaults & permissions to new table
#

########################################
###### 1) Renaming existing table ###### 
########################################
echo "Renaming Table"

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename GXD_Structure, GXD_Structure_Old 
go

sp_rename GXD_TheilerStage, GXD_TheilerStage_Old 
go

quit
EOSQL

###################################################
###### 2) Create New Table (and the indexes) ###### 
###################################################
echo "Creating New Table"

${MGD_DBSCHEMADIR}/table/GXD_Structure_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/GXD_TheilerStage_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_create.object | tee -a ${LOG}

###################################
###### 3) Populate New Table ###### 
###################################
echo "Populating New Table"

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into GXD_Structure
select 
  o._Structure_key,
  o._Parent_key,
  o._StructureName_key,
  o._Stage_key,
  -1,
  o.edinburghKey,
  o.printName,
  o.treeDepth,
  o.printStop,
  o.topoSort,
  1,
  o.structureNote,
  o.creation_date,
  o.modification_date
from GXD_Structure_Old o
go

insert into GXD_TheilerStage
select
  _Stage_key, 
  -1,
  stage, 
  description, 
  dpcMin, 
  dpcMax, 
  creation_date, 
  modification_date
from GXD_TheilerStage_Old
go

--drop table GXD_Structure_Old
--go

--drop table GXD_TheilerStage_Old
--go

--   set roll-up defaults
--   early embryo = 4856294
--   embryo - other = 4856295
--   postnatal - other = 4856306

update GXD_TheilerStage set _defaultSystem_key = 4856294
where _Stage_key in (1,2,3,4,5,6,7,8,9,10)
go

update GXD_TheilerStage set _defaultSystem_key = 4856295
where _Stage_key in (11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27)
go

update GXD_TheilerStage set _defaultSystem_key = 4856306
where _Stage_key in (28)
go

quit
EOSQL

############################################
###### 4) keys, defaults, permissions ###### 
############################################
echo "Adding defaults, keys, and perms to New Table"

${MGD_DBSCHEMADIR}/index/GXD_Structure_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/GXD_Structure_bind.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/GXD_TheilerStage_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/GXD_TheilerStage_bind.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/ALL_Cre_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/ALL_Cre_Cache_bind.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/GXD_Assay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Assay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Structure_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Structure_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ALL_Allele_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ALL_Allele_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}

${MGD_DBPERMSDIR}/public/table/GXD_Structure_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/GXD_Structure_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/table/GXD_TheilerStage_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/GXD_TheilerStage_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/table/ALL_Cre_Cache_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/ALL_Cre_Cache_grant.object | tee -a ${LOG}


