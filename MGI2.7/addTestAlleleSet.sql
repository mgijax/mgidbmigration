#!/bin/csh -f

#
# Migration for TR 2237/Marker History
#

echo "running $0..."

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv MGD	$2

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql << EOSQL
   
use $MGD
go

/* Add Test set of Alleles */
/* Acat2 = 30 */

declare @key int
select @key = max(_Allele_key) + 1 from ALL_Allele

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,1,"Acat2<tm1Tier5>","allele test tm1",NULL,"tier5","tier5",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,2,"Acat2<tm2Tier5>","allele test tm2",NULL,"tier5","tier5",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,3,"Acat2<tm3Tier5>","allele test tm3",NULL,"tier5","tier5",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,1,"Acat2<tm1Tier4>","allele test tm1",NULL,"tier4","tier4",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,2,"Acat2<tm2Tier4>","allele test tm2",NULL,"tier4","tier4",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,1,"Acat2<tm1Tier3>","allele test tm1",NULL,"tier3","tier3",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,2,"Acat2<tm2Tier3>","allele test tm2",NULL,"tier3","tier3",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,1,"Acat2<tm1Tier2>","allele test tm1",NULL,"tier2","tier2",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,30,-1,-1,-1,-1,2,"Acat2<tm2Tier2>","allele test tm2",NULL,"tier2","tier2",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

/* Add Test cases for using NOMENDB symbols */

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,NULL,-1,-1,-1,-1,1,"Abcc1a<tm1Tier5>","allele test tm1","Abcc1a","tier5","tier5",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

select @key = @key + 1

insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, createdBy, modifiedBy, approvedBy, approval_date)
values(@key,NULL,-1,-1,-1,-1,3,"Abcc1a<tm2Tier5>","allele test tm2","Abcc1a","tier5","tier5",NULL,NULL)
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
values(@key,22864,1)

go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
