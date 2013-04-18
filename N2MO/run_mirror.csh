#!/bin/csh -f

#
# This script should be run prior to the migration to download all the latest
# input files that are needed by the loads.
#

cd `dirname $0` && source ../Configuration

setenv LOG `pwd`/$0.log.$$
rm -rf ${LOG}
touch ${LOG}

cd ${MIRROR_FTP}

#
# Run ftp.ncbi.nih.gov2 mirror. This includes:
#    package NCBI_GENE (for entrezgeneload)
#    package HOMOLOGENE (for entrezgeneload and homologyload)
#    package MAPVIEW (for mapviewload)
#
date | tee -a ${LOG}
echo 'Run ftp.ncbi.nih.gov2 mirror' | tee -a ${LOG}
./runmirror ftp.ncbi.nih.gov2 ftp.ncbi.nih.gov2.log

#
# Run grcf.jhmi.edu mirror. This includes:
#    package OMIM (for entrezgeneload)
#
date | tee -a ${LOG}
echo 'Run grcf.jhmi.edu mirror' | tee -a ${LOG}
./runmirror grcf.jhmi.edu grcf.jhmi.edu.log

#
# Run ftp.nextprot.org mirror. This includes:
#    package NEXTPROT (for nextprotload)
#
date | tee -a ${LOG}
echo 'Run ftp.nextprot.org mirror' | tee -a ${LOG}
./runmirror ftp.nextprot.org ftp.nextprot.org.log

#
# Run ftp.geneontology.org mirror. This includes:
#    package GO_ANNOTATIONS (for goahumanload and goratload)
#
date | tee -a ${LOG}
echo 'Run ftp.geneontology.org mirror' | tee -a ${LOG}
./runmirror ftp.geneontology.org ftp.geneontology.org.log

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
