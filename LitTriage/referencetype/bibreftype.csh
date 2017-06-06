#!/bin/csh -f

#
# migrates bib_refs._referencetype_key
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

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'MGI Curation Record')
where lower(r.journal) = 'genbank submission'
;

-- Peer Reviewed Article
update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Peer Reviewed Article')
where lower(r.journal) in ('exp eye res', 'plos biol')
;
update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Peer Reviewed Article')
where lower(r.journal) like 'skrifter %'
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Dissertation/Thesis')
where lower(r.journal) like '% thesis%'
;
update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Dissertation/Thesis')
from BIB_Notes n
where r._Refs_key = n._Refs_key
and (lower(n.note) like '%graduate thesis%' or lower(n.note) like '%dissertation%')
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Conference Proceedings/Abstracts')
where lower(r.pgs) like '%abstr%'
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Conference Proceedings/Abstracts')
where lower(r.title) like '%abstract%'
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'MGI Data Load')
where r.title in ('Mammalian Orthology Load', 'Protein SuperFamily Classification Load', 'HCOP Orthology Load',
	'Allen Brain Atlas [Internet] database Load', 'MouseFuncLoad', 'Wikipedia Gene Summary Load')
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'MGI Data Load')
where lower(r.title) like '%fantom2%' and lower(r.authors) like 'mouse genome informatics%'
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Personal Communication')
where lower(r.title) like '%personal communication%'
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'MGI Direct Data Submission')
from ACC_Accession a
where r._Refs_key = a._Object_key
and a.accID in ('J:207088', 'J:77793')
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
        from VOC_Vocab v, VOC_Term t
        where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
        and t.term = 'Peer Review Article')
where r.journal in (
'Am J Hum Genet',
'Anat Rec',
'Anim Genet',
'Arch Physiol Biochem',
'Behav Genet',
'Blood',
'Br J Rheumatol',
'Brain Pathol',
'Circulation',
'Cong Anom',
'Cytogenet Cell Genet',
'Dev Dyn',
'Diabetes',
'Eur Cytokine Netw',
'Exp Hematol',
'Experientia',
'FASEB J',
'Fed Proc',
'Gastroenterology',
'Genet Res',
'Genetics',
'Genome',
'Hepatology',
'Hered Deaf News',
'Hereditas',
'Hum Reprod',
'Immunogenetics',
'Int J Exp Pathol',
'Invest Ophthalmol Vis Sci',
'Isozyme Bulletin',
'J Anat',
'J Anim Sci',
'J Assist Reprod Genet',
''J Bone Miner Res',
'J Exp Zool',
'J Immunol',
'J Invest Dermatol',
'J Neurochem',
'J Neuropathol Exp Neurol',
'J Pathol',
'J Physiol',
'J Reprod Fertil',
'J Reticuloendothel Soc',
'Lab Invest',
'Mamm Genome',
'Mol Immunol',
'Neuropathology',
'Neurosci Lett',
'Neuroscience',
'Proc Am Assoc Cancer Res',
'Prostaglandins',
'Regul Pept',
'Sleep',
'Soc Neurosci',
'Teratology',
'Tex Rep Biol Med',
'Trans R Soc Trop Med Hyg',
'Transgenic Res'
)
;

EOSQL

#
# there should be no reference associated with Reference Type 'Not Specified'
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(r.*) from BIB_Refs r, VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' 
and v._Vocab_key = t._Vocab_key 
and t.term = 'Not Specified'
and t._Term_key = r._ReferenceType_key
;

--delete from VOC_Term t using VOC_Vocab v where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key and t.term = 'Not Specified';
EOSQL

