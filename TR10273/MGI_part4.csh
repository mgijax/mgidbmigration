#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 4 running loads)
#
# 1. run cache loads
# 2. run qc/public reports
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

#date | tee -a ${LOG}
#echo 'Create Dummy Sequences' | tee -a ${LOG}
#${SEQCACHELOAD}/seqdummy.csh

#date | tee -a ${LOG}
#echo 'Load Sequence/Coordinate Cache Table' | tee -a ${LOG}
#${SEQCACHELOAD}/seqcoord.csh
#date | tee -a ${LOG}
#echo 'Load Sequence/Marker Cache Table' | tee -a ${LOG}
#${SEQCACHELOAD}/seqmarker.csh
#date | tee -a ${LOG}
#echo 'Load Sequence/Probe Cache Table' | tee -a ${LOG}
#${SEQCACHELOAD}/seqprobe.csh
#date | tee -a ${LOG}
#echo 'Load Sequence/Description Cache Table' | tee -a ${LOG}
#${SEQCACHELOAD}/seqdescription.csh

date | tee -a ${LOG}
echo 'Load Marker/Label Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
date | tee -a ${LOG}
echo 'Load Marker/Reference Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh
date | tee -a ${LOG}
echo 'Load Marker/Homology Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkhomology.csh
date | tee -a ${LOG}
echo 'Load Marker/Location Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh
date | tee -a ${LOG}
echo 'Load Marker/Probe Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkprobe.csh
date | tee -a ${LOG}
echo 'Load Marker/MCV Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkmcv.csh

#date | tee -a ${LOG}
#echo 'Load Genetic Map Tables' | tee -a ${LOG}
#${GENMAPLOAD}/bin/genmapload.sh

date | tee -a ${LOG}
echo 'Load Allele/Label Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
date | tee -a ${LOG}
echo 'Load Allele/Combination Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecombination.csh
date | tee -a ${LOG}
echo 'Load Marker/OMIM Cache Table' | tee -a ${LOG}
# the OMIM cache depends on the allele combination note 3
${MRKCACHELOAD}/mrkomim.csh
date | tee -a ${LOG}
echo 'Load Allele/Strain Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allstrain.csh
date | tee -a ${LOG}
echo 'Load Allele/CRE Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecrecache.csh

date | tee -a ${LOG}
echo 'Load Bib Citation Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/bibcitation.csh
date | tee -a ${LOG}
echo 'Load Image Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/imgcache.csh

date | tee -a ${LOG}
echo 'Load Voc/Count Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
date | tee -a ${LOG}
echo 'Load Voc/Marker Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocmarker.csh
date | tee -a ${LOG}
echo 'Load Voc/Allele Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocallele.csh

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcmonthly_reports.csh

# this must run before the generateGIAAssoc.csh script
# which depends on GIA_???.py reports
date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh

date | tee -a ${LOG}
echo 'Daily Public Reports' | tee -a ${LOG}
${PUBRPTS}/nightly_reports.csh

date | tee -a ${LOG}
echo 'Weekly Public Reports' | tee -a ${LOG}
${PUBRPTS}/weekly_reports.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
