#!/bin/csh -f

#
# wts2-1155/fl2-394/GOC taking over GOA mouse, GOA human, etc.
#
# sierra : driver area to pick up gpad:
#       http://skyhook.berkeleybop.org/full-issue-325-gopreprocess/annotations/?C=N;O=A
#
# fl2-394/loadadmin:
#       dailytasks.csh:${GOLOAD}/godaily.sh -> ${GOLOAD}/bin/go.sh
#       sundaytasks.csh:${GOLOAD}/go.sh -> ${GOLOAD}/bin/go.sh
#
#       new:  ${GOLOAD}/bin/goload.sh
#
# fl2-394/mirror_wget : remove
#       see mirror_wget/HISTORY
#
# fl2-394/pgmgddbschema : trunk ; remove
#       VOC_deleteGOWithdrawn_create.object
#       VOC_deleteGOWithdrawn_drop.object
#
# fl2-394/vocload : trunk
# fl2-394/goload : wts1155 branch
#       from: https://snapshot.geneontology.org/products/upstream_and_raw_data/noctua_mgi.gpad.gz
#       to  : ??
#
#       proteincomplex.sh : remove
#
# fl2-394/annotload : wts1155 branch
# fl2-394/lib_py_dataload
# fl2-394/lib_py_age : moved to lib_py_dataload; retire
#       changing isGOmouseNoctua -> isGO
#       isGOAmouse : remove
#       isGOAhuman : remove
#       isGOrat    : remove
#       remove this logic: delete any go-annotations that are using withdrawn markers
#       mv lib_py_dataload/vocabloadlib.py -> annotload/lib
#       mv lib_py_age/agelib.py -> lib_py_dataload
#
# fl2-394/mgicacheload : wts1155
#       inferredfrom.goahumanload : remove
#       inferredfrom.goratload    : remove
#       inferredfrom.goaload      : remove
#       inferredfrom.gocfpload    : remove
#       inferredfrom.gorefgenload : remove
#       inferredfrom.gomousenoctua -> inferredfrom.py && change "NOCTUA"%" to "GO_%"
#
#       moved to goload:
#               inferredfrom.sh
#               inferredfrom.py
#               go_annot_extensions_display_load.csh
#               go_annot_extensions_display_load.py
#               go_isoforms_display_load.csh
#               go_isoforms_display_load.py
#
# fl2-394/lib_py_report
#       go_annot_extensions.py
#
# fl2-492/uniprotload: wts1155 branch, remove
#       makeGOAnnot.sh
#       makeGOAnnot.py
#       goecannot.config.default
#       goipannot.config.default
#       gospkwannot.config.default
#       /data/downloads/go_translation
#       /data/downloads/current.geneontology.org/ontology/external2go
#
# fl2-644/qcreports_db
#       see https://mgi-jira.atlassian.net/browse/FL2-644
#
# fl2-645/reports_db
#       see https://mgi-jira.atlassian.net/browse/FL2-645
#
# 1. Li: review _vocab_key = 82 and remove any obsolete terms
# 2. goload.error : Reactome references are not in MGI
#       when we process the GOA/Mouse, we save all of the Reactome rows 
#       (for which we do not have the reference in MGI) to a goamouse.gaf file. 
#       Then we append the goamouse.gaf to the end of our mgi/gaf.
#       Since MGI will no longer be generating the MGI/GAF (GO will), we need another solution
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

date
 
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 

-- GO_REF references

select a1._accession_key, a2.jnumid, a1.accid, a1.prefixpart, a1.numericpart, a2.short_citation
from acc_accession a1, bib_citation_cache a2
where a1._logicaldb_key = 185
and a1.accid like 'GO_REF:%'
and a1._object_key = a2._refs_key
order by a1.accid
;

--delete from mgi_user where login in ('emapload');
--delete from mgi_user where login in ('fearload');
--delete from mgi_user where login in ('gbpreprocessor');
--delete from mgi_user where login in ('gtblatpipeline');
--delete from mgi_user where login in ('omim_hpoload');
--delete from mgi_user where login in ('rvload');
--delete from mgi_user where login in ('uniprot_override_load');
--delete from mgi_user where login in ('hgnc_homologyload');
--delete from mgi_user where login in ('homologeneload');
--delete from mgi_user where login in ('hybrid_homologyload');
--delete from mgi_user where login in ('qtlarchiveload');

