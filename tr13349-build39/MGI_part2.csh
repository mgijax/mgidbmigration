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
        breaksw
endsw

date | tee -a ${LOG}
echo 'Run Problem Alignment Sequence Load' | tee -a ${LOG}
rm -f $DATALOADSOUTPUT/mgi/problemseqsetload/input/lastrun
${PROBLEMSEQSETLOAD}/bin/problemseqsetload.sh

# commented out loads below are awaiting Ensembl and NCBI Gene models and the mgigff file. Once they are ready
# we can uncommment these loads
#date | tee -a ${LOG}
#echo 'Run MCV Vocabulary Load' | tee -a ${LOG}
#${MCVLOAD}/bin/run_mcv_vocload.sh

# DATA: Sophia will publish file
#date | tee -a ${LOG}
#echo 'Run MCV Annotation Load' | tee -a ${LOG}
#${MCVLOAD}/bin/mcvload.sh

# DATA: Sophia will test then publish files for GMs and associations
#date | tee -a ${LOG}
#echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
#${GENEMODELLOAD}/bin/genemodelload.sh ensembl

#date | tee -a ${LOG}
#echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
#${GENEMODELLOAD}/bin/genemodelload.sh ncbi

# DATA: curators will prepare and publish files. script to catenate files into one
# file and QC as a whole 11/4 to be done. Part of migration or part of mrkcoordload?

date | tee -a ${LOG}
echo 'Run Marker/Coordinate Load Prep' | tee -a $LOG
./mrkcoordload_prep.sh
set STAT=$?
echo "STAT: $STAT"

if ( $STAT == 1 ) then
    echo "mrkcoordload_prep.sh failed"
    exit 1
endif

date | tee -a ${LOG}
echo 'Run Marker/Coordinate Load' | tee -a $LOG
${MRKCOORDLOAD}/bin/mrkcoordload.sh | tee -a $LOG

# DATA: is from the database
date | tee -a ${LOG}
echo 'run tss gene load' | tee -a $LOG
${TSSGENELOAD}/bin/tssgeneload.sh | tee -a $LOG

# DATA: is configured and is in a TR directory
#date | tee -a ${LOG}
#echo 'Run Gene Trap Coordinate Load' | tee -a ${LOG}
#${GTCOORDLOAD}/bin/gtcoordload.sh

# seqcoord.csh, mrklocation.csh must be run before alomrkload.sh
# run alomrkload only after the genemodel and marker coordinates have been 
# updated

#date | tee -a ${LOG}
#echo 'Run Sequence/Coordinate Cache Load' | tee -a ${LOG}
#${SEQCACHELOAD}/seqcoord.csh

#date | tee -a ${LOG}
#echo 'Run Marker/Location Cache Load' | tee -a ${LOG}
#${MRKCACHELOAD}/mrklocation.csh

# DATA: is from the database
#date | tee -a ${LOG}
#echo 'Run ALO/Marker Load' | tee -a ${LOG}
#${ALOMRKLOAD}/bin/alomrkload.sh

# DATA: is from mgigff3 file it is fetched from ${FTPROOT}/pub/mgigff3/MGIlgff3.gz
#date | tee -a ${LOG}
#echo 'Run Strain Gene Model Load' | tee -a ${LOG}
#${STRAINGENEMODELLOAD}/bin/straingenemodelload.sh

# DATA: data is on bhmgiapp14ld and bhmgiap09lt - it needs to be downloaded
# on bhmgidevapp01 before the build.
# load is configured to NOT check the MGI_Set - just drop and reload existing
# experiments
#date | tee -a ${LOG}
#echo 'Run RNA Sequence Load' | tee -a ${LOG}
#${RNASEQLOAD}/bin/rnaseqload.sh

# DATA: Copied from production above
#date | tee -a ${LOG}
#echo 'Run EntrezGene Data Provider Load' | tee -a ${LOG}
#${ENTREZGENELOAD}/loadFiles.csh

#date | tee -a ${LOG}
#echo 'Run Mouse EntrezGene Load' | tee -a ${LOG}
#${EGLOAD}/bin/egload.sh

# DATA: Copied from production above
#date | tee -a ${LOG}
#echo 'Run UniProt Load' | tee -a ${LOG}
#${UNIPROTLOAD}/bin/uniprotload.sh

# This recreates the location notes that were deleted in part 1
# DATA: From TR directory
#date | tee -a ${LOG}
#echo 'Run Location Note Load in incremental mode'| tee -a ${LOG}
#${NOTELOAD}/mginoteload.csh /mgi/all/wts_projects/13300/13349/Build39/LocationNotes/location.config

# This creates noteload file by parsing the parsed notes file with new coordinates added in last two
# columns
# DATA: From file provided by Paul (he starts with output from parse_molecular_notes.csh
# 
date | tee -a ${LOG}
echo 'Run Molecular note load'| tee -a ${LOG}
${NOTELOAD}/mginotload.csh /mgi/all/wts_projects/13300/13349/Build39/MolecularNotes/molecularnote.config

#date | tee -a ${LOG}
#echo 'autosequence check' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/test/autosequencecheck.csh | tee -a $LOG 

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
