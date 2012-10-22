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

###-----------------------###
###--- final datestamp ---###
###-----------------------###

# run sangermpload
# make sure factory settings
#cp ${SANGERMPLOAD}/sangermpload.config.default ${SANGERMPLOAD}/sangermpload.config
#cp ${SANGERMPLOAD}/annotload.config.default ${SANGERMPLOAD}/annotload.config
#echo ${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}
#${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}

# run tests
#cp ${SANGERMPLOAD}/sangermpload.config.test ${SANGERMPLOAD}/sangermpload.config
#cp ${SANGERMPLOAD}/annotload.config.test ${SANGERMPLOAD}/annotload.config
#cp ${SANGERMPLOAD}/mgi_sanger_mp_test.tsv /data/loads/scrum-dog/mgi/sangermpload.test/input
#echo ${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}
#${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}

# run stand-alone genotype tests
#cp ${SANGERMPLOAD}/sangermpload.config.genotype.test ${SANGERMPLOAD}/sangermpload.config
#cp ${SANGERMPLOAD}/mgi_genotypeload_test.txt /data/loads/scrum-dog/mgi/sangermpload.test/input
#echo ${SANGERMPLOAD}/bin/makeGenotypeTest.sh | tee -a ${LOG}
#${SANGERMPLOAD}/bin/makeGenotypeTest.sh | tee -a ${LOG}

# run stand-alone annotation tests
cp ${SANGERMPLOAD}/mgi_annotload_test.txt /data/loads/scrum-dog/mgi/sangermpload.test/input
echo ${SANGERMPLOAD}/bin/makeAnnotationTest.sh | tee -a ${LOG}
${SANGERMPLOAD}/bin/makeAnnotationTest.sh | tee -a ${LOG}

# re-set factory settings
cp ${SANGERMPLOAD}/sangermpload.config.default ${SANGERMPLOAD}/sangermpload.config
cp ${SANGERMPLOAD}/annotload.config.default ${SANGERMPLOAD}/annotload.config

# the genotypeload-er should handle this
# run allcacheload
#${ALLCACHELOAD}/allelecombination.csh | tee -a ${LOG}

# run mrkomim.csh
#${MRKCACHELOAD}/mrkomim.csh | tee -a ${LOG}

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

# remind Kim that she needs to manually add genotype notes

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