delete from mgi_user where login in ('gbgtfilter');
delete from mgi_user where login in ('dots_assocload');
delete from mgi_user where login in ('mapviewload');
delete from mgi_user where login in ('mousecyc_load');
delete from mgi_user where login in ('mousefunc_assocload');
delete from mgi_user where login in ('nia_assocload');
delete from mgi_user where login in ('dfci_assocload');

delete from mgi_user where login in ('dfci_seqload');
delete from mgi_user where login in ('dots_seqload');
delete from mgi_user where login in ('eurogenoannot_load');
delete from mgi_user where login in ('genmapload');
delete from mgi_user where login in ('gtlite_assocload');
delete from mgi_user where login in ('mirbase_coordload');
delete from mgi_user where login in ('mirbase_load');
delete from mgi_user where login in ('mkiaa_load');
delete from mgi_user where login in ('mtoload');
delete from mgi_user where login in ('nia_seqload');
delete from mgi_user where login in ('orthology_load');
delete from mgi_user where login in ('qtl_coordload');
delete from mgi_user where login in ('roopenian-sts_coordload');
delete from mgi_user where login in ('scrum-dog');
delete from mgi_user where login in ('snp_load');
delete from mgi_user where login in ('tr9601dna_coordload');
delete from mgi_user where login in ('tr9583micro_coordload');
delete from mgi_user where login in ('tr9873mirbase_coordload');
delete from mgi_user where login in ('tr9612_annotload');
delete from mgi_user where login in ('trna_coordload');
delete from mgi_user where login in ('treefam_assocload');
delete from mgi_user where login in ('unists_nomenload');
delete from mgi_user where login in ('unists_coordload');
delete from mgi_user where login in ('mapview_coordload');
delete from mgi_user where login in ('ps');
delete from mgi_user where login in ('smc');

-- set users to Inactive
update mgi_user set _userstatus_key = 316351
where login in ('adiehl','benjal','bobs','cml','dbl','dbradt','deg','drj','dlb','hdene','hdt','hjd','il','jbd','jbubier','jchu','jte','ksf','ljm','llw2','lmc', 'mac', 'rbabiuk', 'tbreddy', 'tmeehan', 'wpitman', 'fantom2', 'djd', 'dow', 'jak', 'jblake', 'jlewis', 'jsb', 'jw', 'klf', 'kstone', 'kub', 'lnh', 'mbw', 'mjv', 'mikem', 'jrecla', 'acv', 'dbm' )
;

update mgi_user set _usertype_key = 316352 where login in ('jrecla');
delete from voc_term where _term_key in (316358,316356);

update voc_term set term = 'go_qualifier_term', abbreviation = 'go_qualifier_term' where _term_key = 18583064;
insert into voc_term values((select nextval('voc_term_seq')), 82, 'go_qualifier_id', 'go_qualifier_id', null, 137, 0, 1001, 1001, now(), now());
delete from voc_term where _vocab_key = 82 and term in ('creation-date');

-- probably remove
DROP FUNCTION IF EXISTS VOC_deleteGOWithdrawn();

-- duplicate voc_term.note
-- occurs_at | BFO:0000066
-- during | RO:0002092
-- results_in_division_of | RO:0002233
-- has_regulation_target | RO:0002233
-- has_direct_input | RO:0002233
-- has_end_location | RO:0002339
-- exists_during | RO:0002491
update VOC_Term set note = null where _vocab_key = 82 and term = 'occurs_at';
update VOC_Term set note = null where _vocab_key = 82 and term = 'during';
update VOC_Term set note = null where _vocab_key = 82 and term = 'results_in_division_of';
update VOC_Term set note = null where _vocab_key = 82 and term = 'has_regulation_target';
update VOC_Term set note = null where _vocab_key = 82 and term = 'has_direct_input';
update VOC_Term set note = null where _vocab_key = 82 and term = 'has_end_location';
update VOC_Term set note = null where _vocab_key = 82 and term = 'exists_during';

