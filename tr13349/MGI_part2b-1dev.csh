#!/bin/csh -fx

# Build 39 Loads
# part 2b-1
#
# * copy input files for this and all other 2b parts
# * Run ensembl and ncbi genemodelload using Sophia's B39* files
# ** associations
# ** gene models
# * run mrkcoordload, this will load coordinates for whatever collections are
# *    present in /data/mrkcoord/current
# * run tssgenelod since tss genes have been available since last fall they will be 
#     loaded by the mrkcoordload step 
# * run mgigff3blat - this will generate the gff3blat coordinate file that Sophia may edit
#    then put in the current directory
#
#
# BEFORE adding a call to a load in this script:
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
echo '--- starting part 2b' | tee -a $LOG

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
        scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2accession.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA/
        scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2pubmed.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA/
        scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2refseq.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA/
        scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_info.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA/
        scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_history.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA/
        scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen /data/downloads/ftp.ncbi.nih.gov/gene/DATA/
        scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current/homologene.data /data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current/
        scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot/uniprotmus.dat
        scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/interpro/names.dat /data/downloads/ftp.ebi.ac.uk/pub/databases/interpro/
        scp bhmgiapp01:/data/downloads/go_translation/ec2go /data/downloads/go_translation/ec2go
        scp bhmgiapp01:/data/downloads/go_translation/interpro2go /data/downloads/go_translation/interpro2go
        scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_kw2go /data/downloads/go_translation/uniprotkb_kw2go
        scp bhmgidevapp01:/data/reports/reports_db/output/mgi.gpi /data/reports/reports_db/output/mgi.gpi
        cp -p /mgi/all/wts_projects/13300/13349/Build39/GeneTraps/gtblatpipeline_files/best_blat_hits_single_Gbrowse.gff /data/downloads/ftp.ncbi.nih.gov/gtblatpipeline/output
        breaksw
endsw

date | tee -a ${LOG}
echo 'Run Problem Alignment Sequence Load' | tee -a ${LOG}
rm -f $DATALOADSOUTPUT/mgi/problemseqsetload/input/lastrun
${PROBLEMSEQSETLOAD}/bin/problemseqsetload.sh

# Sophia says she will not add any MCV til after production release
# leaving these in and commented out in case she changes her mind. 
#date | tee -a ${LOG}
#echo 'Run MCV Vocabulary Load' | tee -a ${LOG}
#${MCVLOAD}/bin/run_mcv_vocload.sh

# DATA: Sophia will publish file
#date | tee -a ${LOG}
#echo 'Run MCV Annotation Load' | tee -a ${LOG}
#${MCVLOAD}/bin/mcvload.sh


# DATA: Sophia will test  on test server then we run:
date | tee -a ${LOG}
echo 'Copying  ensembl input files from production /data/downloads to local /data/downloads' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copydownloads.sh ensembl

date | tee -a ${LOG}
echo 'Copying  ensembl input files from local /data/downloads to local input directories ' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copyinputs.sh ensembl

date | tee -a ${LOG}
echo 'Copying  ncbi input files from production /data/downloads to local /data/downloads' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copydownloads.sh ncbi

date | tee -a ${LOG}
echo 'Copying  ncbi input files from local /data/downloads to local input directories ' | tee -a ${LOG}
${GENEMODELLOAD}/bin/copyinputs.sh ncbi 

date | tee -a ${LOG}
echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
rm -f $DATALOADSOUTPUT/mgi/genemodelload/input/Ensembl.lastrun
${GENEMODELLOAD}/bin/genemodelload.sh ensembl

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
rm -f $DATALOADSOUTPUT/mgi/genemodelload/input/NCBI.lastrun
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run Caches' | tee -a ${LOG}
${GENEMODELLOAD}/bin/runGeneModelCache.sh

# Sophia must verify and put gff3blat file in /data/mrkcoord/current
#
# DATA: curators will prepare and publish files. script to catenate files into
# one file and QC as a whole then publish if QC successful
date | tee -a ${LOG}
echo 'Run Marker/Coordinate Load Prep' | tee -a $LOG
./mrkcoordload_prep.sh
set STAT=$?
echo "STAT: $STAT"

if ( $STAT == 1 ) then
    echo "mrkcoordload_prep.sh failed"
    exit 1
endif

# DATA: run on data catenated, qc'd and published from above mrkcoordload_prep.sh
# the data here will be anything that Paul is working on (not gff3blat it comes later)
date | tee -a ${LOG}
echo 'Run Marker/Coordinate Load' | tee -a $LOG
${MRKCOORDLOAD}/bin/mrkcoordload.sh | tee -a $LOG

# DATA: is from the database
date | tee -a ${LOG}
echo 'run tss gene load' | tee -a $LOG
${TSSGENELOAD}/bin/tssgeneload.sh | tee -a $LOG

# DATA: uses database and files that it downloads
date | tee -a ${LOG}
echo 'run mgigff3 using the new gene models' | tee -a $LOG
/usr/local/mgi/live/mgigff3/bin/refresh

date | tee -a ${LOG}
echo '--- finished part 2b-1' | tee -a ${LOG}
