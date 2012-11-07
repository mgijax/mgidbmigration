#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 3)
#
# 1. run 'runtest_part2' to load additional genotypes & annotations for testing
# 2. run 'runtest_part3' to review the tests (pass/fail)
#
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

# run test - part 2 - MP & OMIM annotations
echo ${HTMPLOAD}/test/runtest_part2.sh | tee -a ${LOG}
${HTMPLOAD}/test/runtest_part2.sh | tee -a ${LOG}

# run test - part 3 - review
echo ${HTMPLOAD}/test/runtest_part3.sh | tee -a ${LOG}
${HTMPLOAD}/test/runtest_part3.sh | tee -a ${LOG}

#
# log into cardolan and run the exporter
#

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
