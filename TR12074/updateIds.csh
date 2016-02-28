#!/bin/csh -fx

#
# Migration for TAL TR12074
# (part 1 - optionally load dev database. etc)
#
# delete these alleles and cellLines:
# ID          Key        symbol			   MCLs  	        Key
# MGI:4455496 615090     Dsc2<tm1a(KOMP)Wtsi> 	   EPD0567_2_H12 	675705
# MGI:4456717 615974     Cdc14a<tm1a(EUCOMM)Hmgu>  HEPD0647_2_C11	1015174
# MGI:4948619 640323     Nt5c1b<tm1a(KOMP)Wtsi>    EPD0739_2_C12	760816
# MGI:4364141 572080	 Sel1l<tm1a(KOMP)Wtsi>	   EPD0284_3_D08	573061
# MGI:4841035 622369	 Spink14<tm1a(KOMP)Wtsi>   EPD0652_1_D10	710953
###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${PG_DBSERVER}"
echo "Database: ${PG_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}


cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

/*  Dsc2<tm1a(KOMP)Wtsi> */
update ACC_Accession
set accID = 'MGI:4455496', prefixPart = 'MGI:', numericPart = 4455496
where _Accession_key = 787228481;

/* Cdc14a<tm1a(EUCOMM)Hmgu> */
update ACC_Accession
set accID = 'MGI:4456717', prefixPart = 'MGI:', numericPart = 4456717
where _Accession_key = 787228503;

/* Nt5c1b<tm1a(KOMP)Wtsi> */
update ACC_Accession
set accID = 'MGI:4948619', prefixPart = 'MGI:', numericPart = 4948619
where _Accession_key = 787228487;

/* Sel1l<tm1a(KOMP)Wtsi> */
update ACC_Accession
set accID = 'MGI:4364141', prefixPart = 'MGI:', numericPart = 4364141
where _Accession_key = 787228484;

/* Spink14<tm1a(KOMP)Wtsi> */
update ACC_Accession
set accID = 'MGI:4841035', prefixPart = 'MGI:', numericPart = 4841035
where _Accession_key = 787228490;

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
