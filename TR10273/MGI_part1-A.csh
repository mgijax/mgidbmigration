#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 1 - migration of existing data into new structures)

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

delete from VOC_Evidence_Property where _PropertyTerm_key = 8809651
go

declare @nextProperty integer
select @nextProperty = max(_EvidenceProperty_key) from VOC_Evidence_Property
declare @propertyKey integer
select @propertyKey = _Term_key from VOC_Term where _Vocab_key = 86

select seq = identity(10), e._AnnotEvidence_key
into #toadd
from VOC_Annot a, VOC_Evidence e
where a._AnnotType_key = 1002
and a._Annot_key = e._Annot_key

insert into VOC_Evidence_Property
select @nextProperty + seq,_AnnotEvidence_key,@propertyKey,1,1,'NA',1001,1001,getdate(),getdate()
from #toadd
go

EOSQL

/mgi/all/wts_projects/11100/11110/tr11110.csh | tee -a ${LOG}
#./sexauto.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

