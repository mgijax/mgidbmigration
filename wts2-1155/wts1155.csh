#!/bin/csh -f

#
# wts2-1155/fl2-394/gorat
#
# mirror_wget : remove
#       ftp.geneontology.org.external2go
#       snapshot.geneontology.org.goload
#       snapshot.geneontology.org.goload.noctua
#
# goload
#       gomousenoctua.py:
#       from: https://snapshot.geneontology.org/products/upstream_and_raw_data/noctua_mgi.gpad.gz
#       to  : http://snapshot.geneontology.org/annotations/mgi.gpad.gz
#
# qcreports_db
#       mgf/GO_EvidenceProperty.py
#       mgf/GO_stats.py (NOCTUA_ may no longer exist)
#       mgd/GO_PM2GeneRefsNotInMGI.py
#       monthly/MRK_GOAnnot.py
#       qcr.shtml:
#               remove: QC: GOAMouse/invalid pubmedids (ln)
#               keep  : QC: GOMouseNoctua/invalid pubmedids (ln)
# reports_db
#       remove: daily/GO_gene_association.py
#
#       GOC needs to make these:
#       gene_association.mgi (GAF)
#       gene_association_pro.mgi (GAF)
#       mgi.gpad
#
#       become obsolete:
#       gene_association_nonoctua.mgi (GAF)
#       gene_association_nonoctua_pro.mgi (GAF)
#       mgi_nonoctua.gpad
#
# mgicacheload
#       inferredfrom.goahumanload : remove
#       inferredfrom.goratload    : remove
#       inferredfrom.gomousenoctua: change "NOCTUA"%" to "GO_Central"
#       inferredfrom.goaload
#       inferredfrom.gocfpload
#       inferredfrom.gorefgenload
#
# uniprotload: remove
#       makeGOAnnot.sh
#       makeGOAnnot.py
#       goecannot.config.default
#       goipannot.config.default
#       gospkwannot.config.default
#       /data/downloads/go_translation
#       /data/downloads/current.geneontology.org/ontology/external2go
#
# lib_py_report
#       go_annot_extensions.py
#
# 1. MGI_User.login; remove "NOCTUA_" from "NOCTUA_xxx" users
#       leave only GO_Central and other GOA_% 
# 2. David: review _vocab_key = 82 and remove any obsolete terms
# 3. David: change description for GO_REF references at MGI and at GO
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

-- GO_REF references
select a2.jnumid, a1.accid, a2.short_citation 
from acc_accession a1, bib_citation_cache a2 
where a1._logicaldb_key = 185
and a1.prefixpart = 'GO_REF:'
and a2._object_key = a2._refs_key
;

delete from mgi_user where login in ('dots_seqload');
delete from mgi_user where login in ('dfci_seqload');
delete from mgi_user where login in ('nia_seqload');
delete from mgi_user where login in ('mkiaa_load');
delete from mgi_user where login in ('nia_assocload');
delete from mgi_user where login in ('snp_load');
delete from mgi_user where login in ('dots_assocload');
delete from mgi_user where login in ('dfci_assocload');
delete from mgi_user where login in ('unists_nomenload');
delete from mgi_user where login in ('unists_coordload');
delete from mgi_user where login in ('mirbase_coordload');
delete from mgi_user where login in ('mirbase_load');
delete from mgi_user where login in ('qtl_coordload');
delete from mgi_user where login in ('treefam_assocload');
delete from mgi_user where login in ('gtlite_assocload');
delete from mgi_user where login in ('roopenian-sts_coordload');
delete from mgi_user where login in ('mousecyc_load');
delete from mgi_user where login in ('gbpreprocessor');
delete from mgi_user where login in ('gbgtfilter');
delete from mgi_user where login in ('mousefunc_assocload');
delete from mgi_user where login in ('gtblatpipeline');
delete from mgi_user where login in ('tr9601dna_coordload');
delete from mgi_user where login in ('tr9583micro_coordload');
delete from mgi_user where login in ('tr9873mirbase_coordload');
delete from mgi_user where login in ('tr9612_annotload');
delete from mgi_user where login in ('mtoload');
delete from mgi_user where login in ('genmapload');
delete from mgi_user where login in ('trna_coordload');
delete from mgi_user where login in ('orthology_load');
delete from mgi_user where login in ('eurogenoannot_load');
delete from mgi_user where login in ('mapviewload');
delete from mgi_user where login in ('qtlarchiveload');
delete from mgi_user where login in ('emapload');
delete from mgi_user where login in ('rvload');
delete from mgi_user where login in ('fearload');
delete from mgi_user where login in ('uniprot_override_load');
delete from mgi_user where login in ('omim_hpoload');
delete from mgi_user where login in ('human_coordload');

update voc_term set term = 'go_qualifier_term', abbreviation = 'go_qualifier_term' where _term_key = 18583064;
insert into voc_term values((select nextval('voc_term_seq')), 82, 'go_qualifier_id', 'go_qualifier_id', null, 137, 0, 1001, 1001, now(), now());

EOSQL

# delete all GO annotations
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Annot_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object | tee -a $LOG
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from voc_annot where _annottype_key = 1000;
EOSQL
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Annot_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a $LOG

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
rm -rf go_translation
rm -rf go_noctua
ln -s go_noctua snapshot.geneontology.org/annotations
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot

rm -rf ${DATALOADSOUTPUT}/go/*/input/*
rm -rf ${DATALOADSOUTPUT}/uniprot/uniprotload/output/*
rm -rf ${DATALOADSOUTPUT}/uniprot/uniprotload/logs/*

#${GOLOAD}/go.sh | tee -a $LOG
${UNIPROTLOAD}/bin/uniprotload.sh | tee -a $LOG

# remove obsolete output files
rm -rf ${PUBREPORTDIR}/output/gene_association.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_nonoctua.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_nonoctua_pro.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_pro.mgi*
rm -rf ${PUBREPORTDIR}/output/mgi.gpad*
rm -rf ${PUBREPORTDIR}/output/mgi_nonoctua.gpad*

# this report is obsolete
#cd ${PUBRPTS}
#source ./Configuration
#cd daily
#${PYTHON} GO_gene_association.py | tee -a $LOG

cd ${QCRPTS}
source ./Configuration
cd mgd
${PYTHON} GO_EvidenceProperty.py
${PYTHON} GO_stats.py

#
# David:  review _vocab_key = 82 and remove any obsolete terms
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- property terms that are no longer used; can be deleted from voc_term
select v.*
from VOC_Term v
where v._vocab_key = 82
and not exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p 
where a._annottype_key = 1000 
and a._annot_key = e._annot_key
and e._annotevidence_key = p._annotevidence_key
and p._propertyterm_key = v._term_key
)
order by t.term
;

-- property terms that are used
select v.*
from VOC_Term v
where v._vocab_key = 82
and exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p 
where a._annottype_key = 1000 
and a._annot_key = e._annot_key
and e._annotevidence_key = p._annotevidence_key
and p._propertyterm_key = v._term_key
)
order by t.term
;

-- remove NOCTUA_ and GOA_ users; only GO_Central should be left
select * from mgi_user where login like 'NOCTUA_%' or login like 'GOA_%' order by login;
delete from mgi_user where login like 'NOCTUA_%';
--keep; still used by other go loads
--delete from mgi_user where login like 'GOA_%';
select * from mgi_user where login like 'NOCTUA_%' or login like 'GOA_%' order by login;

EOSQL

date |tee -a $LOG

