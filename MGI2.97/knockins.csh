#!/bin/csh -f

#
# Test date for Knock-Ins
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

declare @reporterGeneKey integer
select @reporterGeneKey = _Term_key from VOC_Term_GXDReporterGene_View where term = "lacZ"

declare @indexAssayKey integer
select @indexAssayKey = _Term_key from VOC_Term_GXDIndexAssay_View where term = "Knock in"

update GXD_Assay 
set _AssayType_key = 9, _ReporterGene_key = @reporterGeneKey
from  VOC_Term_GXDReporterGene_View
where _Assay_key in (5201, 3827, 6779)

update GXD_Assay
set _AntibodyPrep_key = null
where _Assay_key = 6779

update GXD_Index_Stages 
set _IndexAssay_key = @indexAssayKey 
from GXD_Index i, GXD_Index_Stages s
where i._Refs_key = 21724 and i._Marker_key = 12184 and i._Index_key = s._Index_key

update GXD_Index_Stages 
set _IndexAssay_key = @indexAssayKey 
from GXD_Index i, GXD_Index_Stages s
where i._Refs_key = 49625 and i._Marker_key = 12184 and i._Index_key = s._Index_key

update GXD_Index_Stages 
set _IndexAssay_key = @indexAssayKey 
from GXD_Index i, GXD_Index_Stages s
where i._Refs_key = 79645 and i._Marker_key = 12184 and i._Index_key = s._Index_key

go

checkpoint
go

quit

EOSQL

date | tee -a $LOG

