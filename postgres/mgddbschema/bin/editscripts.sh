#!/bin/sh

cd `dirname $0` && . ../Configuration

#
# edit from sybase to postgres
#

${MGDPOSTGRES}/bin/editcreatetable.sh
${MGDPOSTGRES}/bin/editdroptable.sh
${MGDPOSTGRES}/bin/edittruncatetable.sh

#see editcreatekey.sh before un-commenting this call
#${MGDPOSTGRES}/bin/editcreatekey.sh
#${MGDPOSTGRES}/bin/editdropkey.sh

${MGDPOSTGRES}/bin/editcreateindex.sh
${MGDPOSTGRES}/bin/editdropindex.sh

${MGDPOSTGRES}/bin/editcreateview.sh
${MGDPOSTGRES}/bin/editdropview.sh

