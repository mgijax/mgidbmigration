#!/bin/csh -fx

#
# Migration for N2MO -- 
# (part 1 - optionally load dev database. Create new structures)

###----------------------###
###--- initialization ---###
###----------------------###

echo 'Running preload GO report' | tee -a ${LOG}
source ${PUBRPTS}/Configuration
${PUBRPTS}/daily/GO_gene_association.py

cp -p ${REPORTOUTPUTDIR}/gene_association.mgi ./gene_association.mgi.preload

date | tee -a ${LOG}
echo 'Load GOA/Human Annotations' | tee -a ${LOG}
source ../Configuration
${GOAHUMANLOAD}/bin/goahuman.sh

date | tee -a ${LOG}
echo 'Load GO/Rat Annotations' | tee -a ${LOG}
source ../Configuration
${GORATLOAD}/bin/gorat.sh

echo 'Running preload GO report' | tee -a ${LOG}
source ${PUBRPTS}/Configuration
${PUBRPTS}/daily/GO_gene_association.py

cp -p ${REPORTOUTPUTDIR}/gene_association.mgi ./gene_association.mgi.postload

# restore calling scripts configuration
source ../Configuration

