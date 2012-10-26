#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 3 running reports)
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
echo ${SANGERMPLOAD}/test/runtest_part2.sh | tee -a ${LOG}
${SANGERMPLOAD}/test/runtest_part2.sh | tee -a ${LOG}

# run test - part 3 - review
echo ${SANGERMPLOAD}/test/runtest_part3.sh | tee -a ${LOG}
${SANGERMPLOAD}/test/runtest_part3.sh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
