#!/bin/csh -fx

#
# Migration for TR11515
#
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

setenv TMXLOG $0.log
rm -rf ${TMXLOG}
touch ${TMXLOG}

date | tee -a ${TMXLOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${TMXLOG}

use ${MGD_DBNAME}
go

(
select aa.accID, 
substring(a.symbol,1,50) as symbol,
substring(ttt.term,1,20) as collection,
substring(t.term,1,20) as generationType, 
substring(tt.term,1,20) as attributeType
from ALL_Allele a, ACC_Accession aa, VOC_Term t, VOC_Annot va, VOC_Term tt, VOC_Term ttt
where a._Allele_Type_key = t._Term_key
and a._Collection_key = ttt._Term_key
and a._Allele_key = va._Object_key
and va._AnnotType_key = 1014
and va._Term_key = tt._Term_key
and a._Allele_key = aa._Object_key
and aa._MGIType_key = 11
and aa._LogicalDB_key = 1
and a.symbol like '%<tm[0-9]a(%'
and exists (select 1 from ACC_Accession aa
         where a._Allele_key = aa._Object_key
         and aa._MGIType_key = 11
         and aa._LogicalDB_key in (125, 126, 138, 143)
         )

union

select aa.accID, 
substring(a.symbol,1,50) as symbol,
substring(ttt.term,1,20) as collection,
substring(t.term,1,20) as generationType, 
substring(tt.term,1,20) as attributeType
from ALL_Allele a, ACC_Accession aa, VOC_Term t, VOC_Annot va, VOC_Term tt, VOC_Term ttt
where a._Allele_Type_key = t._Term_key
and a._Collection_key = ttt._Term_key
and a._Allele_key = va._Object_key
and va._AnnotType_key = 1014
and va._Term_key = tt._Term_key
and a.symbol like '%<tm[0-9]a(%'
and a._Allele_key = aa._Object_key
and aa._MGIType_key = 11
and aa._LogicalDB_key = 1
and not exists (select 1 from ACC_Accession aa
         where a._Allele_key = aa._Object_key
         and aa._MGIType_key = 11
         and aa._LogicalDB_key in (125, 126, 138, 143)
         )
)
order by a.symbol, generationType, attributeType
go

EOSQL
date | tee -a ${TMXLOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${TMXLOG}
echo "--- Finished" | tee -a ${TMXLOG}

