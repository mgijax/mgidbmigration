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

alter table GXD_ProbePrep drop _Coverage_key
go

drop table GXD_LabelCoverage
go

quit

EOSQL

${MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_drop.object
${MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object 

${MGD_DBSCHEMADIR}/view/GXD_ProbePrep_View_drop.object
${MGD_DBSCHEMADIR}/view/GXD_ProbePrep_View_create.object

date | tee -a  ${LOG}

