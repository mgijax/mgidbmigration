#!/bin/csh -f

#
# wts2-1155/fl2-394/gorat
#
# mirror_wget
# goload
# qcreports_db
#       GO_EvidenceProperty.py, GO_stats.py (NOCTUA_ may no longer exist)
# reports_db
#       daily/GO_gene_association.py
# lib_py_report
#       go_annot_extensions.py
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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from mgi_user where login in (
'dots_seqload',
'dfci_seqload',
'nia_seqload',
'mkiaa_load',
'nia_assocload',
'snp_load',
'dots_assocload',
'dfci_assocload',
'unists_nomenload',
'unists_coordload',
'mirbase_coordload',
'mirbase_load',
'qtl_coordload',
'treefam_assocload',
'gtlite_assocload',
'roopenian-sts_coordload',
'mousecyc_load',
'gbpreprocessor',
'gbgtfilter',
'mousefunc_assocload',
'gtblatpipeline',
'tr9601dna_coordload',
'tr9583micro_coordload',
'tr9873mirbase_coordload',
'tr9612_annotload',
'mtoload',
'genmapload',
'trna_coordload',
'orthology_load',
'eurogenoannot_load',
'mapviewload',
'qtlarchiveload',
'emapload',
'rvload',
'fearload',
'uniprot_override_load',
'omim_hpoload',
'human_coordload',
'NOCTUA_Alzheimers_University_of_Toronto',
'NOCTUA_ARUK-UCL',
'NOCTUA_BHF-UCL',
'NOCTUA_CACAO',
'NOCTUA_CAFA',
'NOCTUA_DFLAT',
'NOCTUA_dictyBase',
'NOCTUA_FlyBase',
'NOCTUA_GO_Central',
'NOCTUA_GOC-OWL',
'NOCTUA_HGNC',
'NOCTUA_IntAct',
'NOCTUA_NTNU_SB',
'NOCTUA_ParkinsonsUK-UCL',
'NOCTUA_PINC',
'NOCTUA_Reactome',
'NOCTUA_Roslin_Institute',
'NOCTUA_SynGO-UCL',
'NOCTUA_WormBase',
'NOCTUA_YuBioLab',
'NOCTUA_HGNC-UCL',
'GOA_RHEA',
'NOCTUA_ComplexPortal',
'NOCTUA_DisProt'
)
;

update voc_term set term = 'go_qualifier_term', abbreviation = 'go_qualifier_term' where _term_key = 18583064;
insert into voc_term values((select nextval('voc_term_seq')), 82, 'go_qualifier_id', 'go_qualifier_id', null, 137, 0, 1001, 1001, now(), now());

EOSQL

#
#
# mirror_wget
# remove: ftp.geneontology.org.goload
# remove: snapshot.geneontology.org.goload.noctua
# add   : snapshot.geneontology.org.goload.annotations
# add to packagelist.daily:  snapshot.geneontology.org.goload.annotations
#

${MIRROR_WGET}/download_package purl.obolibrary.org.pr
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload
${MIRROR_WGET}/download_package ftp.geneontology.org.goload
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.annotations

cd /data/downloads
rm -rf current.geneontology.org
rm -rf snapshot.geneontology.org/products
rm -rf go_noctua
ln -s go_noctua snapshot.geneontology.org/annotations

rm -rf ${DATALOADSOUTPUT}/go/*/input/*

${GOLOAD}/go.sh | tee -a $LOG

cd ${PUBRPTS}
source ./Configuration
cd daily
${PYTHON} GO_gene_association.py | tee -a $LOG

cd ${QCRPTS}
source ./Configuration
cd mgd
${PYTHON} GO_EvidenceProperty.py
${PYTHON} GO_stats.py

date |tee -a $LOG

