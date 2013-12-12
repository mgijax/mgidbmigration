#!/bin/csh -fx

#
# Migration for TR11515
#
# Allele Type: _Vocab_key = 38
# Allele Subtype: _Vocab_key = 93
# Allele/Subtype annotation: _AnnotType_key = 1014
#
# * migration existing _Vocab_key = 38 to new terms
#	- ALL_Allele._Allele_Type_key
#	- ALL_CellLine_Derivation._DerivationType_key
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- existing terms
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 38 order by term
go

select count(*) from ALL_Allele where _Allele_Type_key in (847118, 847117, 847116, 847120, 847119)
go

-- start: allows a fresh of a previous migration
delete from VOC_Term where _Vocab_key = 93
go

delete from VOC_Term where _Vocab_key = 38 and sequenceNum > 20
go
-- end: allows a fresh of a previous migration

-- add new VOC_Term._Vocab_key = 38 terms (both old and new terms exist)

declare @nextTermKey integer
select @nextTermKey = max(_Term_key) + 1 from VOC_Term

insert into VOC_Term values (@nextTermKey, 38, 'Targeted', null, 21, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+1, 38, 'Endonuclease-mediated', null, 22, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+2, 38, 'Transposon Concatemer', null, 23, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+3, 38, 'Transgenic', null, 24, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+4, 38, 'Other (see notes)', null, 25, 0, 1001, 1001, getdate(), getdate())

go

EOSQL
date | tee -a ${LOG}

#
# create new vocabulary
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleleAttribute.config | tee -a ${LOG}

#
# migrate existing ALL_Allele._Allele_Type_key from old type to new type
# add appropriate allele-attribute
#
#cd ${DBUTILS}/mgidbmigration/TR11515/alleletype
#./alleletype.py | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- delete old VOC_Term._Vocab_key = 38 terms that are no longer used
-- (exclude the new terms added as part of this projects)
delete VOC_Term
from VOC_Term t
where t._Vocab_key = 38
and not exists (select 1 from ALL_Allele a where t._Term_key = a._Allele_Type_key)
and not exists (select 1 from ALL_CellLine_Derivation a where t._Term_key = a._DerivationType_key)
and t.term not in ('Endonuclease-mediated', 'Transposon Concatemer', 'Other (see notes)')
go

-- verify
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 38 order by term
go

select vv.* 
from VOC_Vocab v, VOC_Term vv 
where v.name = 'Allele Subtype' 
and v._Vocab_key = vv._Vocab_key
go

-- should return (0) results
select a.symbol, a._Allele_key, a._Allele_Type_key, t.term
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
and t.term in (
 'Targeted (Floxed/Frt)',
 'Targeted (knock-in)',
 'Targeted (knock-out)',
 'Targeted (other)',
 'Targeted (Reporter)',
 'Transgenic (Cre/Flp)',
 'Transgenic (random, expressed)',
 'Transgenic (random, gene disruption)',
 'Transgenic (Reporter)',
 'Transgenic (Transposase)'
)
order by a.symbol
go

-- should return (0) results
select a.name, a._Derivation_key, a._DerivationType_key, t.term
from ALL_CellLine_Derivation a, VOC_Term t
where a._DerivationType_key = t._Term_key
and t.term in (
 'Targeted (Floxed/Frt)',
 'Targeted (knock-in)',
 'Targeted (knock-out)',
 'Targeted (other)',
 'Targeted (Reporter)',
 'Transgenic (Cre/Flp)',
 'Transgenic (random, expressed)',
 'Transgenic (random, gene disruption)',
 'Transgenic (Reporter)',
 'Transgenic (Transposase)'
)
order by a.name
go

-- should return (?) results
select count(a._Allele_key)
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
and t.term in (
 'Targeted',
 'Endonuclease-mediated',
 'Transposon Concatemer',
 'Transgenic'
)
go

-- should return (0) results
select count(a._Derivation_key)
from ALL_CellLine_Derivation a, VOC_Term t
where a._DerivationType_key = t._Term_key
and t.term in (
 'Targeted',
 'Endonuclease-mediated',
 'Transposon Concatemer',
 'Transgenic',
 'Other (see notes)'
)
go

-- 
select distinct t.term
from ALL_CellLine_Derivation a, VOC_Term t
where a._DerivationType_key = t._Term_key
order by t.term
go

-- should return (0) results
select t.*
from VOC_Term t
where t._Vocab_key = 38
and not exists (select 1 from ALL_Allele a where t._Term_key = a._Allele_Type_key)
and not exists (select 1 from ALL_CellLine_Derivation a where t._Term_key = a._DerivationType_key)
and t.term not in ('Endonuclease-mediated', 'Transposon Concatemer', 'Other (see notes)')
go

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

