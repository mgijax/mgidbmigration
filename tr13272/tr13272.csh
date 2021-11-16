#!/bin/csh -f

#
# tags needed:
#
# reports_db
# goload
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
 
cd ${PUBRPTS}
source ./Configuration
cd daily
$PYTHON GO_gpi.py | tee -a $LOG

# run goload

${MIRROR_WGET}/download_package purl.obolibrary.org.pr | tee -a $LOG
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo | tee -a $LOG
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG
${MIRROR_WGET}/download_package ftp.geneontology.org.goload | tee -a $LOG
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload | tee -a $LOG
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_Property_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select _annot_key into temp toDelete from voc_annot where _annottype_key = 1000;

delete from mgi_note using toDelete, voc_evidence, voc_evidence_property
where toDelete._annot_key = voc_evidence._annot_key 
and voc_evidence._annotevidence_key = voc_evidence_property._annotevidence_key
and voc_evidence_property._evidenceproperty_key = mgi_note._object_key 
and mgi_note._mgitype_key = 41;

delete from voc_evidence_property using toDelete, voc_evidence 
where toDelete._annot_key = voc_evidence._annot_key and voc_evidence._annotevidence_key = voc_evidence_property._annotevidence_key;

delete from voc_evidence using toDelete where toDelete._annot_key = voc_evidence._annot_key;

delete from acc_accession from toDelete where toDelete._annot_key = acc_accession._object_key and acc_accession._mgitype_key = 25;

delete from voc_annot where _annottype_key = 1000;

EOSQL

${GOLOAD}/go.sh | tee -a $LOG

${UNIPROTLoAD}/bin/uniprotload.sh | tee -a $LOG

cd ${PUBRPTS}
source ./Configuration
cd daily
$PYTHON GO_gene_association.py | tee -a $LOG
cd ../weekly
$PYTHON GO_gene_association_nonmouse.py | tee -a $LOG

cd ${QCRPTS}
source ./Configuration
cd weekly
$PYTHON GO_stats.py

date |tee -a $LOG
