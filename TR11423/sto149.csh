#!/bin/csh -fx

#
# Migration for TR11423
# sto149 : add new synonym-type, process Sue's OMIM/OBO file
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

# add new synonym type
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

delete from MGI_SynonymType where synonymType = 'disease cluster'
go

declare @synType integer
select @synType = max(_SynonymType_key) + 1
from MGI_SynonymType

insert MGI_SynonymType (_SynonymType_key, _MGIType_key, _Organism_key, 
        synonymType, definition, allowOnlyOne)
values (@synType, 13, NULL, 'disease cluster', 'used to store the disease-cluster-OBO data', 0)
go

select * from MGI_SynonymType where synonymType = 'disease cluster'
go


EOSQL
date | tee -a ${LOG}

#
# call vocload
#
date | tee -a ${LOG}
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a ${LOG}
date | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select a.accID, s._Object_key, substring(s.synonym, 1, 50) as synonym
from MGI_Synonym s, ACC_Accession a
where s._SynonymType_key = 1031
and s._Object_key = a._Object_key
and s._MGIType_key = a._MGIType_key
and a.preferred = 1
order by a.accID
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

