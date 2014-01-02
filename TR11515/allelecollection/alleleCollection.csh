#!/bin/csh -fx

#
# Migration for TR11515/Allele Collection
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

setenv COLLLOG $0.log
rm -rf ${COLLLOG}
touch ${COLLLOG}

cd ${DBUTILS}/mgidbmigration/TR11515/allelecollection

date | tee -a ${COLLLOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${COLLLOG}

use ${MGD_DBNAME}
go

delete from VOC_Term where _Vocab_key = 92
go

sp_rename ALL_Allele, ALL_Allele_Old
go

EOSQL
date | tee -a ${COLLLOG}

#
# create new vocabulary
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/allelecollection/alleleCollection.config | tee -a ${COLLLOG}

#
# schema
#
${MGD_DBSCHEMADIR}/table/ALL_Allele_create.object | tee -a ${COLLLOG}

date | tee -a ${COLLLOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${COLLLOG}

use ${MGD_DBNAME}
go

declare @collectionKey integer
select @collectionKey = _Term_key from VOC_Term
where _Vocab_key = 92
and term = 'Not Specified'

insert into ALL_Allele
select _Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _Allele_Status_key,
_Transmission_key, @collectionKey, symbol, name, nomenSymbol, 
isWildType, isExtinct, isMixed,
_CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key, approval_date, creation_date, modification_date
from ALL_Allele_Old
go

EOSQL
date | tee -a ${COLLLOG}

#
# schema
#
${MGD_DBSCHEMADIR}/default/ALL_Allele_bind.object | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/index/ALL_Allele_create.object | tee -a ${COLLLOG}

${MGD_DBSCHEMADIR}/key/ALL_Allele_drop.object | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/trigger/ALL_Allele_drop.object | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Term_drop.object | tee -a ${COLLLOG}

${MGD_DBSCHEMADIR}/key/ALL_Allele_create.object | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${COLLLOG}

${MGD_DBSCHEMADIR}/view/view_drop.csh | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/view/view_create.csh | tee -a ${COLLLOG}

${MGD_DBSCHEMADIR}/procedure/procedure_drop.csh | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/procedure/procedure_create.csh | tee -a ${COLLLOG}

${MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a ${COLLLOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a ${COLLLOG}

#
# migrate
#
date | tee -a ${COLLLOG}
./alleleCollection.py | tee -a ${COLLLOG}
date | tee -a ${COLLLOG}

#
# SQL reports
#
date | tee -a ${COLLLOG}
./alleleCollectionSQL.csh 
date | tee -a ${COLLLOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${COLLLOG}
echo "--- Finished" | tee -a ${COLLLOG}

