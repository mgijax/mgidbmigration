#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${MGD_DBSCHEMADIR}/index/ACC_Accession_drop.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

drop index ACC_Accession.idx_MGIType_Object_key
go

checkpoint
go

end

EOSQL

${MGD_DBSCHEMADIR}/index/ACC_Accession_create.object | tee -a $LOG

#${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_drop.object | tee -a $LOG
#${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_create.object | tee -a $LOG

#${MGD_DBSCHEMADIR}/view/GXD_Genotype_View_drop.object | tee -a $LOG
#${MGD_DBSCHEMADIR}/view/GXD_Genotype_View_create.object | tee -a $LOG

#${MGD_DBSCHEMADIR}/all_perms.csh | tee -a $LOG

date |tee -a $LOG

