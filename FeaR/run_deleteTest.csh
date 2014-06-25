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
setenv INPUT /data/loads/mgi/fearload/input
setenv LOGS /data/loads/mgi/fearload/logs
setenv REPORTS /data/loads/mgi/fearload/reports
setenv OUTPUT /data/loads/mgi/fearload/output

echo "--- Run delete file 1 ---" | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/US163_testData/US163_delete.txt ${INPUT}/fearload.txt

#${FEARLOAD}/bin/fearload.sh

# move output directories
if (  -d ${LOGS}.US163_delete ) then
   rm -rf  ${LOGS}.US163_delete
endif
mv ${LOGS} ${LOGS}.US163_delete
mkdir  ${LOGS}

if (  -d ${REPORTS}.US163_delete ) then
   rm -rf  ${REPORTS}.US163_delete
endif
mv ${REPORTS} ${REPORTS}.US163_delete
mkdir  ${REPORTS}

if (  -d ${OUTPUT}.US163_delete ) then
   rm -rf  ${OUTPUT}.US163_delete
endif
mv ${OUTPUT} ${OUTPUT}.US163_delete
mkdir  ${OUTPUT}

echo "--- Done running Deletes  ---"

date | tee -a ${LOG}