EOSQL

#
# set all GO annotations = GO_Central (1539)
# the goload will delete them later
#
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_Property_drop.object
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 

-- move all of the GOA_*, NOCTUA_* -> GO_Central

select _Annot_key into temp toUpdate1 from VOC_Annot where _AnnotType_key = 1000;
select p._AnnotEvidence_key into temp toUpdate2 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p
where a._AnnotType_key = 1000
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = p._AnnotEvidence_key;
;

create index td_idx1 on toUpdate1(_Annot_key);
create index td_idx2 on toUpdate2(_AnnotEvidence_key);
update voc_evidence e set _createdby_key = 1539, _modifiedby_key = 1539 from toUpdate1 t where t._annot_key = e._annot_key;
update voc_evidence_property p set _createdby_key = 1539, _modifiedby_key = 1539 from toUpdate2 t where t._annotevidence_key = p._annotevidence_key;

select s._Assoc_key 
into temp toUpdate3 
from MGI_Reference_Assoc s, MGI_User u 
where s._createdby_key = u._user_key
and u.login like 'GOA_%'
;
create index td_idx3 on toUpdate3(_Assoc_key);
update MGI_Reference_Assoc s set _createdby_key = 1539, _modifiedby_key = 1539 from toUpdate3 t where t._assoc_key = s._assoc_key;

select s._Assoc_key 
into temp toUpdate4 
from BIB_Workflow_Status s, MGI_User u 
where s._createdby_key = u._user_key
and u.login like 'GOA_%'
;
create index td_idx4 on toUpdate4(_Assoc_key);
update BIB_Workflow_Status s set _createdby_key = 1539, _modifiedby_key = 1539 from toUpdate4 t where t._assoc_key = s._assoc_key;

-- set 'GOC' -> GO_MGI to re-use this _user_key
update MGI_User set login = 'GO_MGI', name = 'GO_MGI' where _user_key = 1503;
delete from MGI_User where login like 'GOA_%';
delete from mgi_user where login like 'NOCTUA_%';

EOSQL
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_Property_create.object

#
#
# mirror_wget
# remove: ftp.geneontology.org.external2go
# remove: ftp.geneontology.org.goload
# remove: snapshot.geneontology.org.goload.noctua
# add   : 
# add to packagelist.daily:  snapshot.geneontology.org.goload.annotations
#

rm -rf ${DATADOWNLOADS}/go_noctua 
rm -rf ${DATADOWNLOADS}/go_translation
rm -rf ${DATADOWNLOADS}/go_gene_assoc
rm -rf ${DATADOWNLOADS}/goa
rm -rf ${DATADOWNLOADS}/snapshot.geneontology.org
rm -rf ${DATADOWNLOADS}/current.geneontology.org
rm -rf ${DATADOWNLOADS}/ftp.ebi.ac.uk/pub/databases/GO
rm -rf ${DATADOWNLOADS}/mirror_wget_logs/ftp.geneontology.org.external2go*
rm -rf ${DATADOWNLOADS}/mirror_wget_logs/ftp.geneontology.org.goload*
rm -rf ${DATADOWNLOADS}/mirror_wget_logs/ftp.ebi.ac.uk.goload*
rm -rf ${DATADOWNLOADS}/mirror_wget_logs/snapshot.geneontology.org.goload.noctua*

# this will need to be changed to grab the "new" Sierra file when it is ready
${MIRROR_WGET}/download_package purl.obolibrary.org.pr
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo
${MIRROR_WGET}/download_package purl.obolibrary.org.go-basic.obo
${MIRROR_WGET}/download_package raw.githubusercontent.com.evidenceontology
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload
${MIRROR_WGET}/download_package snapshot.geneontology.org.uniprotload
ln -s ${DATADOWNLOADS}/snapshot.geneontology.org/ontology/external2go ${DATADOWNLOADS}/go_translation

# change to vocload to create unique DAG bcp file names
${VOCLOAD}/runOBOIncLoad.sh GO.config

