#!/bin/csh -fx

#
# add 'label' to MGI_SetMember
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

INSERT INTO MGI_SetMember
SELECT o._SetMember_key, o._Set_key, o._Object_key, null, o.sequenceNum,
	o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
FROM MGI_SetMember_old o
;

select count(*) from MGI_SetMember_old;
select count(*) from MGI_SetMember;

DROP TABLE MGI_SetMember_old;

EOSQL
date | tee -a ${LOG}

