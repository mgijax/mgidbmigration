#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# Transmission
#
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use $MGD_DBNAME
go

select distinct aa._Allele_key, aa.symbol, c.jnumID
from GXD_AlleleGenotype g, VOC_Annot a, VOC_Evidence e, ALL_Allele aa, BIB_Citation_Cache c
where g._Genotype_key = a._Object_key
and a._AnnotType_key = 1002
and g._Allele_key = aa._Allele_key
and aa.isWildType = 0
and aa._Transmission_key != 3982951
and a._Annot_key = e._Annot_key
and e._Refs_key = c._Refs_key
and c.jnumID in ('J:165965', 'J:175295')
order by aa.symbol
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

# exec ALL_updateTransmission 1002, 167061, 'htmpload'
# exec ALL_updateTransmission 1002, 176391, 'htmpload'

