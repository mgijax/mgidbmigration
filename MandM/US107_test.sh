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
output_dir=$3
echo "sybase_path: $sybase_path"
echo "linux_path: $linux_path"
echo ""

echo "geisha bcp diffs"
sybase_cluster=$sybase_path/geishaload/output/MRK_Cluster.bcp
linux_cluster=$linux_path/geishaload/output/MRK_Cluster.bcp
sybase_cluster_sort=$output_dir/MRK_Cluster.sybase.geisha.sort
linux_cluster_sort=$output_dir/MRK_Cluster.linux.geisha.sort
cluster_diff=$output_dir/geisha_cluster.diff

cat $sybase_cluster | cut -f1-6 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f1-6 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/geishaload/output/MRK_ClusterMember.bcp
linux_cluster=$linux_path/geishaload/output/MRK_ClusterMember.bcp
sybase_cluster_sort=$output_dir/MRK_ClusterMember.sybase.geisha.sort
linux_cluster_sort=$output_dir/MRK_ClusterMember.linux.geisha.sort
cluster_diff=$output_dir/geisha_clusterMember.diff

cat $sybase_cluster | cut -f2-3 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f2-3 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff


echo "hgnc bcp diffs"
sybase_cluster=$sybase_path/hgncload/output/MRK_Cluster.bcp
linux_cluster=$linux_path/hgncload/output/MRK_Cluster.bcp
sybase_cluster_sort=$output_dir/MRK_Cluster.sybase.hgnc.sort
linux_cluster_sort=$output_dir/MRK_Cluster.linux.hgnc.sort
cluster_diff=$output_dir/hgnc_cluster.diff

cat $sybase_cluster | cut -f1-6 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f1-6 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/hgncload/output/MRK_ClusterMember.bcp
linux_cluster=$linux_path/hgncload/output/MRK_ClusterMember.bcp
sybase_cluster_sort=$output_dir/MRK_ClusterMember.sybase.hgnc.sort
linux_cluster_sort=$output_dir/MRK_ClusterMember.linux.hgnc.sort
cluster_diff=$output_dir/hgnc_clusterMember.diff

cat $sybase_cluster | cut -f2-3 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f2-3 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff


echo "zfin bcp diffs"
sybase_cluster=$sybase_path/zfinload/output/MRK_Cluster.bcp
linux_cluster=$linux_path/zfinload/output/MRK_Cluster.bcp
sybase_cluster_sort=$output_dir/MRK_Cluster.sybase.zfin.sort
linux_cluster_sort=$output_dir/MRK_Cluster.linux.zfin.sort
cluster_diff=$output_dir/zfin_cluster.diff

cat $sybase_cluster | cut -f1-6 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f1-6 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/zfinload/output/MRK_ClusterMember.bcp
linux_cluster=$linux_path/zfinload/output/MRK_ClusterMember.bcp
sybase_cluster_sort=$output_dir/MRK_ClusterMember.sybase.zfin.sort
linux_cluster_sort=$output_dir/MRK_ClusterMember.linux.zfin.sort
cluster_diff=$output_dir/zfin_clusterMember.diff

cat $sybase_cluster | cut -f2-3 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f2-3 |  sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff


echo "xenbase bcp diffs"
sybase_cluster=$sybase_path/xenbaseload/output/MRK_Cluster.bcp
linux_cluster=$linux_path/xenbaseload/output/MRK_Cluster.bcp
sybase_cluster_sort=$output_dir/MRK_Cluster.sybase.xenbase.sort
linux_cluster_sort=$output_dir/MRK_Cluster.linux.xenbase.sort
cluster_diff=$output_dir/xenbase_cluster.diff

cat $sybase_cluster | cut -f1-6 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f1-6 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/xenbaseload/output/MRK_ClusterMember.bcp
linux_cluster=$linux_path/xenbaseload/output/MRK_ClusterMember.bcp
sybase_cluster_sort=$output_dir/MRK_ClusterMember.sybase.xenbase.sort
linux_cluster_sort=$output_dir/MRK_ClusterMember.linux.xenbase.sort
cluster_diff=$output_dir/xenbase_clusterMember.diff

cat $sybase_cluster | cut -f2-3 | sort > $sybase_cluster_sort
cat $linux_cluster |  cut -f2-3 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff


echo "homologene bcp diffs"
sybase_cluster=$sybase_path/homologeneload/output/MRK_Cluster.bcp
linux_cluster=$linux_path/homologeneload/output/MRK_Cluster.bcp
sybase_cluster_sort=$output_dir/MRK_Cluster.sybase.homologene.sort
linux_cluster_sort=$output_dir/MRK_Cluster.linux.homologene.sort
cluster_diff=$output_dir/homologene_cluster.diff

cat $sybase_cluster | cut -f1-6 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f1-6 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/homologeneload/output/MRK_ClusterMember.bcp
linux_cluster=$linux_path/homologeneload/output/MRK_ClusterMember.bcp
sybase_cluster_sort=$output_dir/MRK_ClusterMember.sybase.homologene.sort
linux_cluster_sort=$output_dir/MRK_ClusterMember.linux.homologene.sort
cluster_diff=$output_dir/homologene_clusterMember.diff

cat $sybase_cluster | cut -f2-3 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f2-3 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/homologeneload/output/ACC_Accession.bcp
linux_cluster=$linux_path/homologeneload/output/ACC_Accession.bcp
sybase_cluster_sort=$output_dir/ACC_Accession.bcp.sybase.homologene.sort
linux_cluster_sort=$output_dir/ACC_Accession.bcp.linux.homologene.sort
cluster_diff=$output_dir/homologene_accession.diff

cat $sybase_cluster | cut -f2-9 | sort > $sybase_cluster_sort
cat $linux_cluster |  cut -f2-9 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff


echo "hybrid bcp diffs"
sybase_cluster=$sybase_path/hybridload/output/MRK_Cluster.bcp
linux_cluster=$linux_path/hybridload/output/MRK_Cluster.bcp
sybase_cluster_sort=$output_dir/MRK_Cluster.sybase.hybrid.sort
linux_cluster_sort=$output_dir/MRK_Cluster.linux.hybrid.sort
cluster_diff=$output_dir/hybrid_cluster.diff

cat $sybase_cluster | cut -f1-6 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f1-6 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/hybridload/output/MRK_ClusterMember.bcp
linux_cluster=$linux_path/hybridload/output/MRK_ClusterMember.bcp
sybase_cluster_sort=$output_dir/MRK_ClusterMember.sybase.hybrid.sort
linux_cluster_sort=$output_dir/MRK_ClusterMember.linux.hybrid.sort
cluster_diff=$output_dir/hybrid_clusterMember.diff

cat $sybase_cluster | cut -f2-3 | sort > $sybase_cluster_sort
cat $linux_cluster | cut -f2-3 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

sybase_cluster=$sybase_path/hybridload/output/MGI_Property.bcp
linux_cluster=$linux_path/hybridload/output/MGI_Property.bcp
sybase_cluster_sort=$output_dir/MGI_Property.sybase.hybrid.sort
linux_cluster_sort=$output_dir/MGI_Property.linux.hybrid.sort
cluster_diff=$output_dir/hybrid_property.diff

cat $sybase_cluster | cut -f2-7 | sort > $sybase_cluster_sort
cat $linux_cluster |  cut -f2-7 | sort  > $linux_cluster_sort
diff $sybase_cluster_sort  $linux_cluster_sort > $cluster_diff

