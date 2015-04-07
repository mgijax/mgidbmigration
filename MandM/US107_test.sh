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

sybase_path=$1
linux_path=$2
echo "sybase_path: $sybase_path"
echo "linux_path: $linux_path"
echo ""

echo "geisha sybase bcp counts"
echo "MRK_Cluster.bcp:"
cat $sybase_path/geishaload/output/MRK_Cluster.bcp | wc -l
echo "MRK_ClusterMember.bcp:"
cat $sybase_path/geishaload/output/MRK_ClusterMember.bcp | wc -l
echo ""

echo "geisha postgres bcp counts"
echo "MRK_Cluster.bcp:"
cat $linux_path/geishaload/output/MRK_Cluster.bcp | wc -l
echo "MRK_ClusterMember.bcp:"
cat $linux_path/geishaload/output/MRK_ClusterMember.bcp | wc -l
echo ""

echo "geisha bcp diffs"
sybase_cluster=$sybase_path/geishaload/output/MRK_Cluster.bcp
linux_cluster=$linux_path/geishaload/output/MRK_Cluster.bcp
sybase_cluster_sort=MRK_Cluster.sybase.sort
linux_cluster_sort=MRK_Cluster.linux.sort
cluster_diff=geisha_cluster.diff

cat $sybase_cluster | cut -f1-6 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f1-6 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff
#rm $sybase_cluster_sort $linux_cluster_sort

echo "homologene bcp counts"
echo "MRK_Cluster.bcp:"
cat $sybase_path/homologeneload/output/MRK_Cluster.bcp | wc -l
echo "MRK_ClusterMember.bcp:"
cat $sybase_path/homologeneload/output/MRK_ClusterMember.bcp | wc -l
echo ""

echo "hgnc bcp counts"
echo "MRK_Cluster.bcp:"
cat $sybase_path/hgncload/output/MRK_Cluster.bcp | wc -l
echo "MRK_ClusterMember.bcp:"
cat $sybase_path/hgncload/output/MRK_ClusterMember.bcp | wc -l
echo ""

echo "zfin bcp counts"
echo "MRK_Cluster.bcp:"
cat $sybase_path/zfinload/output/MRK_Cluster.bcp | wc -l
echo "MRK_ClusterMember.bcp:"
cat $sybase_path/zfinload/output/MRK_ClusterMember.bcp | wc -l
echo ""

echo "xenbase bcp counts"
echo "MRK_Cluster.bcp:"
cat $sybase_path/xenbaseload/output/MRK_Cluster.bcp | wc -l
echo "MRK_ClusterMember.bcp:"
cat $sybase_path/xenbaseload/output/MRK_ClusterMember.bcp | wc -l
echo ""

echo "hybrid bcp counts"
echo "MRK_Cluster.bcp:"
cat $sybase_path/hybridload/output/MRK_Cluster.bcp | wc -l
echo "MRK_ClusterMember.bcp:"
cat $sybase_path/hybridload/output/MRK_ClusterMember.bcp | wc -l

