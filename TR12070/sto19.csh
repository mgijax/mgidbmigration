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

--        into temporary table annotations 
        select distinct p.value
        from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p, VOC_Term t
        where a._AnnotType_key = 1000 
        and a._Annot_key = e._Annot_key 
        and e._AnnotEvidence_key = p._AnnotEvidence_key
        and p._PropertyTerm_key = t._Term_key
        and t._Vocab_key = 82
        and t.term not in ('anatomy', 
                'cell type', 
                'dual-taxon ID', 
                'evidence', 
                'external ref', 
                'gene product', 
                'modification', 
                'target', 
                'text')
        and p.value is not null 
        and (
             p.value like '%EMAP:%'
            )
        order by p.value
;

EOSQL

date |tee -a $LOG

