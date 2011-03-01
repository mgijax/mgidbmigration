#!/bin/csh -f

#
# TR10584/Permissions for Strains
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

update VOC_Term set term = 'UserRoleModule' where _Term_key = 706925
update VOC_Term set term = 'GXD ImageModule' where _Term_key = 901208
update VOC_Term set term = 'MPVocAnnot' where _Term_key = 6738024
update VOC_Term set term = 'OMIMVocAnnot' where _Term_key = 6738026
update VOC_Term set term = 'GOVocAnnot' where _Term_key = 6738028
update VOC_Term set term = 'TDCVocAnnot' where _Term_key = 6738030
update VOC_Term set term = 'GenotypeModule' where _Term_key = 706927
update VOC_Term set term = 'StrainModule' where _Term_key = 6738020
update VOC_Term set term = 'strains jax:update any field' where _Term_key = 6738023
update VOC_Term set term = 'StrainJAXModule' where _Term_key = 6738022
update VOC_Term set term = 'strains jax:update any field' where _Term_key = 6738021

delete from MGI_UserRole where _UserRole_key in (1324,1325,1326,1327,1328,1329,1330,1331,1332,1333,1334,1335)
delete from MGI_UserRole where _UserRole_key in (1255,1256)
go

/* create new Orthology */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'OrthologyModule', null, 33, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'orthology:update any field', null, 59, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1069, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1083, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1093, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1401, 1000, 1000, getdate(), getdate())
go

/* create new Orthology */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'MLCModule', null, 34, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'mlc:update any field', null, 60, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
go

/* create new Sequence */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'SequenceModule', null, 35, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'sequence:update any field', null, 61, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
go

/* create new Nomenclature */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'NomenModule', null, 36, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'nomen:update any field', null, 62, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1065, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1068, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1075, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1083, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1098, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 7, @termKey, 1401, 1000, 1000, getdate(), getdate())
go

/* create new AlleleDerivationModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'AlleleDerivationModule', null, 37, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'allele derivation:update any field', null, 62, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1065, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1070, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1071, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1075, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1084, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 7, @termKey, 1098, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 8, @termKey, 1099, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 9, @termKey, 1100, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 10, @termKey, 1406, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 11, @termKey, 1408, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 12, @termKey, 1413, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 13, @termKey, 1421, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 14, @termKey, 1431, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 15, @termKey, 1438, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 16, @termKey, 1454, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 17, @termKey, 1455, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 18, @termKey, 1483, 1000, 1000, getdate(), getdate())
go

/* create new Anitbody */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'AntibodyModule', null, 38, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'antibody:update any field', null, 63, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1077, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1080, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1091, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1431, 1000, 1000, getdate(), getdate())
go

/* create new Antigen */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'AntigenModule', null, 39, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'antigen:update any field', null, 64, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1077, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1080, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1091, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1431, 1000, 1000, getdate(), getdate())
go

/* create new Assay */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'AssayModule', null, 40, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'assay:update any field', null, 65, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1077, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1080, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1091, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1431, 1000, 1000, getdate(), getdate())
go

/* create new Dictionary */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'DictionaryModule', null, 41, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'dictionary:update any field', null, 66, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1077, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1080, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1091, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1431, 1000, 1000, getdate(), getdate())
go

/* create new IndexStage */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'IndexStageModule', null, 42, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'index:update any field', null, 67, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1077, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1080, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1091, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1431, 1000, 1000, getdate(), getdate())
go

/* create new Mapping */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'MappingModule', null, 43, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'mapping:update any field', null, 68, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1041, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1068, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1069, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1075, 1000, 1000, getdate(), getdate())
go

/* create new Molecular */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'MolecularSegmentModule', null, 44, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'molecular segment:update any field', null, 69, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1077, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1080, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1091, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1431, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 7, @termKey, 1069, 1000, 1000, getdate(), getdate())
go

/* create new MarkerNonMouseModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'MarkerNonMouseModule', null, 45, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'marker non-mouse:update any field', null, 70, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
go

/* create new MarkerModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'MarkerModule', null, 46, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'marker:update any field', null, 71, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1040, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1065, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1068, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 7, @termKey, 1069, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 8, @termKey, 1070, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 9, @termKey, 1072, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 10, @termKey, 1075, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 11, @termKey, 1076, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 12, @termKey, 1079, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 13, @termKey, 1083, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 14, @termKey, 1084, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 15, @termKey, 1085, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 16, @termKey, 1087, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 17, @termKey, 1093, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 18, @termKey, 1098, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 19, @termKey, 1100, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 20, @termKey, 1401, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 21, @termKey, 1408, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 22, @termKey, 1413, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 23, @termKey, 1421, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 24, @termKey, 1431, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 25, @termKey, 1452, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 26, @termKey, 1454, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 27, @termKey, 1455, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 28, @termKey, 1464, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 29, @termKey, 1483, 1000, 1000, getdate(), getdate())
go

/* create new molecular source organism */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'Molecular Source', null, 47, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'molecular source:organism', null, 72, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1091, 1000, 1000, getdate(), getdate())
go

/* create new references: washu */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'References:restrictions by J:', null, 48, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'references:WashU/J:57656', null, 73, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 2, 34, 'references:UniGene/J:57747', null, 74, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())
insert into MGI_RoleTask values(@taskKey + 1, @termKey, @termKey + 2, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
go

/* create new Reference */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'ReferenceModule', null, 49, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'references:update any field', null, 74, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1079, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1087, 1000, 1000, getdate(), getdate())
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

