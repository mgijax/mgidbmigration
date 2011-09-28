#!/bin/sh

#
# cleanup for postgres migration
#

cd `dirname $0` &. ./Configuration

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0

/* MouseCyc loads DAG edges whose parent does not exist in DGA_Node */
/* this product needs to be looked at and fixed */
delete from DAG_Edge e where not exists (select 1 from DAG_Node n where e._Parent_key = n._Node_key);

/* GXD_GelBand contains _GelLane_key that does not exist in GXD_GelLane */
delete from GXD_GelBand b where not exists (select 1 from GXD_GelLane g where b._GelLane_key = g._GelLane_key);

/* GXD_Index_Stages contains _Index_key that does not exist in GXD_Index */
delete from GXD_Index_Stages a where not exists (select 1 from GXD_Index b where a._Index_key = b._Index_key);

delete from HMD_Homology_Marker a where not exists (select 1 from HMD_Homology b where a._Homology_key = b._Homology_key);

delete from IMG_ImagePane a where not exists (select 1 from IMG_Image b where a._Image_key = b._Image_key);

delete from CRS_Cross a where not exists (select 1 from PRB_Strain b where a._malestrain_key = b._strain_key);

delete from PRB_Strain_Genotype a where not exists (select 1 from PRB_Strain b where a._strain_key = b._strain_key);

delete from PRB_Source a where not exists (select 1 from PRB_Tissue b where a._Tissue_key = b._Tissue_key);

update ACC_LogicalDB set _Organism_key = null where _LogicalDB_key in (142,143);


EOSQL

