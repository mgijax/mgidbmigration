#!/bin/csh -fx

#
# Migration for TR11515/Allele Type
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

setenv TYPELOG $0.log
rm -rf ${TYPELOG}
touch ${TYPELOG}

cd ${DBUTILS}/mgidbmigration/TR11515/alleletype

date | tee -a ${TYPELOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${TYPELOG}

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
insert into VOC_Term values (@nextTermKey+2, 38, 'Transgenic', null, 22, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+3, 38, 'Endonuclease-mediated', null, 23, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+4, 38, 'Other (see notes)', null, 24, 0, 1001, 1001, getdate(), getdate())

go

EOSQL
date | tee -a ${TYPELOG}

#
# create new vocabulary
#
date | tee -a ${TYPELOG}
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleleAttribute.config | tee -a ${TYPELOG}
date | tee -a ${TYPELOG}

#
# migrate existing ALL_Allele._Allele_Type_key from old type to new type
# add appropriate allele-attribute
#
date | tee -a ${TYPELOG}
./alleletype.py | tee -a ${TYPELOG}
${MGI_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} VOC_Annot
date | tee -a ${TYPELOG}

date | tee -a ${TYPELOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${TYPELOG}

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

-- reorder the sequence number
exec VOC_reorderTerms 38
go

EOSQL
date | tee -a ${TYPELOG}

# verify migration
date | tee -a ${TYPELOG}
echo 'start: running migration reports...'
./alleletypeSQL.csh
./alleletype-after-SQL.csh
./alleletype-byprovider-SQL.csh
./alleletype-noattribute-SQL.csh
./alleletype-tma.csh
./alleletype-tmb.csh
./alleletype-tmc.csh
./alleletype-tmd.csh
./alleletype-tme.csh
./alleletype-tmx.csh
./alleletype-tmx1.csh
./alleletype-tmx2.csh
echo 'done: running migration reports...'
date | tee -a ${TYPELOG}

#
# compare alleletype-before-SQL.csh.log and alleletype-after-SQL.csh.log
#
grep "^ Targeted" alleletype-before-SQL.csh.log
#grep "Targeted" alleletype-after-SQL.csh.log


###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${TYPELOG}
echo "--- Finished" | tee -a ${TYPELOG}

