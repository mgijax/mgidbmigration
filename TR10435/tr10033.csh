#!/bin/csh -f

#
# TR 10033/Image Assocation
#

cd `dirname $0` && source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG
use ${MGD_DBNAME}
go
drop table IMG_ImagePane_Assoc
go
sp_rename IMG_ImagePane_Assoc_Old, IMG_ImagePane_Assoc
go
quit
EOSQL

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use ${MGD_DBNAME}
go

sp_rename IMG_ImagePane_Assoc, IMG_ImagePane_Assoc_Old
go

quit

EOSQL

#
# adding _ImageAssocType_key
#

${MGD_DBSCHEMADIR}/table/IMG_ImagePane_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/IMG_ImagePane_Assoc_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/IMG_ImagePane_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/IMG_ImagePane_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use ${MGD_DBNAME}
go

/* migrate IMG_ImagePane_Assoc */

declare @vocabKey integer
select @vocabKey = _Vocab_key from VOC_Vocab where name = 'Image Association Type'
declare @ptermKey integer
select @ptermKey = _Term_key from VOC_Term where _Vocab_key = @vocabKey and term = 'Phenotype'

insert into IMG_ImagePane_Assoc
select o._Assoc_key, o._ImagePane_key, o._MGIType_key, o._Object_key, @ptermKey,
o.isPrimary, o.creation_date, o.modification_date
from IMG_ImagePane_Assoc_Old o

go

quit

EOSQL

#
# add indexes
#

${MGD_DBPERMSDIR}/curatorial/table/IMG_ImagePane_Assoc_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/table/IMG_ImagePane_Assoc_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/IMG_ImagePane_Assoc_View_grant.object | tee -a ${LOG}

date >> ${LOG}

