#!/bin/csh -f

#
# tags needed:
#
# reports_db
# goload
# annotload
# lib_py_report
#
# delete *all* GO Annotations
# run goload
# run uniprotload
# generate reports
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
# save copy of....go_cam files
scp bhmgiapp01:/export/gondor/ftp/pub/custom/go_cam_gene_association.mgi .
scp bhmgiapp01:/export/gondor/ftp/pub/custom/go_cam_gene_association_pro.mgi .
scp bhmgiapp01:/export/gondor/ftp/pub/custom/go_cam_mgi.gpad .

# run goload

${MIRROR_WGET}/download_package purl.obolibrary.org.pr | tee -a $LOG
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo | tee -a $LOG
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG
${MIRROR_WGET}/download_package ftp.geneontology.org.goload | tee -a $LOG
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload | tee -a $LOG
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua | tee -a $LOG
scp bhmgiapp01:/data/loads/uniprot/uniprotload/output/go_ec_annot.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/output
scp bhmgiapp01:/data/loads/uniprot/uniprotload/output/go_ip_annot.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/output
scp bhmgiapp01:/data/loads/uniprot/uniprotload/output/go_spkw_annot.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/output
scp bhmgiapp01:/data/loads/uniprot/uniprotload/output/marker_ip_annot.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/output
scp bhmgiapp01:/data/loads/uniprot/uniprotload/output/mgi_uniprot_load.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/output
scp bhmgiapp01:/data/loads/uniprot/uniprotload/output/mgi_acc_assoc.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/output
scp bhmgiapp01:/data/loads/uniprot/uniprotload/output/uniprot_acc_assoc.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/output

${GOLOAD}/gopreprocess.sh | tee -a $LOG
${GOLOAD}/go.sh | tee -a $LOG
${UNIPROTLOAD}/bin/makeGOAnnot.sh | tee -a $LOG
${UNIPROTLOAD}/bin/makeInterProAnnot.sh | tee -a $LOG
${MGICACHELOAD}/bin/inferredfrom.csh | tee -a $LOG

cd ${PUBRPTS}
source ./Configuration
cd daily
$PYTHON GO_gene_association.py | tee -a $LOG

cd ${QCRPTS}
source ./Configuration
cd weekly
$PYTHON GO_stats.py

date |tee -a $LOG
