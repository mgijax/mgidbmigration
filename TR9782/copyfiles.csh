#!/bin/csh -fx

#
# mirror and rcp files needed for dev builds
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
# Mirrors	
#

date | tee -a ${LOG}
echo 'Mirroring entrezgeneload/egload files' | tee -a ${LOG}
${MIRROR_FTP}/runmirror ftp.ncbi.nih.gov2 ftp.ncbi.nih.gov2.log

date | tee -a ${LOG}
echo 'Mirroring proload file' | tee -a ${LOG}
${MIRROR_FTP}/runmirror ftp.pir.georgetown.edu ftp.pir.georgetown.edu.log

date | tee -a ${LOG}
echo 'Mirroring Ensembl vega_ensemblseqload files' | tee -a ${LOG}
${MIRROR_FTP}/runmirror ftp.ensembl.org ftp.ensembl.org.log

date | tee -a ${LOG}
echo 'Mirroring VEGA vega_ensemblseqload files' | tee -a ${LOG}
${MIRROR_FTP}/runmirror ftp.sanger.ac.uk ftp.sanger.ac.uk.log

#
# rcp files
#
date | tee -a ${LOG}
echo 'rcp uniprotmus.dat for entrezgeneload and genemodelload files from shire' | tee -a ${LOG}
cd /data/seqdbs/blast/uniprot.build
rcp hobbiton:/data/seqdbs/blast/uniprot.build/uniprotmus.dat .

echo 'rcp  genemodelload files from shire' | tee -a ${LOG}
cd /data/loads/mgi/genemodelload/input
rcp shire:/data/loads/mgi/genemodelload/input/ensembl_assoc.txt .
rcp shire:/data/loads/mgi/genemodelload/input/ensembl_genemodels.txt .
rcp shire:/data/loads/mgi/genemodelload/input/ncbi_assoc.txt .
rcp shire:/data/loads/mgi/genemodelload/input/ncbi_genemodels.txt .
rcp shire:/data/loads/mgi/genemodelload/input/vega_assoc.txt .
rcp shire:/data/loads/mgi/genemodelload/input/vega_genemodels.txt . 


rcp shire:/data/downloads/ensembl_mus_gtf/Mus_musculus.NCBIM37.56.gtf.gz ./ensembl_biotypes.gz
rcp shire:/data/downloads/ensembl_mus_cdna/Mus_musculus.NCBIM37.56.cdna.all.fa.gz ./ensembl_transcripts.gz
rcp shire:/data/downloads/ensembl_mus_protein/Mus_musculus.NCBIM37.56.pep.all.fa.gz ./ensembl_proteins.gz 
rcp shire:/data/downloads/vega_mus_gtf/gtf_file.gz ./vega_biotypes.gz 
rcp shire:/data/downloads/vega_mus_cdna/Mus_musculus.VEGA37.37.cdna.all.fa.gz ./vega_transcripts.gz
rcp shire:/data/downloads/vega_mus_protein/Mus_musculus.VEGA37.37.pep.all.fa.gz ./vega_proteins.gz 
rcp shire:/data/downloads/entrezgene/gene_info.gz ./ncbi_biotypes.gz

# file for GeneTrap RNA gbrowseutils report
cd /data/downloads/ftp.ncbi.nih.gov/gtblatpipeline/output
rcp shire:/data/downloads/ftp.ncbi.nih.gov/gtblatpipeline/output/best_blat_hits_single_Gbrowse.master.gff .

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
