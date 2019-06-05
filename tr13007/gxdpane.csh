#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--select _imagepane_key, panelabel from img_imagepane where panelabel like ' %';

--select _imagepane_key, panelabel, regexp_replace(panelabel, '^ ', '_', 'g')
--from img_imagepane
--where panelabel like ' %'
--;

update img_imagepane
set panelabel = regexp_replace(panelabel, '^ ', '_', 'g')
where panelabel like ' %'
;

EOSQL

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#select _imagepane_key, panelabel from img_imagepane where panelabel like '_%';
#EOSQL

date |tee -a $LOG

