#!/bin/csh -f

#
# wts2-1155/fl2-491/GOC:  littriageload/merge littriage_goa/littriage_noctua folders to littriage_go
#
# littriageload
# autolittriage : comments changed from littriage_goa -> littriage_go
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

date
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0
update MGI_User set login = 'littriage_go', name = 'littriage_go' where _user_key = 1575;
update ACC_Accession set _createdby_key = 1575, _modifiedby_key = 1575 where _createdby_key = 1623;
update BIB_Refs set _createdby_key = 1575, _modifiedby_key = 1575 where _createdby_key = 1623;
update BIB_Workflow_Status set _createdby_key = 1575, _modifiedby_key = 1575 where _createdby_key = 1623;
update BIB_Workflow_Relevance set _createdby_key = 1575, _modifiedby_key = 1575 where _createdby_key = 1623;
update BIB_Workflow_Data set _createdby_key = 1575, _modifiedby_key = 1575 where _createdby_key = 1623;
delete from MGI_User where _user_key = 1623;
select * from mgi_user where _user_key in (1575,1623);
EOSQL

#cd /mgi/all/Triage/PDF_files/Alpha_New_New
#rm -rf littriage_goa
#mv -f littriage_noctua littriage_go
#cd /mgi/all/Triage/PDF_files/_New_Newcurent
#rm -rf littriage_goa
#mv -f littriage_noctua littriage_go
cd ${DATALOADSOUTPUT}/mgi/littriageload/input
rm -rf littriage_goa littriage_noctua
mkdir -p littriage_go
cd ${DBUTILS}/mgidbmigration/wts2-1155
cp littriage_go/* ${DATALOADSOUTPUT}/mgi/littriageload/input/littriage_go
${LITTRIAGELOAD}/bin/littriageload.sh

date 

