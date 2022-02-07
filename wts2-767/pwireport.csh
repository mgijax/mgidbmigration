#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PWI_Report ${MGI_LIVE}/dbutils/mgidbmigration/wts2-767/PWI_Report.bcp "|"

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update PWI_Report set sql_text = 'select accg.accid genotype_id, accr.accid jnum_id, mn._note_key, nt.notetype, mn.note from voc_annot annot join voc_evidence ev on (ev._annot_key=annot._annot_key) join acc_accession acct on ( acct._object_key=annot._term_key and acct._mgitype_key=13 ) join acc_accession accg on ( accg._object_key=annot._object_key and accg._mgitype_key=12 and accg.preferred=1 and accg._logicaldb_key=1 and accg.prefixpart=''MGI:'' ) join acc_accession accr on ( accr._object_key=ev._refs_key and accr._mgitype_key=1 and accr.preferred=1 and accr.prefixpart=''J:'' ) left outer join mgi_note mn on ( mn._object_key=ev._annotevidence_key and mn._mgitype_key=25 ) left outer join mgi_notetype nt on ( nt._notetype_key=mn._notetype_key ) where annot._AnnotType_key = 1002 and acct.accid=''###MP Term ID###'' order by genotype_id, jnum_id, mn._note_key'
where id = 1
;

update PWI_Report set sql_text = 'select accg.accid genotype_id, accr.accid jnum_id, mn._note_key, nt.notetype, mn.note from voc_annot annot join voc_evidence ev on (ev._annot_key=annot._annot_key) join acc_accession acct on ( acct._object_key=annot._term_key and acct._mgitype_key=13 ) join acc_accession accg on ( accg._object_key=annot._object_key and accg._mgitype_key=12 and accg.preferred=1 and accg._logicaldb_key=1 and accg.prefixpart=''MGI:'' ) join acc_accession accr on ( accr._object_key=ev._refs_key and accr._mgitype_key=1 and accr.preferred=1 and accr.prefixpart=''J:'' ) left outer join mgi_note mn on ( mn._object_key=ev._annotevidence_key and mn._mgitype_key=25 ) left outer join mgi_notetype nt on ( nt._notetype_key=mn._notetype_key ) where annot._AnnotType_key = 1002 and acct.accid=''###MP Term ID###'' order by genotype_id, jnum_id, mn._note_key'
where id = 3
;

update PWI_Report set sql_text = 'select a1.accid as arrayExpID, hts.name as sampleName, t2.term as relevance, hts.age as sampleAge, t.term as emapaTerm, ts.stage, n.note as sampleNote from MGI_Note n, GXD_HTSample hts, VOC_Term t, ACC_Accession a1, VOC_Term t2, GXD_TheilerStage ts where n._Notetype_key = 1048 --GXD_HTSample and lower(n.note) like lower(''%###Sample Note Text###%'') and n._Object_key = hts._Sample_key and hts._emapa_key = t._Term_key and hts._Experiment_key = a1._Object_key and a1._MGIType_key = 42 and a1.preferred = 1 and a1._LogicalDB_key = 189 and hts._Relevance_key = t2._Term_key and hts._Stage_key = ts._Stage_key'
where id = 37
;

update PWI_Report set sql_text = 'select v._Allele_key into temporary table notReviewed from ALL_Variant v, ALL_Variant_Sequence s where v._sourcevariant_key is not null and v.isreviewed = 0 and v._Variant_key = s._Variant_key and s._Sequence_type_key = 316347 --dna and s.version is not null and s.startCoordinate is not null and s.endCoordinate is not null and s.variantSequence is not null and s.referenceSequence is not null ; create index idx1 on notReviewed(_Allele_key) ; select mn._Object_key, mn.note into temporary table curNote from MGI_Note mn where mn._Notetype_key = 1050; create index idx2 on curNote(_Object_key) ; select distinct a.accID as alleleID, aa.symbol as alleleSymbol, nn.note as curatorNote from ACC_Accession a, ALL_Allele aa, notReviewed n left outer join curNote nn on n._Allele_key = nn._Object_key where n._Allele_key = aa._Allele_key and n._Allele_key = a._Object_key and a._MGIType_key = 11 and a._LogicalDB_key = 1 and a.preferred = 1 and a.prefixPart = ''MGI:'' order by aa.symbol'
where id = 45
;

update PWI_Report set sql_text = 'select al.symbol as alleleSymbol, aa.accid as alleleID, vs._variant_key, vs.startCoordinate as start, vs.endCoordinate as end, vs.referenceSequence as reference, vs.variantSequence as variant, u.name as createdBy into temporary table curatedNotReviewed from all_variant av, all_variant_sequence vs, all_allele al, acc_accession aa, mgi_user u where av._sourceVariant_key is not null and av.isReviewed = 0 and av._createdby_key = u._user_key and av._variant_key = vs._variant_key and vs._sequence_type_key = 316347 /*genomic*/ and vs.startCoordinate is not null and vs.endCoordinate is not null and vs.referenceSequence is not null and vs.variantSequence is not null and av._allele_key = al._allele_key and al._allele_key = aa._object_key and aa._mgitype_key = 11 and aa._logicaldb_key = 1 and aa.preferred = 1 and aa.prefixPart = ''MGI:'' ; create index idx1 on curatedNotReviewed(_variant_key) ; select n._object_key as _variant_key, n.note into temporary table curatorNotes from MGI_Note n where n._noteType_key = 1050; create index idx2 on curatorNotes(_variant_key) ; select cnr.alleleSymbol, cnr.alleleID, cnr.start, cnr.end, cnr.reference, cnr.variant, cnr.createdBy, cn.note as curatorNote from curatedNotReviewed cnr left outer join curatorNotes cn on(cnr._variant_key = cn._variant_key) order by cnr.alleleSymbol'
where id = 48
;

EOSQL

date |tee -a $LOG

