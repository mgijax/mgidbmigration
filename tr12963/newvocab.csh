#!/bin/csh -f

#
# add:
#
# genome build vocabulary
# amino acid vocabulary
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
delete from voc_vocab where _vocab_key in (140, 141);
EOSQL


cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into voc_vocab values(140, 22864, -1, 1, 0, 'Genome Build', now(), now());
insert into voc_vocab values(141, 22864, -1, 1, 0, 'Amino Acid', now(), now());

EOSQL

date |tee -a $LOG

