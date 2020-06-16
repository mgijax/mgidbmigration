#!/bin/csh -fx

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
echo '--- starting file download' | tee -a $LOG

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
        ${MIRROR_WGET}/download_package ftp.ncbi.nih.gov.gbNC
        ${MIRROR_WGET}/download_package ftp.ncbi.nih.gov.refseqDaily
        scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot/uniprotmus.dat

        breaksw
endsw

date | tee -a ${LOG}
echo 'gbseqload to test prb_source autosequence'
#${GBSEQLOAD}/bin/gbseqload.sh

echo 'refseqload to test prb_source autosequence'
#${REFSEQLOAD}/bin/refseqload.sh

echo 'spseqload trembl to test prb_source autosequence'
${SPSEQLOAD}/bin/spseqload.sh trseqload.config

date | tee -a ${LOG}
echo '--- finished sequence loads' | tee -a ${LOG}
