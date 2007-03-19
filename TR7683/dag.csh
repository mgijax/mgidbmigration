#!/bin/csh -f

#
# TR 8083; new DAG
#
# Usage:  dag.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into DAG_DAG values (7,73993,13,'Obsolete','O',getdate(),getdate())
insert into VOC_VocabDAG values (4,7,getdate(),getdate())
go

EOSQL

date >> ${LOG}

