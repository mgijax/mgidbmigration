#!/bin/csh -f

#
# Template
#

setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

checkpoint
go

end

EOSQL

#${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_drop.object | tee -a $LOG
#${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/view/PRB_AccRef_View_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/PRB_AccRef_View_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/PRB_AccRefNoSeq_View_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/PRB_AccRefNoSeq_View_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/PRB_Probe_View_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/PRB_Probe_View_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a $LOG

date |tee -a $LOG

