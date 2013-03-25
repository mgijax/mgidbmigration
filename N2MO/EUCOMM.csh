#!/bin/csh -fx

#
# Migration for EUCOMMTools -- 

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

#
# Update EUCOMM references
#

date | tee -a ${LOG}
echo "--- Update EUCOMM Reference titles ---" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
update BIB_Refs
set title = "Alleles produced for the EUCOMM and EUCOMMTools projects by the Wellcome Trust Sanger Institute"
where _Refs_key = 156938
go

update BIB_Refs
set title = "Alleles produced for the EUCOMM and EUCOMMTools projects by the Helmholtz Zentrum Muenchen GmbH (Hmgu)"
where _Refs_key = 158158
go

EOSQL
