#!/bin/csh -fx

#
# Migration for Feature Relationship (FeaR) project
# (part 2 - run fear loads)
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

echo "--- Run Feature Relationship Loads ---"
setenv INPUT /data/loads/scrum-bob/mgi/fearload/input
setenv LOGS /data/loads/scrum-bob/mgi/fearload/logs
setenv REPORTS /data/loads/scrum-bob/mgi/fearload/reports
setenv OUTPUT /data/loads/scrum-bob/mgi/fearload/output

echo "--- Run test file 1 ---"
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/US142_testData/Interacts_TempTest1.txt  ${INPUT}/fearload.txt

#${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.Interacts_TempTest1
mkdir  ${LOGS}
mv ${REPORTS}  ${REPORTS}.Interacts_TempTest1
mkdir ${REPORTS}
mv ${OUTPUT}  ${OUTPUT}.Interacts_TempTest1
mkdir ${OUTPUT}

echo "--- Run test file 2 ---"
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/US142_testData/Mutations_TempTest1.txt  ${INPUT}/fearload.txt

#${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.Mutations_TempTest1
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.Mutations_TempTest1
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.Mutations_TempTest1
mkdir ${OUTPUT}

echo "--- Run cluster file  ---"
rm ${INPUT}/fearload.txt
ln -s /data/loads/scrum-bob/mgi/fearload/input/howard_wendy_cluster.txt  ${INPUT}/fearload.txt

#${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.howard_wendy_cluster
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.howard_wendy_cluster
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.howard_wendy_cluster
mkdir ${OUTPUT}

echo "--- Run mutations file  ---"
rm ${INPUT}/fearload.txt
ln -s /data/loads/scrum-bob/mgi/fearload/input/mutations.txt  ${INPUT}/fearload.txt

#${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.mutations
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.mutations
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.mutations
mkdir ${OUTPUT}

echo "--- Run interacts file  ---"
rm ${INPUT}/fearload.txt
ln -s /data/loads/scrum-bob/mgi/fearload/input/interacts.txt  ${INPUT}/fearload.txt

#${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.interacts
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.interacts
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.interacts
mkdir ${OUTPUT}

echo "--- Done running Feature Relationship Loads  ---"

date | tee -a ${LOG}
