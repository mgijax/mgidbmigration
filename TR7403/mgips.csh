#!/bin/csh -f

#
# TR 7316/Remove PhenoSlim data
#
# Usage:  mgips.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${newmgddbschema}/trigger/VOC_Term_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_dropkey foreign, BIB_Refs, VOC_Term
go

/* delete PS annotations */

delete from VOC_Annot where _AnnotType_key = 1001
go

delete from VOC_AnnotType where _AnnotType_key = 1001
go

/* PhenoSlim vocabulary */

delete from VOC_Vocab where _Vocab_key = 1
go

/* PhenoSlim Evidence Codes: rename */

update VOC_Vocab set name = 'Mammalian Phenotype Evidence Codes' where _Vocab_key = 2
go

quit

EOSQL

date >> ${LOG}