rm -rf ${DATALOADSOUTPUT}/go
rm -rf ${DATALOADSOUTPUT}/uniprot/uniprotload/output/*
rm -rf ${DATALOADSOUTPUT}/uniprot/uniprotload/logs/*
rm -rf ${DATALOADSOUTPUT}/mgi/mgicacheload/output/ACC_Accession.bcp
rm -rf ${DATALOADSOUTPUT}/mgi/mgicacheload/output/MGI_Note.go_annot_extensions.bcp
rm -rf ${DATALOADSOUTPUT}/mgi/mgicacheload/output/MGI_Note.go_isoforms.bcp
rm -rf ${DATALOADSOUTPUT}/mgi/mgicacheload/output/VOC_GO_Cache.bcp
rm -rf ${LIBDIRS}/vocabloadlib.py

# run uniprotload/now without GO annotations
# this must run before the GO load, which will generate the GPI file, which uses uniprot info
#scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
# glygen : tweek the wts575.csh to only run the scripts needed
../wts2-575/wts575.csh
${UNIPROTLOAD}/bin/uniprotload.sh 

# run go/annotations
#${GOLOAD}/Install
${GOLOAD}/bin/goload.sh
${GOLOAD}/bin/ecocheck.sh

# GO should provide
rm -rf ${PUBREPORTDIR}/output/gene_association.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_pro.mgi*
rm -rf ${PUBREPORTDIR}/output/mgi.gpad*
rm -rf ${FTPREPORTDIR}/gene_association.mgi*
rm -rf ${FTPREPORTDIR}/mgi.gpad*

# per Steven Grubb/Cindy
rm -rf ${PUBREPORTDIR}/output/BIB_PubMed.rpt
rm -rf ${FTPREPORTDIR}/BIB_PubMed.rpt

# per Richard
rm -rf /data/downloads/ftp.ncbi.nih.gov/gtblatpipeline
#do not remove reports from FTP site

# won’t be needed since they only exist to be picked up by GO:
rm -rf ${QCREPORTDIR}/output/GO_EvidenceProperty.rpt
rm -rf ${PUBREPORTDIR}/output/gene_association_nonoctua.mgi*
rm -rf ${PUBREPORTDIR}/output/gene_association_nonoctua_pro.mgi*
rm -rf ${PUBREPORTDIR}/output/mgi_nonoctua.gpad*
rm -rf ${PUBREPORTDIR}/output/gene_association.mgi*
rm -rf ${PUBREPORTDIR}/output/mgi.gpad*
rm -rf ${PUBREPORTDIR}/output/go_term.mgi*
rm -rf ${FTPREPORTDIR}/gene_association_nonoctua.mgi*
rm -rf ${FTPREPORTDIR}/gene_association_nonoctua_pro.mgi*
rm -rf ${FTPREPORTDIR}/mgi_nonoctua.gpad*
rm -rf ${FTPREPORTDIR}/output/gene_association.mgi*
rm -rf ${FTPREPORTDIR}/output/mgi.gpad*
rm -rf ${FTPREPORTDIR}/output/go_term.mgi*

# run qc reports
cd ${QCRPTS}
source ./Configuration
${QCRPTS}/qcgo_reports.csh

#
# review _vocab_key = 82 and remove any obsolete terms
# commenting out; GO is ok with leaving things as-is
#
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#
#-- property terms that are no longer used; can be deleted from voc_term
#select v.*
#from VOC_Term v
#where v._vocab_key = 82
#and not exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p 
#where a._annottype_key in (1000 , 1019)
#and a._annot_key = e._annot_key
#and e._annotevidence_key = p._annotevidence_key
#and p._propertyterm_key = v._term_key
#)
#order by v.term
#;
#
#-- property terms that are used
#select v.*
#from VOC_Term v
#where v._vocab_key = 82
#and exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p 
#where a._annottype_key in (1000, 1019)
#and a._annot_key = e._annot_key
#and e._annotevidence_key = p._annotevidence_key
#and p._propertyterm_key = v._term_key
#)
#order by v.term
#;
#
#EOSQL

# other things to test due to annotload, etc. changes
# this has been run during lec-testing mucho times, so commenting out
#${PIRSFLOAD}/bin/pirsfload.sh

date 

