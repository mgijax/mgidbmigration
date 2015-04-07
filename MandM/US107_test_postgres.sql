#!/bin/sh
 
#
#  If the MGICONFIG environment variable does not have a local override,
#  use the default "live" settings.
#
if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

CONFIG_MASTER=${MGICONFIG}/master.config.sh

export CONFIG_MASTER

echo "PG_DBSERVER: $PG_DBSERVER"
echo "PG_DBNAME: $PG_DBNAME"
echo ""

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

/* geisha */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13575998;

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13575998
and c._Cluster_key = m._Cluster_key;

/* homologene */
select count(*) from MRK_Cluster
where _ClusterSource_key = 9272151;

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 9272151
and c._Cluster_key = m._Cluster_key;

select count(*) from ACC_Accession a, MRK_Cluster c
where a._MGIType_key = 39
and a._Object_key = c._Cluster_key;

/* hgnc */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13437099;

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13437099
and c._Cluster_key = m._Cluster_key;

/* zfin */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13575996;

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13575996
and c._Cluster_key = m._Cluster_key;

/* xenbase */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13611349;

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13611349
and c._Cluster_key = m._Cluster_key;

/* hybrid */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13764519;

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13764519
and c._Cluster_key = m._Cluster_key;

select count(*) from MRK_Cluster m, MGI_Property p
where m._ClusterSource_key = 13764519
and m._Cluster_key = p._Object_key
and p._PropertyType_key = 1001;

EOSQL
