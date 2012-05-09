#!/bin/sh

#
# cleanup for postgres migration
#

cd `dirname $0` && . ../Configuration

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0

select * from SNP_ConsensusSnp_StrainAllele s 
where not exists (select 1 from SNP_Strain ss where ss._mgdStrain_key = s._mgdStrain_key);

EOSQL

