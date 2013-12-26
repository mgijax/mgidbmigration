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

# start a new log file for this migration, and add a datestamp

setenv LOG ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-noattribute-SQL.csh.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select aa.accID,
substring(a.symbol,1,50),
substring(ttt.term,1,20),
substring(t.term,1,20) as generationType
from ALL_Allele a, ACC_Accession aa, VOC_Term t, VOC_Term ttt
where a._Allele_Type_key = t._Term_key
and t.term in (
 'Targeted',
 'Transgenic',
 'Endonuclease-mediated'
)
and a._Collection_key = ttt._Term_key
and a._Allele_key = aa._Object_key
and aa._MGIType_key = 11
and aa._LogicalDB_key = 1
and not exists (select 1 from VOC_Annot va
	where a._Allele_key = va._Object_key and va._AnnotType_key = 1014
	)
order by generationType, a.symbol
go

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

