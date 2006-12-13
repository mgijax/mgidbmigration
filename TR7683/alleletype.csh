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
declare @assocKey int
select @assocKey = max(_Association_key) + 1 from MGI_VocAssociation

insert into VOC_Term values(@termKey, 38, 'transposon induced', null, 19, 0, 1000, 1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 1, 38, 'transgenic (transposase)', null, 20, 0, 1000, 1000, getdate(), getdate())
insert into VOC_Term values(@termKey + 2, 41, 'Transposon induced', null, 10, 0, 1000, 1000, getdate(), getdate())

insert into MGI_VocAssociation values(@assocKey, 1001, @termKey + 2, @termKey, 20, 1000, 1000, getdate(), getdate())
insert into MGI_VocAssociation values(@assocKey + 1, 1001, 847159, @termKey + 1, 21, 1000, 1000, getdate(), getdate())
go

EOSQL

date >> ${LOG}

