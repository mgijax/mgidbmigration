#!/bin/csh -f

#
# Migration for 3.02 release (cDNA Load)
#
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}
  
use ${DBNAME}
go

declare @setKey integer
declare @log1Key integer
declare @log2Key integer
select @setKey = max(_SetMember_key) + 1 from MGI_SetMember
select @log1Key = _LogicalDB_key from ACC_LogicalDB where name = 'mKIAA'
select @log2Key = _LogicalDB_key from ACC_LogicalDB where name = 'mFLJ'
insert into MGI_SetMember values(@setKey, 1000, @log1Key, 5, 1001, 1001, getdate(), getdate())
insert into MGI_SetMember values(@setKey + 1, 1000, @log2Key, 6, 1001, 1001, getdate(), getdate())
go

checkpoint
go

quit
EOSQL

date | tee -a ${LOG}
