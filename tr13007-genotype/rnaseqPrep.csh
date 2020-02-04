#!/bin/csh -fx

#
# rnaseqPrep.csh
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
echo '--- starting rnaseqPrep.csh' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'Create HT Experiment Sets' | tee -a $LOG
./createSets.csh  | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'Download Experiment Files' | tee -a $LOG
${RNASEQLOAD}/bin/run_downloadFiles.sh  | tee -a $LOG || exit 1

#
# copy 'old' rnaseq files that have not been updated at the source in the new
# pipeline run
#
date | tee -a ${LOG}
echo 'Copy old Experiment Files' | tee -a $LOG

switch (`uname -n`)
    case bhmgiapp14ld:
    case bhmgidevapp01:
    case bhmgiapp01:
    case bhmgiap09lt.jax.org:
        date | tee -a ${LOG}
        echo 'copying old rna-seq files' | tee -a $LOG || exit 1
	scp /mgi/all/wts_projects/13000/13007/data/old_exp_toload/E-GEOD-43721.eae.txt /data/loads/mgi/rnaseqload/raw_input/E-GEOD-43721.eae.txt
        scp /mgi/all/wts_projects/13000/13007/data/old_exp_toload/E-GEOD-43717.eae.txt /data/loads/mgi/rnaseqload/raw_input/E-GEOD-43717.eae.txt
        scp /mgi/all/wts_projects/13000/13007/data/old_exp_toload/E-MTAB-3725.eae.txt /data/loads/mgi/rnaseqload/raw_input/E-MTAB-3725.eae.txt
        scp /mgi/all/wts_projects/13000/13007/data/old_exp_toload/E-MTAB-3718.eae.txt /data/loads/mgi/rnaseqload/raw_input/E-MTAB-3718.eae.txt
        scp /mgi/all/wts_projects/13000/13007/data/old_exp_toload/E-ERAD-499.eae.txt /data/loads/mgi/rnaseqload/raw_input/E-ERAD-499.eae.txt
	
        breaksw
endsw

# we are copying old files because the download_files script cannot download them
# so will not create this flag. We need to create the download_ok file
date | tee -a ${LOG}
echo 'Create the download_ok file in the raw_input directory' | tee -a $LOG

touch /data/loads/mgi/rnaseqload/raw_input/download_ok

date | tee -a ${LOG}
echo '--- finished rnaseqPrep.csh' | tee -a ${LOG}
