#!/bin/csh -fx

#
# Build 39 Loads
# part 2b-2
#
# * 8d run problemseqsetload it may have changed since 2b-1 - this will inform mgigff3
# * 9d run mrkcoordload, this will load coordinates for whatever collections are
#    present in /data/mrkcoord/current and SHOULD INCLUDE gff3blat collection 
#    output of the mgigff3 run in 2b-1
# * 10a run some cacheloads that alomrkload needs
# * 11a run gene trap coordinate load
# * 11g run alomrkload
# * 11b run mgigff3 refresh - this will generate the gff3blat coordinate file is
#     input for strainmarkerload (run from straingenemodelload)
# * 11c/d run straingenemodelload
# * no point in running refseqload, there will be no seqs to load til the next saturday
# * 12 run mouse entrezgene load
# * 12 run uniprotload
# * 11e run molecular notes updates
# * 11f run variant coordinate updates
#
# BEFORE adding a call to a load in this script
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
# Run this in case Sophia has changed it since running part 2b-1
echo 'Run Problem Alignment Sequence Load' | tee -a ${LOG}
rm -f $DATALOADSOUTPUT/mgi/problemseqsetload/input/lastrun
${PROBLEMSEQSETLOAD}/bin/problemseqsetload.sh

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
date | tee -a ${LOG}
echo 'Run Marker/Coordinate Load' | tee -a $LOG
${MRKCOORDLOAD}/bin/mrkcoordload.sh | tee -a $LOG

# DATA: is from the database
 date | tee -a ${LOG}
 echo 'run tss gene load' | tee -a $LOG
 ${TSSGENELOAD}/bin/tssgeneload.sh | tee -a $LOG

# seqmarker.csh, seqcoord.csh, mrklocation.csh must be run before alomrkload.sh
# run alomrkload only after the genemodel and marker coordinates have been 
# updated

date | tee -a ${LOG}
echo 'Run Sequence/Marker Cache Load' | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh

date | tee -a ${LOG}
echo 'Run Sequence/Coordinate Cache Load' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh

date | tee -a ${LOG}
echo 'Run Marker/Location Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh

# DATA: is configured and is in a TR directory
date | tee -a ${LOG}
echo 'Run Gene Trap Coordinate Load' | tee -a ${LOG}
${GTCOORDLOAD}/bin/gtcoordload.sh

# DATA: is from the database
date | tee -a ${LOG}
echo 'Run ALO/Marker Load' | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

# run refresh - the new gff3 file will inform straingenemodelload
# DATA: uses database and files that it downloads
date | tee -a ${LOG}
echo 'run mgigff3 using the new gene models' | tee -a $LOG
/usr/local/mgi/live/mgigff3/bin/refresh

# DATA: is from mgigff3 file it is fetched from ${FTPROOT}/pub/mgigff3/MGIlgff3.gz
date | tee -a ${LOG}
echo 'Run Strain Gene Model Load' | tee -a ${LOG}
rm -f ${DATALOADSOUTPUT}/mgi/strainmarkerload/output/lastrun
${STRAINGENEMODELLOAD}/bin/straingenemodelload.sh

#3/15 per Richard, we won't run this now, but configure to reload all experiments
# next project when we add more data
# DATA: data is on bhmgiapp14ld and bhmgiap09lt - it needs to be downloaded
# on bhmgidevapp01 before the build.
# if we run this then set LOAD_MODE="test" to NOT check the MGI_Set - just drop and reload existing
# experiments
#date | tee -a ${LOG}
#echo 'Run RNA Sequence Load' | tee -a ${LOG}
#${RNASEQLOAD}/bin/rnaseqload.sh

# DATA: Copied from production above
date | tee -a ${LOG}
echo 'Run EntrezGene Data Provider Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Run Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

# DATA: Copied from production above
date | tee -a ${LOG}
echo 'Run UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh

# This creates noteload file by parsing the parsed notes file with new coordinates added in last two
# columns
# DATA: From file provided by Paul (he starts with output from parse_molecular_notes.csh
# 
date | tee -a ${LOG}
echo 'Run Molecular note load'| tee -a ${LOG}
${NOTELOAD}/mginoteload.csh /mgi/all/wts_projects/13300/13349/Build39/MolecularNotes/molecularnote.config

# Update the variant coordinates to B39
# DATA: From file provided by Paul ( he starts with the output of variant_coords.csh - variant_coords.rpt)
date | tee -a ${LOG}
echo 'Run Variant Coordinate  update' | tee -a ${LOG}
/mgi/all/wts_projects/13300/13349/Build39/Variants/coord_updates/update_variant_coords.csh | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 2b-2' | tee -a ${LOG}
