#!/bin/csh -fx

#
# run delete test files for FeaR builds only
#
# Products:
# fearload
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

echo "--- Run Deletes ---" 
setenv INPUT /data/loads/scrum-bob/mgi/fearload/input
setenv LOGS /data/loads/scrum-bob/mgi/fearload/logs
setenv REPORTS /data/loads/scrum-bob/mgi/fearload/reports
setenv OUTPUT /data/loads/scrum-bob/mgi/fearload/output

 ${LOG}
echo "--- Run delete file 1 ---" | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/testing/US60_testing/US60_DEL_Alpha.txt

#${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.US60_DEL_Alpha.txt
mkdir  ${LOGS}
mv ${REPORTS}  ${REPORTS}.US60_DEL_Alpha.txt
mkdir ${REPORTS}
mv ${OUTPUT}  ${OUTPUT}.US60_DEL_Alpha.txt
mkdir ${OUTPUT}

echo "--- Done running Deletes  ---"

date | tee -a ${LOG}
