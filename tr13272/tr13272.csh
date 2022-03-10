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
${MIRROR_WGET}/download_package raw.githubusercontent.com.evidenceontology | tee -a $LOG
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot

# obsolete output file
rm -rf ${DATALOADSOUTPUT}/go/gomousenoctua/output/pubmed.error
rm -rf ${DATALOADSOUTPUT}/go/lastrun

# start: truncate all GO Annotations
date | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_Property_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0  | tee -a $LOG
select _annot_key into temp toDelete from voc_annot where _annottype_key = 1000;
create index idxtodelete on toDelete(_annot_key);

delete from mgi_note using toDelete, voc_evidence, voc_evidence_property
where toDelete._annot_key = voc_evidence._annot_key 
and voc_evidence._annotevidence_key = voc_evidence_property._annotevidence_key
and voc_evidence_property._evidenceproperty_key = mgi_note._object_key 
and mgi_note._mgitype_key = 41;

delete from voc_evidence_property using toDelete, voc_evidence 
where toDelete._annot_key = voc_evidence._annot_key and voc_evidence._annotevidence_key = voc_evidence_property._annotevidence_key;

delete from voc_evidence using toDelete where toDelete._annot_key = voc_evidence._annot_key;

delete from voc_annot where _annottype_key = 1000;

DROP FUNCTION IF EXISTS VOC_deleteGOGAFRed(text);
DROP TRIGGER IF EXISTS PRB_Source_insert_trigger ON PRB_Source;
DROP FUNCTION IF EXISTS PRB_Source_insert();

EOSQL

${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_Property_create.object  | tee -a $LOG

# end: truncate all GO Annotations

date | tee -a $LOG
${GOLOAD}/go.sh | tee -a $LOG

date | tee -a $LOG
${UNIPROTLOAD}/bin/uniprotload.sh | tee -a $LOG

date | tee -a $LOG
cd ${PUBRPTS}
source ./Configuration
cd daily
$PYTHON GO_gene_association.py | tee -a $LOG

cd ${QCRPTS}
source ./Configuration
cd weekly
$PYTHON GO_stats.py

#ssh bhmgiapp01
#cd /export/gondor/ftp/pub/custom/noctua
#scp bhmgiapp14ld:/data/reports/lec/reports_db/output/gene_association.mgi .
#scp bhmgiapp14ld:/data/reports/lec/reports_db/output/gene_association_nonoctua.mgi .
#scp bhmgiapp14ld:/data/reports/lec/reports_db/output/gene_association_pro.mgi .
#scp bhmgiapp14ld:/data/reports/lec/reports_db/output/mgi.gpad .
#scp bhmgiapp14ld:/data/reports/lec/reports_db/output/mgi.gpi .
#scp bhmgiapp14ld:/data/reports/lec/reports_db/output/mgi_nonoctua.gpad .

date |tee -a $LOG
