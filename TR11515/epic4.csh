#!/bin/csh -fx

#
# Migration for TR11515
# epic 4 : allele type
# sto? : ?
#
# _Vocab_key = 38
#
# * migration existing _Vocab_key = 38 to new terms
#	- ALL_Allele._Allele_Type_key
#	- ALL_CellLine_Derivation._DerivationType_key
#
# * create new vocabulary for "Allele Attribute" (see TR11515/epic4 directory)
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

delete from VOC_Vocab where name = 'Allele Attribute'
go

-- add new VOC_Term._Vocab_key = 38 terms (both old and new terms exist)
declare @maxKey integer
select @maxKey = max(_Term_key) + 1 from VOC_Term

insert into VOC_Term values (@maxKey, 38, 'Targeted', null, 21, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@maxKey+1, 38, 'Endonuclease-mediated', null, 22, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@maxKey+2, 38, 'Transposon Concatemer', null, 23, 0, 1001, 1001, getdate(), getdate())
insert into VOC_Term values (@maxKey+3, 38, 'Transgenic', null, 24, 0, 1001, 1001, getdate(), getdate())

go

EOSQL
date | tee -a ${LOG}

#
# create new vocabulary for "Allele Attribute"
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/epic4/alleleAttribute.config | tee -a ${LOG}

#
# migrate existing ALL_Allele._Allele_Type_key from old type to new type
# add appropriate allele-attribute
#
./epic4/epic4.py | tee -a ${LOG}


#
# delete old VOC_Term._Vocab_key = 38 terms
#

#
# verify
#

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

