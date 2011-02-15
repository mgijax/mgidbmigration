#!/bin/csh -f

#
# TR10584/Permissions for Strains
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#only use during testing
#delete from MGI_UserRole where _UserRole_key >= 1249
#delete from MGI_RoleTask where _RoleTask_key >= 1077
#delete from VOC_Term where _Term_key >= 6687672

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

/* fix sequence numbers */
update VOC_Term set sequenceNum = 12 where _Term_key = 2721205 and _Vocab_key = 33
update VOC_Term set sequenceNum = 13 where _Term_key = 2721207 and _Vocab_key = 33
update VOC_Term set sequenceNum = 14 where _Term_key = 2721209 and _Vocab_key = 33
update VOC_Term set sequenceNum = 15 where _Term_key = 2721211 and _Vocab_key = 33
update VOC_Term set sequenceNum = 16 where _Term_key = 2721213 and _Vocab_key = 33
update VOC_Term set sequenceNum = 17 where _Term_key = 2721215 and _Vocab_key = 33
update VOC_Term set sequenceNum = 18 where _Term_key = 2721217 and _Vocab_key = 33
update VOC_Term set sequenceNum = 19 where _Term_key = 2721219 and _Vocab_key = 33
update VOC_Term set sequenceNum = 20 where _Term_key = 2721221 and _Vocab_key = 33
update VOC_Term set sequenceNum = 21 where _Term_key = 2721223 and _Vocab_key = 33
update VOC_Term set sequenceNum = 22 where _Term_key = 2721225 and _Vocab_key = 33
update VOC_Term set sequenceNum = 23 where _Term_key = 2721228 and _Vocab_key = 33
update VOC_Term set sequenceNum = 24 where _Term_key = 2721230 and _Vocab_key = 33
update VOC_Term set sequenceNum = 25 where _Term_key = 2792981 and _Vocab_key = 33
update VOC_Term set sequenceNum = 26 where _Term_key = 3566936 and _Vocab_key = 33

declare @termKey integer
select @termKey = max(_Term_key) + 1 from VOC_Term 

declare @roleKey integer
select @roleKey = max(_UserRole_key) + 1 from MGI_UserRole

declare @taskKey integer
select @taskKey = max(_RoleTask_key) + 1 from MGI_RoleTask

insert into VOC_Term values(@termKey, 33, 'strain: full permissions', null, 27, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 34, 'strain: update any fields', null, 54, 0, 1000,1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey, @termKey, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_RoleTask values(@taskKey, @termKey, @termKey + 1, 1000, 1000, getdate(), getdate())

insert into VOC_Term values(@termKey + 2, 33, 'strain: references/genotypes only', null, 28, 0, 1000,1000, getdate(), getdate())
insert into VOC_Term 
values(@termKey + 3, 34, 'strain: update references/genotypes only', null, 55, 0, 1000,1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 1, @termKey + 2, 1000, 1000, 1000, getdate(), getdate())
insert into MGI_RoleTask values(@taskKey + 1, @termKey + 2, @termKey + 3, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey + 2, @termKey, 1001, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 3, @termKey + 2, 1001, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey + 4, @termKey, 1100, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 5, @termKey, 1084, 1000, 1000, getdate(), getdate())

insert into MGI_UserRole values(@roleKey + 6, @termKey + 2, 1100, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 7, @termKey + 2, 1084, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 8, @termKey + 2, 1406, 1000, 1000, getdate(), getdate())
insert into MGI_UserRole values(@roleKey + 9, @termKey + 2, 1421, 1000, 1000, getdate(), getdate())

checkpoint
go

end

EOSQL

date |tee -a $LOG

