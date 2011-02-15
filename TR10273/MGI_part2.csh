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

###--------------------------------------------------------------###
###--- run Europhenome genotype annotation load               ---###
###--------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Europhenome Genotype Annotation Load' | tee -a ${LOG}
${GENOTYPEANNOTLOAD}/bin/genotypeannotload.sh euro_genotypeannotload.config

exit 0

###--------------------------------------------------------------###
###--- run cacheloads		      	                      ---###
###--------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Load Marker Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
${MRKCACHELOAD}/mrkref.csh
${MRKCACHELOAD}/mrkhomology.csh
${MRKCACHELOAD}/mrklocation.csh
${MRKCACHELOAD}/mrkomim.csh
${MRKCACHELOAD}/mrkprobe.csh

date | tee -a ${LOG}
echo 'Load Allele Cache tables' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
${ALLCACHELOAD}/allelecombination.csh
${ALLCACHELOAD}/allstrain.csh

date | tee -a ${LOG}
echo 'Load Voc Cache tables' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
${MGICACHELOAD}/vocmarker.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
