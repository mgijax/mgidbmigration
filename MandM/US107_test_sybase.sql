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

echo "MGD_DBSERVER: $MGD_DBSERVER"
echo "MGD_DBNAME: $MGD_DBNAME"
echo ""

#cat - <<EOSQL | ${MGI_DBUTILS}/bin/doisql.csh $0
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0
/* geisha */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13575998
go

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13575998
and c._Cluster_key = m._Cluster_key
go

/* homologene */
select count(*) from MRK_Cluster
where _ClusterSource_key = 9272151
go

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 9272151
and c._Cluster_key = m._Cluster_key
go

select count(*) from ACC_Accession a, MRK_Cluster c
where a._MGIType_key = 39
and a._Object_key = c._Cluster_key
go

/* hgnc */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13437099
go

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13437099
and c._Cluster_key = m._Cluster_key
go

/* zfin */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13575996
go

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13575996
and c._Cluster_key = m._Cluster_key
go

/* xenbase */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13611349
go

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13611349
and c._Cluster_key = m._Cluster_key
go

/* hybrid */
select count(*) from MRK_Cluster
where _ClusterSource_key = 13764519
go

select count(*) from MRK_Cluster c, MRK_ClusterMember m
where c._ClusterSource_key = 13764519
and c._Cluster_key = m._Cluster_key
go

select count(*) from MRK_Cluster m, MGI_Property p
where m._ClusterSource_key = 13764519
and m._Cluster_key = p._Object_key
and p._PropertyType_key = 1001
go

EOSQL
