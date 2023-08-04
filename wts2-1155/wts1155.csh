#!/bin/csh -f

#
# wts2-1155/fl2-394/gorat
#
# mirror_wget
#
# goload
#       gomousenoctua.py: : change from 
#
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
# lib_py_report
#       go_annot_extensions.py
#
# 1. MGI_User.login; do we remove "NOCTUA_" from "NOCTUA_xxx" users?
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
where a1.accid like ('GO_REF%') and a1._object_key = a2._refs_key
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
delete from mgi_user where login in ('NOCTUA_Alzheimers_University_of_Toronto');
delete from mgi_user where login in ('NOCTUA_ARUK-UCL');
delete from mgi_user where login in ('NOCTUA_BHF-UCL');
delete from mgi_user where login in ('NOCTUA_CACAO');
delete from mgi_user where login in ('NOCTUA_CAFA');
delete from mgi_user where login in ('NOCTUA_DFLAT');
delete from mgi_user where login in ('NOCTUA_dictyBase');
delete from mgi_user where login in ('NOCTUA_FlyBase');
delete from mgi_user where login in ('NOCTUA_GO_Central');
delete from mgi_user where login in ('NOCTUA_GOC-OWL');
delete from mgi_user where login in ('NOCTUA_HGNC');
delete from mgi_user where login in ('NOCTUA_IntAct');
delete from mgi_user where login in ('NOCTUA_NTNU_SB');
delete from mgi_user where login in ('NOCTUA_ParkinsonsUK-UCL');
delete from mgi_user where login in ('NOCTUA_PINC');
delete from mgi_user where login in ('NOCTUA_Reactome');
delete from mgi_user where login in ('NOCTUA_Roslin_Institute');
delete from mgi_user where login in ('NOCTUA_SynGO-UCL');
delete from mgi_user where login in ('NOCTUA_WormBase');
delete from mgi_user where login in ('NOCTUA_YuBioLab');
delete from mgi_user where login in ('NOCTUA_HGNC-UCL');
delete from mgi_user where login in ('NOCTUA_ComplexPortal');
delete from mgi_user where login in ('NOCTUA_DisProt');
delete from mgi_user where login in ('GOA_RHEA');

select * from mgi_user where login like 'NOCTUA_%' or login like 'GOA_%' order by login;
--update mgi_user set login = 'AgBase', name = 'AgBase' where _user_key = 1577;
--update mgi_user set login = 'SynGO', name = 'SynGO' where _user_key = 1595;
--update mgi_user set login = 'UniProt', name = 'UniProt' where _user_key = 1597;
--update mgi_user set login = 'MGI', name = 'MGI' where _user_key = 1599;
--update mgi_user set login = 'WB', name = 'WB' where _user_key = 1612;

update voc_term set term = 'go_qualifier_term', abbreviation = 'go_qualifier_term' where _term_key = 18583064;
insert into voc_term values((select nextval('voc_term_seq')), 82, 'go_qualifier_id', 'go_qualifier_id', null, 137, 0, 1001, 1001, now(), now());

EOSQL

# remove obsolete output files
rm -rf ${PUBREPORTDIR}/output/gene_association.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_nonoctua.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_nonoctua_pro.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_pro.mgi*
rm -rf ${PUBREPORTDIR}/output/mgi.gpad*
rm -rf ${PUBREPORTDIR}/output/mgi_nonoctua.gpad*

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

EOSQL

date |tee -a $LOG

