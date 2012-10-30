#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 2 running loads)
#
# 1. use current Sanger BioMart data
# 2. run Sanger dataload with Sanger BioMart as input
# 3. run 'runtest_part1' to load the Sanger test data
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
echo ${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}
${SANGERMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}

# run test - part 1 - sanger biomart input file + additonal genotypes
echo ${SANGERMPLOAD}/test/runtest_part1.sh | tee -a ${LOG}
${SANGERMPLOAD}/test/runtest_part1.sh | tee -a ${LOG}

# the genotypeload-er should handle this; but if you have a problem...
# run allcacheload
#${ALLCACHELOAD}/allelecombination.csh | tee -a ${LOG}

# cache tables
${MGICACHELOAD}/vocallele.csh | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh | tee -a ${LOG}
${MGICACHELOAD}/vocmarker.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
