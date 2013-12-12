#!/bin/csh -fx

#
# Migration for TR11515
#
# _Vocab_key = new
#
# * create new vocabulary for "Allele Collection" (see TR11515/allelecollection directory)
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

-- start: allows a fresh of a previous migration
delete from VOC_Vocab where name = 'Allele Collection'
go
-- end: allows a fresh of a previous migration

-- rename ALL_Allele
sp_rename ALL_Allele, ALL_Allele_Old
go

EOSQL
date | tee -a ${LOG}

#
# create new vocabulary for "Allele Collection"
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/allelecollection/alleleCollection.config | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @collectionKey integer
select @collectionKey = _Term_key from VOC_Vocab v, VOC_Term t
where v.name = 'Allele Collection'
and v._Vocab_key = t._Vocab_key
and t.term = 'Not Specified'

insert into ALL_Allele
select _Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _Allele_Status_key,
_Transmission_key, @collectionKey, symbol, name, nomenSymbol, 
isWildType, isExtinct, isMixed,
_CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key, approval_date, creation_date, modification_date
from ALL_Allele_Old
go

EOSQL
date | tee -a ${LOG}

#
# migrate
#
#cd ${DBUTILS}/mgidbmigration/TR11515/allelecollection
#./allelecollection.py | tee -a ${LOG}

exit 0

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select vv.* 
from VOC_Vocab v, VOC_Term vv 
where v.name = 'Allele Attribute' 
and v._Vocab_key = vv._Vocab_key
go

select a.symbol, vv.term
from VOC_Vocab v, VOC_Term vv, ALL_Allle a
where v.name = 'Allele Attribute' 
and v._Vocab_key = vv._Vocab_key
and vv._Term_key = a._Collection_key
go

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

