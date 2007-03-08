#!/bin/csh -f

#
# Change the cell line of any clone libraries to be "Not Applicable" where:
#
#     - the current cell line is "Not Specified"
#     - the tissue is anything other than "Not Specified"
#
# Usage:  clonelib.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update PRB_Source
set _CellLine_key = 316336
where _CellLine_key = 316335 and
      _Tissue_key != -1
go

EOSQL

date >> ${LOG}

