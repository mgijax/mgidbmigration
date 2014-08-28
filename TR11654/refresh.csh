#!/bin/csh

${MGD_DBSCHEMADIR}/table/GXD_Expression_drop.object

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0

use ${MGD_DBNAME}
go

sp_rename GXD_Expression_Old, GXD_Expression
go

EOSQL

#${MGD_DBSCHEMADIR}/index/GXD_Expression_drop.object
#${MGD_DBSCHEMADIR}/table/GXD_Expression_truncate.object
#bcpin.csh DEV1_MGI mgd_lec1 GXD_Expression
#${MGD_DBSCHEMADIR}/index/GXD_Expression_create.object

