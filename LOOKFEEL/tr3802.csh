#!/bin/csh -f

#
# Migration for TR 3802
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
# for testing, drop objects first
${newmgddbschema}/table/GXD_AlleleGenotype_drop.object
${newmgddbschema}/procedure/GXD_loadGenoCacheAll_drop.object
${newmgddbschema}/procedure/GXD_loadGenoCacheByGenotype_drop.object
${newmgddbschema}/view/GXD_AlleleGenotype_View_drop.object

#
# Use new schema product to create new objects
#
${newmgddbschema}/default/user_default_create.object
${newmgddbschema}/table/GXD_AlleleGenotype_create.object
${newmgddbschema}/default/GXD_AlleleGenotype_bind.object
${newmgddbschema}/procedure/GXD_loadGenoCacheByGenotype_create.object
${newmgddbschema}/procedure/GXD_loadGenoCacheAll_create.object
${newmgddbschema}/trigger/GXD_Genotype_drop.object
${newmgddbschema}/trigger/GXD_Genotype_create.object
${newmgddbschema}/view/GXD_AlleleGenotype_View_create.object
${newmgddbperms}/public/table/GXD_AlleleGenotype_grant.object
${newmgddbperms}/curatorial/table/GXD_AlleleGenotype_grant.object
${newmgddbperms}/curatorial/procedure/GXD_loadGenoCacheAll_grant.object
${newmgddbperms}/curatorial/procedure/GXD_loadGenoCacheByGenotype_grant.object

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

exec GXD_loadGenoCacheAll
go

dump tran $DBNAME with truncate_only
go

quit

EOSQL

${newmgddbschema}/key/GXD_AlleleGenotype_create.object
${newmgddbschema}/key/GXD_Genotype_drop.object
${newmgddbschema}/key/GXD_Genotype_create.object
${newmgddbschema}/key/ALL_Allele_drop.object
${newmgddbschema}/key/ALL_Allele_create.object
${newmgddbschema}/key/MRK_Marker_drop.object
${newmgddbschema}/key/MRK_Marker_create.object
${newmgddbschema}/index/GXD_AlleleGenotype_create.object

date >> $LOG

