#!/bin/csh -f

#
# Migration for MGI Marker
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "Marker Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

alter table MRK_Marker modify symbol varchar(50) null
go

alter table NOM_Marker modify symbol varchar(50) null
go

alter table NOM_Marker modify humanSymbol varchar(50) null
go

alter table MGI_Fantom2 modify final_symbol1 varchar(50) not null
go

alter table MGI_Fantom2 modify final_symbol2 varchar(50) not null
go

alter table MGI_Fantom2 modify approved_symbol varchar(50) not null
go

alter table MGI_Fantom2Cache modify gba_symbol varchar(50) not null
go

alter table MLD_Expt_Marker modify gene varchar(50) null
go

alter table WKS_Rosetta modify wks_markerSymbol varchar(50) null
go

end

EOSQL

date >> ${LOG}

