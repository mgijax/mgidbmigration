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

drop trigger SEQ_Source_Assoc_Delete
drop trigger SEQ_Source_Assoc_Insert
drop trigger SEQ_Source_Assoc_Update
go

drop procedure HMD_Cleanup
drop procedure HMD_getChromosomes
drop procedure HMD_nomenUpdate
go

/* create new MolecularSourceModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'MolecularSourceModule', null, 50, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'molecular source:update any field', null, 75, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1064, 1000, 1000, getdate(), getdate())
go

/* create new ControlledVocabModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'ControlledVocabModule', null, 51, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'controlled vocabulary:update any field', null, 76, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1065, 1000, 1000, getdate(), getdate())
go

/* create new SimpleVocabModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'SimpleVocabModule', null, 52, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'simple vocabulary:update any field', null, 77, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1065, 1000, 1000, getdate(), getdate())
go

/* create new OrganismModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'OrganismModule', null, 53, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'organism:update any field', null, 78, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey, 1064, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 4, @termKey, 1065, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1068, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 6, @termKey, 1069, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 7, @termKey, 1083, 1000, 1000, getdate(), getdate())
go

/* create new TissueModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'TissueModule', null, 54, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'tissue:update any field', null, 79, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
go

/* create new CrossModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'CrossModule', null, 55, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'crosses:update any field', null, 80, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
go

/* create new RISetModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'RISetModule', null, 56, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'ri sets:update any field', null, 81, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
go

/* create new TranslationModule */

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'TranslationModule', null, 57, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'crosses:update any field', null, 82, 0, 1000,1000, getdate(), getdate())

insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 2, @termKey, 1031, 1000, 1000, getdate(), getdate())
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

