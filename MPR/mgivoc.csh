#!/bin/csh -f

#
# Migration for ALL controlled vocabs
#
# ALL_Inheritance_Mode
# ALL_Molecular_Mutation
# ALL_Status
# ALL_Type
#
# ALL_Note
# ALL_NoteType
# ALL_Reference
# ALL_ReferenceType
# ALL_Synonym
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "Allele Vocabulary Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

update ALL_Allele
set _Mode_key = t._Term_key
from ALL_Allele a, ALL_Inheritance_Mode o, VOC_Term t, VOC_Vocab v
where a._Mode_key = o._Mode_key
and o.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Inheritance Mode"
go

dump tran ${DBNAME} with truncate_only
go

update ALL_Allele
set _Allele_Status_key = t._Term_key
from ALL_Allele a, ALL_Status o, VOC_Term t, VOC_Vocab v
where a._Allele_Status_key = o._Allele_Status_key
and o.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Status"
go

dump tran ${DBNAME} with truncate_only
go

update ALL_Allele
set _Allele_Type_key = t._Term_key
from ALL_Allele a, ALL_Type o, VOC_Term t, VOC_Vocab v
where a._Allele_Type_key = o._Allele_Type_key
and o.alleleType = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Type"
go

dump tran ${DBNAME} with truncate_only
go

update ALL_Allele_Mutation
set _Mutation_key = t._Term_key
from ALL_Allele_Mutation a, ALL_Molecular_Mutation o, VOC_Term t, VOC_Vocab v
where a._Mutation_key = o._Mutation_key
and o.mutation = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Molecular Mutation"
go

dump tran ${DBNAME} with truncate_only
go

quit

EOSQL

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

drop table ALL_Inheritance_Mode
go

drop table ALL_Molecular_Mutation
go

drop table ALL_Status
go

drop table ALL_Type
go

EOSQL

date >> ${LOG}

