#!/bin/csh -fx

#
# TR9560
#
#  remove GXD_LabelCoverage
#  remove GXD_ProbePrep._Coverage_key
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

drop index GXD_ProbePrep.idx_Coverage_key
go

alter table GXD_ProbePrep drop _Coverage_key
go

drop table GXD_LabelCoverage
go

quit

EOSQL

${MGD_DBSCHEMADIR}/trigger/GXD_ProbePrep_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object  | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/GXD_ProbePrep_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_ProbePrep_View_create.object | tee -a ${LOG}

${MGD_DBPERMSDIR}/public/table/GXD_ProbePrep_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/GXD_ProbePrep_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/procedure/GXD_duplicateAssay_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/GXD_ProbePrep_View_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}

