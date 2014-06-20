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

date | tee -a ${LOG}
echo "--- Run Feature Relationship Loads ---" | tee -a ${LOG}

setenv INPUT /data/loads/mgi/fearload/input
setenv LOGS /data/loads/mgi/fearload/logs
setenv REPORTS /data/loads/mgi/fearload/reports
setenv OUTPUT /data/loads/mgi/fearload/output

date | tee -a ${LOG}
echo "--- Run test file 1 ---" | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/US142_testData/Interacts_TempTest1.txt  ${INPUT}/fearload.txt

${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.Interacts_TempTest1
mkdir  ${LOGS}
mv ${REPORTS}  ${REPORTS}.Interacts_TempTest1
mkdir ${REPORTS}
mv ${OUTPUT}  ${OUTPUT}.Interacts_TempTest1
mkdir ${OUTPUT}

date | tee -a ${LOG}
echo "--- Run test file 2 ---"  | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/US142_testData/Mutations_TempTest1.txt  ${INPUT}/fearload.txt

${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.Mutations_TempTest1
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.Mutations_TempTest1
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.Mutations_TempTest1
mkdir ${OUTPUT}

date | tee -a ${LOG}
echo "--- Run Howard cluster file  ---"  | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/Cluster_stuff/clusters_2a_howard_04April2014.txt  ${INPUT}/fearload.txt

${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.howard_cluster
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.howard_cluster
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.howard_cluster
mkdir ${OUTPUT}

date | tee -a ${LOG}
echo "--- Run Wendy cluster file  ---"  | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/Cluster_stuff/wp_cluster_membership_upload_24Mar2014.txt ${INPUT}/fearload.txt

${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.wendy_cluster
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.wendy_cluster
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.wendy_cluster
mkdir ${OUTPUT}

date | tee -a ${LOG}
echo "--- Run mutations file  ---" | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/Mutation_stuff/MutationOverlaps_2.txt ${INPUT}/fearload.txt

${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.mutations
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.mutations
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.mutations
mkdir ${OUTPUT}

date | tee -a ${LOG}
echo "--- Run interacts file  ---" | tee -a ${LOG}
rm ${INPUT}/fearload.txt
ln -s /mgi/all/wts_projects/11500/11560/Interacts_stuff/microT_Tarbase_upload_28Apr2014_1.txt ${INPUT}/fearload.txt

${FEARLOAD}/bin/fearload.sh

# move output directories
mv ${LOGS} ${LOGS}.interacts
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.interacts
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.interacts
mkdir ${OUTPUT}

date | tee -a ${LOG}
echo "--- Done running Feature Relationship Loads  ---" | tee -a ${LOG}

date | tee -a ${LOG}
