#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select distinct e._experiment_key, a.accid, t1.term, t4.term, t2.term, t3.term
from acc_accession a, gxd_htexperiment e, gxd_htsample s, gxd_htexperimentvariable v, 
        voc_term t1, voc_term t2, voc_term t3, voc_term t4
where a._logicaldb_key in (189, 190)
and a._object_key = e._experiment_key
and e._experimenttype_key = t1._term_key
and e._experiment_key = s._experiment_key
and e._experiment_key = v._experiment_key
and s._rnaseqtype_key = t2._term_key
and s._relevance_key = t3._term_key
and v._term_key = t4._term_key
and a.accid in (
'GSE217078',
'GSE180128',
'GSE75386',
'GSE146043',
'GSE171851',
'GSE240381',
'GSE215112',
'GSE76514',
'GSE197610',
'GSE169262',
'GSE157983',
'GSE181527',
'GSE196331',
'GSE185345',
'GSE180589',
'GSE71982',
'GSE186357',
'GSE100389',
'GSE203163',
'GSE67120',
'GSE102935',
'GSE149040',
'GSE251727',
'GSE153653',
'GSE52525',
'GSE192551',
'GSE125708',
'GSE163520',
'GSE175649',
'GSE122026',
'GSE178826',
'GSE193376',
'GSE111839',
'GSE196874',
'GSE86225',
'GSE109444',
'GSE111107',
'GSE133054',
'GSE150338',
'GSE135167',
'GSE117963',
'GSE84324',
'GSE202132',
'GSE184902',
'GSE155928',
'GSE148882',
'GSE136148',
'GSE156633',
'E-GEOD-65924',
'GSE118403',
'GSE231547',
'E-MTAB-11115',
'E-ERAD-433',
'GSE166692',
'GSE226113',
'GSE120963',
'GSE123187',
'GSE223066',
'GSE137060',
'GSE186525',
'GSE158450',
'GSE227627',
'GSE200027',
'GSE244355',
'GSE227836',
'GSE233363',
'GSE210414',
'E-GEOD-14470',
'GSE245022',
'GSE80810',
'GSE199659'
)
;
EOSQL

