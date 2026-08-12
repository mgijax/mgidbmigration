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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- strainmarkerload
select t1._vocab_key, t1.term as rawBiotype, t2.term as primaryMcvTerm
        from VOC_Term t1, VOC_Term t2, MRK_BiotypeMapping m
        where t1._Vocab_key = 136 --Biotype MGP
        and t1._Term_key = m._BiotypeTerm_key
        and m._PrimaryMCVTerm_key = t2._Term_key
	order by t1.term
;

-- straingenomeload
select _vocab_key, term from voc_term where _vocab_key = 79 order by term;

select t1._vocab_key, t1.term as rawBiotype, t2.term as primaryMcvTerm
        from VOC_Term t1, VOC_Term t2, MRK_BiotypeMapping m
        where t1._Vocab_key = 136 --Biotype MGP
        and t1._Term_key = m._BiotypeTerm_key
        and m._PrimaryMCVTerm_key = t2._Term_key
	and not exists (select 1 from voc_term b where t1.term = b.term and b._vocab_key = 79)
	order by t1.term
;

EOSQL

