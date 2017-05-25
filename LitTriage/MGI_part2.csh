#!/bin/csh -fx

#
# TR12250/Literature Triage
#
# (part 2 - run loads)
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
##date | tee -a ${LOG}
#echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
#scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology
#scp bhmgiapp01:/data/downloads/data.omim.org/omim.txt.gz /data/downloads/data.omim.org
#scp bhmgiapp01:/data/downloads/compbio.charite.de/jenkins/job/hpo.annotations/lastStableBuild/artifact/misc/phenotype_annotation.tab /data/downloads/compbio.charite.de/jenkins/job/hpo.annotations/lastStableBuild/artifact/misc
#scp bhmgiapp01:/data/downloads/dmdd.org.uk/DMDD_MP_annotations.tsv /data/downloads/dmdd.org.uk
#scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk
#scp /mgi/all/wts_projects/12200/12291/RelationshipVocab4_26_17b /data/loads/mgi/rvload/input/RelationshipVocab.obo
#scp /mgi/all/wts_projects/12200/12291/RNAI_load4_26_2017.txt /data/loads/mgi/fearload/input/fearload.txt

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
