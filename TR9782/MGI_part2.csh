#!/bin/csh -fx

#
# Migration part 2 for TR9782 -- MGI4.33
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
#source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

#					 	 #
# RUN STUFF THAT WILL RUN FROM saturdaytasks.csh #
#						 #

###---------------------------------###
###--- Run Protein Ontology load ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'Run Pro Load' | tee -a ${LOG}
${PROLOAD}/bin/proload.sh

###---------------------------------###
###--- Run Gene Model Loads      ---###
###---------------------------------###
date | tee -a ${LOG}
# remove all lastrun files
rm /data/loads/mgi/genemodelload/input/*.lastrun

echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensembl

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run VEGA Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh vega

###----------------------------------------###
###--- run all the Saturday cacheloads  ---###
###----------------------------------------###
date | tee -a ${LOG}
echo 'Load Sequence Cache tables' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh
${SEQCACHELOAD}/seqmarker.csh
${SEQCACHELOAD}/seqdescription.csh

date | tee -a ${LOG}
echo 'Load Marker Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
${MRKCACHELOAD}/mrkref.csh
${MRKCACHELOAD}/mrklocation.csh

date | tee -a ${LOG}
echo 'Load Allele Cache tables' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
${ALLCACHELOAD}/allelecombination.csh
${ALLCACHELOAD}/allstrain.csh
${ALLCACHELOAD}/allelecrecache.csh

date | tee -a ${LOG}
echo 'Load Voc Cache tables' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
${MGICACHELOAD}/vocmarker.csh

#                                                #
# RUN STUFF THAT WILL RUN FROM saturdaytasks.csh #
#                                                #

###---------------------------------###
###--- Run EntrezGene Loads      ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'EntrezGene Data Provider load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Mouse EntrezGene load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

###---------------------------------###
###--- Run SWISS-PROT Load       ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'SWISS-PROT Load' | tee -a ${LOG}
${SWISSLOAD}/preswissload.csh
${SWISSLOAD}/swissload.csh

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
