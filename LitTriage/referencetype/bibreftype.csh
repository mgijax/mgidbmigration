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
	and t.term = 'JAX Notes')
where lower(r.journal) like 'jax notes'
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
	and t.term = 'MGI Data Load')
where lower(r.journal) in ('database download', 'database procedure', 'database release')
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
or lower(r.journal) like '%personal communication%'
;
update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'Personal Communication')
where r.journal in ('The Jackson Laboratory Summer Student Program, Eva M. Eicher, Sponsor')
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
	from VOC_Vocab v, VOC_Term t
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
	and t.term = 'MGI Direct Data Submission')
where r.journal = 'MGI Direct Data Submission'
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
        and t.term = 'Conference Proceedings/Abstracts')
where r.journal in (
'7th ICLAS Symp, Utrecht 1979',
'Cytochrome P450 8th Int Conf',
'Eumorphia 3rd Annual Meeting. Barcelona, Spain',
'Fifth International Workshop on Mouse Genome Mapping',
'Joint Scientific Meeting of BDSR and NOF',
'Lillia Babbitt Hyde Foundation Conference on the Mammary Tumor Virus, Inverness, California',
'Proc 11th Int Cong Genet',
'Proc 4th Int Cong Int Soc Hematol',
'Proc XI Int Cong Genet',
'Society for Neurscience Abstracts',
'The 16th International Mouse Genome Conferance',
'Trans Am Soc Neurochem'
)
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
        from VOC_Vocab v, VOC_Term t
        where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
        and t.term = 'External Resource')
where r.journal in (
'Allen Brain Atlas',
'GBASE, The Jackson Laboratory',
'http://www.gudmap.org',
'Online Mendelian Inheritance in Man, OMIM (TM)',
'Patent Application     US20100138936 A1',
'PhenoSITE, World Wide Web (URL: http://www.brc.riken.jp/lab/gsc/mouse/)'
)
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
        from VOC_Vocab v, VOC_Term t
        where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
        and t.term = 'MGI Curation Record')
where r.journal in (
'Begins ''Companion to''',
'Res Rep Health Eff Inst'
)
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
        from VOC_Vocab v, VOC_Term t
        where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
        and t.term = 'Newsletter')
where r.journal in (
'Mouse Mutagenesis Memo No. 6',
'Begins ''Companion Issue''',
'Begins ''Mouse Genome''',
'Mouse News Lett',
'Peromyscus News Lett'
'Rat News Let'
)
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
        from VOC_Vocab v, VOC_Term t
        where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
        and t.term = 'Unreviewed Article')
where r.journal in (
'Acta Veterinaria-Beograd',
'Acta Zooligica Sinica',
'Adv Neurochem',
'Acta Veterinaria-Beograd',
'Acta Zooligica Sinica',
'Adv Neurochem',
'BioRxiv',
'bioRxiv (Cold Spring Harbor Lab reprint)',
'Cardiovascular Research',
'Cogent Biology',
'Colloq Int (Collques Internationaux) C.N.R.S.',
'Environ Pollut',
'Exp Anim (Tokyo)',
'Genet Res Camb',
'Genome Biol Evol',
'Handbook of Experimental Pharmacology',
'Health Research',
'Inflamm Regen',
'Int J Biol',
'J Cancer Prevention',
'J Inborn Errors of Metab and Screening',
'Jap J Clin Opthalmol',
'North American J Med Sci',
'Proc New Zealand Soc Anim Prod',
'Records of Genetics Soc. Amer',
'Sichuan J of Zoology'
)
;

update BIB_Refs r
set _ReferenceType_key = (select t._Term_key
        from VOC_Vocab v, VOC_Term t
        where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
        and t.term = 'Annual Report/Bulletin')
where r.journal like ('%Special Bulletin')
or r.journal like ('%Annu Rep%')
or r.journal like ('%Ann Rep%')
or r.journal like ('%Annual Report%')
or r.journal like ('%Scientific Report%')
or r.journal like ('%Final Report%')
;

EOSQL

./bibpeer.csh | tee -a $LOG

#
# there should be no reference associated with Reference Type 'Not Specified'
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select distinct journal 
from BIB_Refs r, VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' 
and v._Vocab_key = t._Vocab_key 
and t.term = 'Not Specified'
and t._Term_key = r._ReferenceType_key
order by journal
;

--delete from VOC_Term t using VOC_Vocab v where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key and t.term = 'Not Specified';
EOSQL

