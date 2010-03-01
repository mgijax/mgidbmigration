#!/bin/csh -fx

#
# mirror and rcp files needed for dev builds
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
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
echo 'rcp uniprotmus.dat for entrezgeneload and genemodelload files from hobbiton' | tee -a ${LOG}
cd /data/seqdbs/blast/uniprot.build
rcp hobbiton:/data/seqdbs/blast/uniprot.build/uniprotmus.dat .

cd /data/loads/mgi/genemodelload/input
rcp shire:/data/loads/mgi/genemodelload/input/ensembl_assoc.txt .
rcp shire:/data/loads/mgi/genemodelload/input/ensembl_genemodels.txt .
rcp shire:/data/loads/mgi/genemodelload/input/ncbi_assoc.txt .
rcp shire:/data/loads/mgi/genemodelload/input/ncbi_genemodels.txt .
rcp shire:/data/loads/mgi/genemodelload/input/vega_assoc.txt .
rcp shire:/data/loads/mgi/genemodelload/input/vega_genemodels.txt . 

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
