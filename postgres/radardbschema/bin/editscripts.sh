#!/bin/sh

cd `dirname $0` && . ../Configuration

#
# edit from sybase to postgres
#

${RADARPOSTGRES}/bin/editcreatetable.sh
${RADARPOSTGRES}/bin/editdroptable.sh
${RADARPOSTGRES}/bin/edittruncatetable.sh

${RADARPOSTGRES}/bin/editcreatekey.sh
${RADARPOSTGRES}/bin/editdropkey.sh

${RADARPOSTGRES}/bin/editcreateindex.sh
${RADARPOSTGRES}/bin/editdropindex.sh

${RADARPOSTGRES}/bin/editcreateview.sh
${RADARPOSTGRES}/bin/editdropview.sh

