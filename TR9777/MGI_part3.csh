#!/bin/csh -fx

#
# Migration part 3 for TR9777 -- MGI 4.33
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###----------------------###
###--- Public reports ---###
###----------------------###

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
source ${PUBRPTS}/Configuration
${PUBRPTS}/daily/GO_gene_association.py

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
