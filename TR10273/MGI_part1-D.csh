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

select aa.symbol, a._AllelePair_key
into #toupdate1
from GXD_AllelePair a, ALL_Allele_CellLine c, ALL_CellLine cc, ALL_Allele aa
where a._Allele_key_1 = c._Allele_key
and a._MutantCellLine_key_1 = null
and c._MutantCellLine_key = cc._CellLine_key
and cc.cellLine = 'Not Specified'
and a._Allele_key_1 = aa._Allele_key
order by aa.symbol
go

select aa.symbol, a._AllelePair_key
into #toupdate2
from GXD_AllelePair a, ALL_Allele_CellLine c, ALL_CellLine cc, ALL_Allele aa
where a._Allele_key_2 = c._Allele_key
and a._MutantCellLine_key_2 = null
and c._MutantCellLine_key = cc._CellLine_key
and cc.cellLine = 'Not Specified'
and a._Allele_key_2 = aa._Allele_key
order by aa.symbol
go

select * from #toupdate1
go

select * from #toupdate2
go

select aa.symbol, a._AllelePair_key, cc.cellLine
from GXD_AllelePair a, ALL_Allele_CellLine c, ALL_CellLine cc, ALL_Allele aa
where a._Allele_key_1 = c._Allele_key
and a._MutantCellLine_key_1 = null
and c._MutantCellLine_key = cc._CellLine_key
and cc.cellLine != 'Not Specified'
and a._Allele_key_1 = aa._Allele_key
order by aa.symbol
go

select aa.symbol, a._AllelePair_key, cc.cellLine
from GXD_AllelePair a, ALL_Allele_CellLine c, ALL_CellLine cc, ALL_Allele aa
where a._Allele_key_2 = c._Allele_key
and a._MutantCellLine_key_2 = null
and c._MutantCellLine_key = cc._CellLine_key
and cc.cellLine != 'Not Specified'
and a._Allele_key_2 = aa._Allele_key
order by aa.symbol
go

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

