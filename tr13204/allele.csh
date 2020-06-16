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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd ALL_Allele_Mutation ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/ALL_Allele_Mutation.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/ALL_Allele_Mutation_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.ALL_Allele_Mutation DROP CONSTRAINT ALL_Allele_Mutation__Allele_key_fkey CASCADE;
ALTER TABLE mgd.ALL_Allele_Mutation DROP CONSTRAINT ALL_Allele_Mutation_pkey CASCADE;
ALTER TABLE mgd.ALL_Allele_Mutation DROP CONSTRAINT ALL_Allele_Mutation__Mutation_key_fkey CASCADE;
ALTER TABLE ALL_Allele_Mutation RENAME TO ALL_Allele_Mutation_old;

EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/ALL_Allele_Mutation_create.object | tee -a $LOG 

# autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Allele_Mutation_create.object | tee -a $LOG 

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into ALL_Allele_Mutation
select nextval('all_allele_mutation_seq'), m._allele_key, m._mutation_key, m.creation_date, m.modification_date
from ALL_Allele_Mutation_old m
;

ALTER TABLE mgd.ALL_Allele_Mutation ADD PRIMARY KEY (_Assoc_key);
ALTER TABLE mgd.ALL_Allele_Mutation ADD FOREIGN KEY (_Allele_key) REFERENCES mgd.ALL_Allele DEFERRABLE;
ALTER TABLE mgd.ALL_Allele_Mutation ADD FOREIGN KEY (_Mutation_key) REFERENCES mgd.VOC_Term DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/ALL_Allele_Mutation_drop.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/index/ALL_Allele_Mutation_create.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_Mutation_drop.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_Mutation_create.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/view/ALL_Allele_Mutation_View_create.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from ALL_Allele_Mutation_old;
select count(*) from ALL_Allele_Mutation;

drop table mgd.ALL_Allele_Mutation_old;

EOSQL

date |tee -a $LOG

