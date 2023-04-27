#!/bin/csh -fx

#
#  par loads
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
echo '--- starting par.csh' | tee -a $LOG

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
    case bhmgiap09lt.jax.org:
    case bhmgidevapp01:
        date | tee -a ${LOG}
        echo 'run mirror_wget downloads' | tee -a $LOG 
        #${MIRROR_WGET}/download_package ftp.ncbi.nih.gov.entrez_gene >>& ${LOG}
        breaksw
endsw

# rm lastrun file
rm ${DATALOADSOUTPUT}/mgi/partnerofload/input/lastrun

date | tee -a ${LOG}
echo 'Running PAR Mapping Load' | tee -a $LOG
${MAPPINGLOAD}/mappingonlyload.sh /mgi/all/wts2_projects/1000/WTS2-1080/parmappingload.config >>& ${LOG}

date | tee -a ${LOG}
echo 'Run Partner Of Load' | tee -a ${LOG}
${PARTNEROFLOAD}/bin/partnerofload.sh >>& ${LOG}

date | tee -a ${LOG}
echo 'Run genemodelload copydownload.sh ensembl' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copydownloads.sh ensembl >>& ${LOG}

date | tee -a ${LOG}
echo 'Run genemodelload copyinputs.sh ensembl' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copyinputs.sh ensembl >>& ${LOG}

date | tee -a ${LOG}
echo 'Run genemodelload copydownload.sh ensemblreg' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copydownloads.sh ensemblreg >>& ${LOG}

date | tee -a ${LOG}
echo 'Run genemodelload copyinputs.sh ensemblreg' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copyinputs.sh ensemblreg >>& ${LOG}

date | tee -a ${LOG}
echo 'Run genemodelload copydownload.sh ncbi' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copydownloads.sh ncbi >>& ${LOG}

date | tee -a ${LOG}
echo 'Run genemodelload copyinputs.sh ncbi' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copyinputs.sh ncbi >>& ${LOG}

date | tee -a ${LOG}
echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensembl

date | tee -a ${LOG}
echo 'Run Ensembl RR Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensemblreg

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

# this is being called from MGI_part2 prior to calling this script
#date | tee -a ${LOG}
#echo 'Run EntrezGene Data Provider Load' | tee -a ${LOG}
#${ENTREZGENELOAD}/loadFiles.csh >>& ${LOG}

date | tee -a ${LOG}
echo 'Run Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh >>& ${LOG}

date | tee -a ${LOG}
echo '--- finished par.csh' | tee -a ${LOG}
