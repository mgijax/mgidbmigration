#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 2 running loads)
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

# run sangermpload
# make sure factory settings
#cp ${SANGERMPLOAD}/sangermpload.config.default ${SANGERMPLOAD}/sangermpload.config
#cp ${SANGERMPLOAD}/annotload.config.default ${SANGERMPLOAD}/annotload.config
echo ${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}
${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}

# run test - part 1 - sanger biomart input file + additonal genotypes
echo ${SANGERMPLOAD}/test/runtest_part1.sh | tee -a ${LOG}
${SANGERMPLOAD}/test/runtest_part1.sh | tee -a ${LOG}

# the genotypeload-er should handle this; but if you have a problem...
# run allcacheload
#${ALLCACHELOAD}/allelecombination.csh | tee -a ${LOG}

#
# make sure Allele Detail Display notes were created
#
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select count(g._Genotype_key)
from GXD_Genotype g
where g._CreatedBy_key = 1524
and exists (select 1 from MGI_Note n
where n._MGIType_key = 12
and n._NoteType_key = 1018
and n._Object_key = g._Genotype_key)
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
