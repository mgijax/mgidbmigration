#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
       setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use $MGD_DBNAME
go

select * from NOM_Marker where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from MRK_Marker where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from ALL_Allele where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from ALL_Marker_Assoc where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from PRB_Probe where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from PRB_Marker where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from GXD_Assay where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from GXD_Genotype where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from GXD_Index where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from VOC_Evidence where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from MGI_Reference_Assoc where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

select * from ACC_Accession where modification_date >= "04/01/2015" and _ModifiedBy_key = 1001
go

EOSQL
date | tee -a ${LOG}

