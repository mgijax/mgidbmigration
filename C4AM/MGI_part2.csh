#!/bin/csh -fx

#
# Migration for C4AM/B38
# (part 2 running loads)
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###--------------------------------------------------------------###
###--- run loads                                              ---###
###--------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Load MCV Annotations' | tee -a ${LOG}
${MCVLOAD}/bin/mcvload.sh

date | tee -a ${LOG}
echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensembl

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run VEGA Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh vega

date | tee -a ${LOG}
echo 'EntrezGene Data Provider Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

date | tee -a ${LOG}
echo 'UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh

# QTL load goes here

#date | tee -a ${LOG}
#echo 'Marker Coordinate Load' | tee -a ${LOG}
#${MRKCOORDLOAD}/bin/mrkcoordload.sh

# gene trap  load goes here w/o cacheloads and alomrkload

# Old TIGM migration goes here

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
