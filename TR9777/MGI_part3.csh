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

###------------------###
###--- QC reports ---###
###------------------###

#date | tee -a ${LOG}
#echo 'QC Reports' | tee -a ${LOG}
#${QCRPTS}/qcnightly_reports.sh

#date | tee -a ${LOG}
#echo 'QC Reports' | tee -a ${LOG}
#${QCRPTS}/qcweekly_reports.sh

#date | tee -a ${LOG}
#echo 'QC Reports' | tee -a ${LOG}
#${QCRPTS}/qcmonthly_reports.sh

###----------------------###
###--- Public reports ---###
###----------------------###

#date | tee -a ${LOG}
#echo 'Public Reports' | tee -a ${LOG}
#${PUBRPTS}/nightly_reports.sh

#date | tee -a ${LOG}
#echo 'Public Reports' | tee -a ${LOG}
#${PUBRPTS}/weekly_reports.sh

#date | tee -a ${LOG}
#echo 'Public Reports' | tee -a ${LOG}
#${PUBRPTS}/monthly_reports.sh

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
source ${PUBRPTS}/Configuration
cd ${PUBRPTS}/daily
./HMD_HumanSequence.py
./MRK_GOHuman.py
./MRK_SwissProt.py
./MRK_SwissProt_Sequence.py
./MRK_SwissProt_TrEMBL.py
./GO_gene_association.py

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
