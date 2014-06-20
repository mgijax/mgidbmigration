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
if (  -d ${LOGS}.Interacts_TempTest1 ) then
   rm -rf  ${LOGS}.Interacts_TempTest1
endif
if (  -d ${REPORTS}.Interacts_TempTest1 ) then
   rm -rf  ${REPORTS}.Interacts_TempTest1
endif
if (  -d ${OUTPUT}.Interacts_TempTest1 ) then
   rm -rf  ${OUTPUT}.Interacts_TempTest1
endif

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
if (  -d ${LOGS}.Mutations_TempTest1 ) then
   rm -rf  ${LOGS}.Mutations_TempTest1
endif
if (  -d ${REPORTS}.Mutations_TempTest1 ) then
   rm -rf  ${REPORTS}.Mutations_TempTest1
endif
if (  -d ${OUTPUT}.Mutations_TempTest1 ) then
   rm -rf  ${OUTPUT}.Mutations_TempTest1
endif

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
if (  -d ${LOGS}.howard_cluster ) then
   rm -rf  ${LOGS}.howard_cluster
endif
if (  -d ${REPORTS}.howard_cluster ) then
   rm -rf  ${REPORTS}.howard_cluster
endif
if (  -d ${OUTPUT}.howard_cluster ) then
   rm -rf  ${OUTPUT}.howard_cluster
endif

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
if (  -d ${LOGS}.wendy_cluster ) then
   rm -rf  ${LOGS}.wendy_cluster
endif
if (  -d ${REPORTS}.wendy_cluster ) then
   rm -rf  ${REPORTS}.wendy_cluster
endif
if (  -d ${OUTPUT}.wendy_cluster ) then
   rm -rf  ${OUTPUT}.wendy_cluster
endif

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
if (  -d ${LOGS}.mutations ) then
   rm -rf  ${LOGS}.mutations
endif
if (  -d ${REPORTS}.mutations ) then
   rm -rf  ${REPORTS}.mutations
endif
if (  -d ${OUTPUT}.mutations ) then
   rm -rf  ${OUTPUT}.mutations
endif

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
if (  -d ${LOGS}.interacts ) then
   rm -rf  ${LOGS}.interacts
endif
if (  -d ${REPORTS}.interacts ) then
   rm -rf  ${REPORTS}.interacts
endif
if (  -d ${OUTPUT}.interacts ) then
   rm -rf  ${OUTPUT}.interacts
endif

mv ${LOGS} ${LOGS}.interacts
mkdir  ${LOGS}
mv ${REPORTS} ${REPORTS}.interacts
mkdir ${REPORTS}
mv ${OUTPUT} ${OUTPUT}.interacts
mkdir ${OUTPUT}

date | tee -a ${LOG}
echo "--- Done running Feature Relationship Loads  ---" | tee -a ${LOG}

date | tee -a ${LOG}
