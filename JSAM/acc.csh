#!/bin/csh -f

#
# Migration for ACC Accession
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "ACC Accession Migration..." | tee -a $LOG
 
# ACC_Accession indexes where dropped in nomen.csh
# we drop ACC_AccessionReference_Old indexes to save space

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename ACC_Accession, ACC_Accession_Old
go

sp_rename ACC_AccessionReference, ACC_AccessionReference_Old
go

sp_rename ACC_AccessionMax, ACC_AccessionMax_Old
go

drop index ACC_AccessionReference_Old.index_Acc_Refs_key
go

drop index ACC_AccessionReference_Old.index_Accession_key
go

drop index ACC_AccessionReference_Old.index_modification_date
go

drop index ACC_AccessionReference_Old.index_Refs_key
go

checkpoint
go

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/ACC_Accession_create.object >> $LOG
${newmgddbschema}/default/ACC_Accession_bind.object >> $LOG
${newmgddbschema}/table/ACC_AccessionReference_create.object >> $LOG
${newmgddbschema}/default/ACC_AccessionReference_bind.object >> $LOG
${newmgddbschema}/table/ACC_AccessionMax_create.object >> $LOG
${newmgddbschema}/default/ACC_AccessionMax_bind.object >> $LOG

#bcpout.csh ${newmgddbschema} ACC_Accession_Old . ACC_Accession_Old.bcp >> $LOG
#bcpout.csh ${newmgddbschema} ACC_AccessionReference_Old . ACC_AccessionReference_Old.bcp >> $LOG
#acc.py >> $LOG
#bcpin.csh ${newmgddbschema} ACC_Accession . ACC_Accession.bcp >> $LOG
#bcpin.csh ${newmgddbschema} ACC_AccessionReference . ACC_AccessionReference.bcp >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_AccessionMax
select o.prefixPart, o.maxNumericPart, o.creation_date, o.modification_date
from ACC_AccessionMax_Old o
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key = 1
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key between 2 and 8
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key = 9
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key between 10 and 11
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key = 12
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key = 13
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key between 14 and 15
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key = 16
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key = 17
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key between 18 and 22
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key = 23
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_Accession
select _Accession_key, accID, prefixPart, numericPart, _LogicalDB_key,
_Object_key, _MGIType_key, private, preferred, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_Accession_Old
where _LogicalDB_Key >= 24
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_AccessionReference
select _Accession_key, _Refs_key, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_AccessionReference_Old
where _Refs_key between 1 and 30000
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_AccessionReference
select _Accession_key, _Refs_key, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_AccessionReference_Old
where _Refs_key between 30001 and 60000
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_AccessionReference
select _Accession_key, _Refs_key, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_AccessionReference_Old
where _Refs_key between 60001 and 90000
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_AccessionReference
select _Accession_key, _Refs_key, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ACC_AccessionReference_Old
where _Refs_key > 90000
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

EOSQL

${newmgddbschema}/index/ACC_Accession_create.object >> $LOG
${newmgddbschema}/index/ACC_AccessionReference_create.object >> $LOG
${newmgddbschema}/index/ACC_AccessionMax_create.object >> $LOG
${newmgddbschema}/key/ACC_Accession_drop.object >> $LOG
${newmgddbschema}/key/ACC_AccessionReference_drop.object >> $LOG
${newmgddbschema}/key/ACC_Accession_create.object >> $LOG
${newmgddbschema}/key/ACC_AccessionReference_create.object >> $LOG
${newmgddbschema}/key/ACC_AccessionMax_create.object >> $LOG

date >> $LOG

