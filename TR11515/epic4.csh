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

EOSQL
date | tee -a ${LOG}

#
# create new vocabulary for "Allele Attribute"
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/alleleAttribute.config | tee -a ${LOG}

#
# migrate existing _Vocab_key = 38 to the new terms (generationType.txt)
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

