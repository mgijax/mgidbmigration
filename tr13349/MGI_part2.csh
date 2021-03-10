#!/bin/csh -fx

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

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

#
# copy /data/downloads files needed for loads
# this only needs to happen on development servers
#
switch (`uname -n`)
    case bhmgiapp14ld:
    case bhmgidevapp01:
    case bhmgiap09lt.jax.org:
        date | tee -a ${LOG}
        echo 'mirror files/copy from production' | tee -a $LOG
	${MIRROR_WGET}/download_package alliancegenome.org.orthology
	${MIRROR_WGET}/download_package purl.obolibrary.org.pr
	${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo
	${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload
	${MIRROR_WGET}/download_package ftp.geneontology.org.goload
	${MIRROR_WGET}/download_package snapshot.geneontology.org.goload
	${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua

        breaksw
endsw

date | tee -a ${LOG}
echo 'autosequence check' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/autosequencecheck.csh | tee -a $LOG 

date | tee -a ${LOG}
echo 'processRelevance.sh' | tee -a $LOG
${LITTRIAGELOAD}/bin/processRelevance.sh | tee -a $LOG 

date | tee -a ${LOG}
echo 'processSecndary.sh' | tee -a $LOG
${LITTRIAGELOAD}/bin/processSecondary.sh | tee -a $LOG 

date | tee -a ${LOG}
echo '/bin/pubmed2geneload.sh' | tee -a $LOG
${PUBMED2GENELOAD}/bin/pubmed2geneload.sh | tee -a $LOG 

# new homology loads, these are run from sunday tasks so putting at end
#  DATA: copied from production /data/downloads above
date | tee -a ${LOG}
echo 'Run Homology Loads' | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh alliance_directload.config | tee -a $LOG || exit 1
${HOMOLOGYLOAD}/bin/homologyload.sh alliance_clusteredload.config | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'Run go loads - some updated to use Alliance homology' | tee -a ${LOG}
${GOLOAD}/go.sh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
