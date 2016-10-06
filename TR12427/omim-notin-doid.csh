#!/bin/csh -f

#
# Template
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

\echo ''
\echo '-- omim-to-genotype (1005)'
\echo '-- omim-to-allele (1012)'
\echo ''
(
select a1.accID, oo.term
from ACC_Accession a1, VOC_Term oo
where a1._MGIType_key = 13
and a1._Object_key = oo._Term_key
and a1.preferred = 1
and oo._Vocab_key = 44
and not exists (select 1 from ACC_Accession a2, VOC_Term oo2
	where a1.accID = a2.accID
	and a2._LogicalDB_key = 15
	and a2._MGIType_key = 13
	and a2._Object_key = oo2._Term_key
	and oo2._Vocab_key = 125
	)
and exists (select 1 from VOC_Annot v where v._AnnotType_key = 1005 and v._Term_key = a1._Object_key)
union all
select a1.accID, oo.term
from ACC_Accession a1, VOC_Term oo
where a1._MGIType_key = 13
and a1._Object_key = oo._Term_key
and a1.preferred = 1
and oo._Vocab_key = 44
and not exists (select 1 from ACC_Accession a2, VOC_Term oo2
	where a1.accID = a2.accID
	and a2._LogicalDB_key = 15
	and a2._MGIType_key = 13
	and a2._Object_key = oo2._Term_key
	and oo2._Vocab_key = 125
	)
and exists (select 1 from VOC_Annot v where v._AnnotType_key = 1012 and v._Term_key = a1._Object_key)
)
order by accID
;

--\echo ''
--\echo '-- omim-to-derivation (1016)'
--\echo ''
--select a1.accID, oo.term
--from ACC_Accession a1, VOC_Term oo
--where a1._MGIType_key = 13
--and a1._Object_key = oo._Term_key
--and oo._Vocab_key = 44
--and not exists (select 1 from ACC_Accession a2, VOC_Term oo2
	--where a1.accID = a2.accID
	--and a2._LogicalDB_key = 15
	--and a2._MGIType_key = 13
	--and a2._Object_key = oo2._Term_key
	--and oo2._Vocab_key = 125
	--)
--and exists (select 1 from VOC_Annot v where v._AnnotType_key = 1016 and v._Term_key = a1._Object_key)
--order by a1.accID
--;

--\echo ''
--\echo '-- omim-to-humangene (1006)'
--\echo ''
--select a1.accID, oo.term
--from ACC_Accession a1, VOC_Term oo
--where a1._MGIType_key = 13
--and a1._Object_key = oo._Term_key
--and oo._Vocab_key = 44
--and not exists (select 1 from ACC_Accession a2, VOC_Term oo2
	--where a1.accID = a2.accID
	--and a2._LogicalDB_key = 15
	--and a2._MGIType_key = 13
	--and a2._Object_key = oo2._Term_key
	--and oo2._Vocab_key = 125
	--)
--and exists (select 1 from VOC_Annot v where v._AnnotType_key = 1006 and v._Term_key = a1._Object_key)
--order by a1.accID
--;

--\echo ''
--\echo '-- hpo-to-omim (1018)'
--\echo ''
--select a1.accID, oo.term
--from ACC_Accession a1, VOC_Term oo
--where a1._MGIType_key = 13
--and a1._Object_key = oo._Term_key
--and oo._Vocab_key = 44
--and not exists (select 1 from ACC_Accession a2, VOC_Term oo2
	--where a1.accID = a2.accID
	--and a2._LogicalDB_key = 15
	--and a2._MGIType_key = 13
	--and a2._Object_key = oo2._Term_key
	--and oo2._Vocab_key = 125
	--)
--and exists (select 1 from VOC_Annot v where v._AnnotType_key = 1018 and v._Object_key = a1._Object_key)
--order by a1.accID
--;

-- OMIM id is in OMIM original vocabulary but not in DO
--select a1.accID, oo.term
--from ACC_Accession a1, VOC_Term oo
--where a1._MGIType_key = 13
--and a1._Object_key = oo._Term_key
--and oo._Vocab_key = 44
--and not exists (select 1 from ACC_Accession a2, VOC_Term oo2
	--where a1.accID = a2.accID
	--and a2._LogicalDB_key = 15
	--and a2._MGIType_key = 13
	--and a2._Object_key = oo2._Term_key
	--and oo2._Vocab_key = 125
	--)
--;

EOSQL

date |tee -a $LOG

