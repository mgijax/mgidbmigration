#!/bin/csh -f

#
# Migration for: Allele Pair
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Allele Pair Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename GXD_AllelePair, GXD_AllelePair_Old
go

end

EOSQL

${newmgddbschema}/table/GXD_AllelePair_create.object | tee -a ${LOG}
${newmgddbschema}/default/GXD_AllelePair_bind.object | tee -a ${LOG}

# keys/permissions will be handled in reconfig phase 

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

declare @stateKey integer
select @stateKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Pair State'
	and t.term = 'Unknown'

declare @compoundKey integer
select @compoundKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Compound'
	and t.term = 'Not Applicable'

insert into GXD_AllelePair
select o._AllelePair_key, o._Genotype_key, o.sequenceNum, 
o._Allele_key_1, o._Allele_key_2, o._Marker_key,
@stateKey, @compoundKey,
${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from GXD_AllelePair_Old o
go

end

EOSQL

${newmgddbschema}/index/GXD_AllelePair_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

/* Homozygous 9036 */

declare @stateKey integer
select @stateKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Pair State'
	and t.term = 'Homozygous'

update GXD_AllelePair
set _PairState_key = @stateKey
where _Allele_key_1 = _Allele_key_2
go

/* Heterozygous 2884 */

declare @stateKey integer
select @stateKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Pair State'
	and t.term = 'Heterozygous'

update GXD_AllelePair
set _PairState_key = @stateKey
where _Allele_key_1 != _Allele_key_2 and _Allele_key_2 is not null
go

/* Hemizgyous X-linked 146 */

declare @stateKey integer
select @stateKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Pair State'
	and t.term = 'Hemizygous X-linked'

update GXD_AllelePair
set _PairState_key = @stateKey
from GXD_AllelePair a, GXD_AllelePair_Old o, MRK_Marker m, ALL_Allele aa, VOC_Term t
where a._Allele_key_2 is null
and a._Marker_key = m._Marker_key
and m.chromosome = "X"
and a._AllelePair_key = o._AllelePair_key
and o.isUnknown = 0
and a._Allele_key_1 = aa._Allele_key
and aa._Allele_Type_key = t._Term_key
and t.term not like 'transgen%'
go

/* Hemizgyous Y-linked 12 */

declare @stateKey integer
select @stateKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Pair State'
	and t.term = 'Hemizygous Y-linked'

update GXD_AllelePair
set _PairState_key = @stateKey
from GXD_AllelePair a, GXD_AllelePair_Old o, MRK_Marker m
where a._Allele_key_2 is null
and a._Marker_key = m._Marker_key
and m.chromosome = "Y"
and a._AllelePair_key = o._AllelePair_key
and o.isUnknown = 0
go

/* Hemizgyous Insertion 671 */

declare @stateKey integer
select @stateKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Pair State'
	and t.term = 'Hemizygous Insertion'

update GXD_AllelePair
set _PairState_key = @stateKey
from GXD_AllelePair a, GXD_AllelePair_Old o, MRK_Marker m, ALL_Allele aa, VOC_Term t
where a._Allele_key_2 is null
and a._Marker_key = m._Marker_key
and m.chromosome != "X"
and a._AllelePair_key = o._AllelePair_key
and o.isUnknown = 0
and a._Allele_key_1 = aa._Allele_key
and aa._Allele_Type_key = t._Term_key
and t.term like 'transgen%'
go

/* Indeterminate 784 */

declare @stateKey integer
select @stateKey = t._Term_key from VOC_Term t, VOC_Vocab v
	where t._Vocab_key = v._Vocab_key
	and v.name = 'Allele Pair State'
	and t.term = 'Indeterminate'

update GXD_AllelePair
set _PairState_key = @stateKey
from GXD_AllelePair a, GXD_AllelePair_Old o
where a._Allele_key_2 is null
and a._AllelePair_key = o._AllelePair_key
and o.isUnknown = 1
go

end

EOSQL

./unmigratedAlleleState.py 

date >> ${LOG}

