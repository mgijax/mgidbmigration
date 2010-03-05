#!/bin/csh -fx

#
# rcp files needed for production release
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration

# start a new log file for this migration, and add a datestamp
setenv LOG `pwd`/`basename $0`.log.$$
rm -rf ${LOG}
touch ${LOG}

#
# rcp files
#
date | tee -a ${LOG}

echo 'rcp  genemodelload files from /data/downloads to /hobbiton/data/genemodels/current/*' | tee -a ${LOG}

# biotypes
cd /hobbiton/data/genemodels/current/biotypes
cp -p /data/downloads/ensembl_mus_gtf/Mus_musculus.NCBIM37.56.gtf.gz .
cp -p /data/downloads/vega_mus_gtf/gtf_file.gz .
cp -p /data/downloads/entrezgene/gene_info.gz .

# transcripts
cd  /hobbiton/data/genemodels/current/transcripts
cp -p /data/downloads/ensembl_mus_cdna/Mus_musculus.NCBIM37.56.cdna.all.fa.gz .
cp -p /data/downloads/vega_mus_cdna/Mus_musculus.VEGA37.37.cdna.all.fa.gz .

# proteins
cd /hobbiton/data/genemodels/current/proteins
cp -p /data/downloads/ensembl_mus_protein/Mus_musculus.NCBIM37.56.pep.all.fa.gz .
cp -p /data/downloads/vega_mus_protein/Mus_musculus.VEGA37.37.pep.all.fa.gz .

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
