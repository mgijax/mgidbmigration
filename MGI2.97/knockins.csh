#!/bin/csh -f

#
# Migration for Knock-Ins (testing only)
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

update GXD_Assay 
set _AssayType_key = 9, _ReporterGene_key = @reporterGeneKey
from  VOC_Term_GXDReporterGene_View
where _Assay_key in (5201, 3827, 6779)
go

update GXD_Assay
set _AntibodyPrep_key = null
where _Assay_key = 6779
go

declare @indexKey integer
select @indexKey = _Index_key from GXD_Index where _Refs_key = 21724 and _Marker_key = 12184

declare @indexAssayKey integer
select @indexAssayKey = _Term_key from VOC_Term_GXDIndexAssay_View where term = "Knock in"

update GXD_Index_Stages set _IndexAssay_key = @indexAssayKey where _Index_key = @indexKey
go

declare @indexKey integer
select @indexKey = _Index_key from GXD_Index where _Refs_key = 49625 and _Marker_key = 12184

declare @indexAssayKey integer
select @indexAssayKey = _Term_key from VOC_Term_GXDIndexAssay_View where term = "Knock in"

update GXD_Index_Stages set _IndexAssay_key = @indexAssayKey where _Index_key = @indexKey
go

declare @indexKey integer
select @indexKey = _Index_key from GXD_Index where _Refs_key = 79645 and _Marker_key = 12184

declare @indexAssayKey integer
select @indexAssayKey = _Term_key from VOC_Term_GXDIndexAssay_View where term = "Knock in"

update GXD_Index_Stages set _IndexAssay_key = @indexAssayKey where _Index_key = @indexKey
go

checkpoint
go

quit

EOSQL

date | tee -a $LOG

