#!/bin/csh -fx

#
# TR12250/Literature Triage
#
# (part 2 - run loads)
#
# BEFORE adding a call to a load:
# . Delete any "lastrun" files that may exist in the "input" directory
# . Copy any new /data/downloads files OR run mirror_wget package, if necessary
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 2' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#
## copy /data/downloads files needed for loads (move to part2?)
#
#date | tee -a ${LOG}
#echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
#scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology

#
# jfilescanner
#
date | tee -a ${LOG}
echo 'running jfilescanner migration (this runs the BIB_Workflow_Data piece only)' | tee -a $LOG
cd jfilescanner
./jfilescanner.csh | tee -a $LOG || exit 1
cd ..

#
# littriageload
#
#date | tee -a ${LOG}
#echo 'running littriageload' | tee -a $LOG
#./littriage | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
