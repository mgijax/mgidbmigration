#!/bin/csh -fx

#
# Migration part 2 for TR9777 -- MGI4.33
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###---------------------------------###
###--- Run EntrezGene Loads      ---###
###--- Comment-out for Production run ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'Uniprot vs. SwissProt comparison' | tee -a ${LOG}
${UNIPROTLOAD}/bin/makeSwissDiffFile.sh

###---------------------------------###
###--- Run EntrezGene Loads      ---###
###--- Comment-out for Production run ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'EntrezGene Data Provider load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Mouse EntrezGene load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

###---------------------------------###
###--- Run UniProt Load       ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh

###---------------------------------###
###--- run all Sunday cacheloads ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'Create Dummy Sequences' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh

date | tee -a ${LOG}
echo 'Load Sequence Cache tables' | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh
${SEQCACHELOAD}/seqprobe.csh
${SEQCACHELOAD}/seqdescription.csh

date | tee -a ${LOG}
echo 'Load Marker Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
${MRKCACHELOAD}/mrkref.csh
${MRKCACHELOAD}/mrkhomology.csh
${MRKCACHELOAD}/mrklocation.csh
${MRKCACHELOAD}/mrkomim.csh
${MRKCACHELOAD}/mrkprobe.csh

date | tee -a ${LOG}
echo 'Load GOA annotations' | tee -a ${LOG}
${GOALOAD}/goa.csh

date | tee -a ${LOG}
echo 'Load Allele Cache tables' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
${ALLCACHELOAD}/allelecombination.csh
${ALLCACHELOAD}/allstrain.csh

date | tee -a ${LOG}
echo 'Load Image Cache table' | tee -a ${LOG}
${MGICACHELOAD}/imgcache.csh

date | tee -a ${LOG}
echo 'Load Voc Cache tables' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
${MGICACHELOAD}/vocmarker.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
