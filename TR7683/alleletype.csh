#!/bin/csh -f

#
# TR 7446/new Allele Types
#
# Usage:  alleletype.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @termKey int
select @termKey = max(_Term_key) + 1 from VOC_Term
declare @memberKey int
select @memberKey = max(_SetMember_key) + 1 from MGI_SetMember

insert into VOC_Term values(@termKey, 38, 'transposon induced', null, 19, 0, 1000, 1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 38, 'transgenic (transposase)', null, 20, 0, 1000, 1000, getdate(), getdate())

/* 1010 Targeted */
/* 1011 Spontaneous */
/* 1012 Chemcially induced  */
/* 1013 Radiation induced */
/* 1014 Other */

insert into MGI_SetMember values(, @memberKey, @termKey, , 1000, 1000, getdate(), getdate())
insert into MGI_SetMember values(, @memberKey + 1, @termKey + 1, , 1000, 1000, getdate(), getdate())
go

EOSQL

date >> ${LOG}

