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
        date | tee -a ${LOG}
        echo 'run mirror_wget downloads' | tee -a $LOG 
        ${MIRROR_WGET}/download_package ftp.ncbi.nih.gov.entrez_gene
        #scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
        breaksw
endsw

echo 'running entrezgeneload/load files' | tee -a $LOG
${ENTREZGENELOAD}/loadFiles.csh | tee -a $LOG

echo 'running entrezgeneload/human/xenopustropicalis/xenopuslaevis' | tee -a $LOG
rm -rf ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/output/human/*
rm -rf ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/output/xenopus/*
rm -rf ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/output/xenopuslaevis/*
${ENTREZGENELOAD}/human/load.csh | tee -a $LOG
${ENTREZGENELOAD}/xenopus/load.csh | tee -a $LOG
${ENTREZGENELOAD}/xenopuslaevis/load.csh | tee -a $LOG

cd ${DBUTILS}/mgidbmigration/fl2b
echo 'running expresses-component migration' | tee -a $LOG
./esmigrate.csh | tee -a $LOG

echo 'running PAR mapping load and chr update' | tee -a $LOG
./par.csh | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
