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

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

cd ${DBUTILS}/mgidbmigration/TR11515/alleletype

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
insert into VOC_Term values (@nextTermKey+2, 38, 'Transgenic', null, 22, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+3, 38, 'Endonuclease-mediated', null, 23, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@nextTermKey+4, 38, 'Other (see notes)', null, 24, 0, 1001, 1001, getdate(), getdate())

go

EOSQL
date | tee -a ${LOG}

#
# create new vocabulary
#
date | tee -a ${LOG}
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleleAttribute.config | tee -a ${LOG}
date | tee -a ${LOG}

#
# migrate existing ALL_Allele._Allele_Type_key from old type to new type
# add appropriate allele-attribute
#
date | tee -a ${LOG}
./alleletype.py | tee -a ${LOG}
${MGI_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} VOC_Annot
date | tee -a ${LOG}

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

-- reorder the sequence number
exec VOC_reorderTerms 38
go

EOSQL
date | tee -a ${LOG}

# verify migration
date | tee -a ${LOG}
./alleletypeSQL.csh | tee -a ${LOG}
date | tee -a ${LOG}
./alleletypeSQL2.csh | tee -a ${LOG}
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

