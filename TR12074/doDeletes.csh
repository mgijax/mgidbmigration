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

#
# load a production backup into mgd and radar
#

if ("${1}" == "dev") then
    echo "--- Loading new database into ${PG_DBSERVER}.${PG_DBNAME}.mgd" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh -a ${PG_DBSERVER} ${PG_DBNAME} mgd /bhmgidb01/dump/mgd.dump  | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${PG_DBSERVER}.${PG_DBNAME}.mgd" | tee -a ${LOG}
endif

if ("${1}" == "dev") then
    echo "--- Loading new database into ${PG_DBSERVER}.${PG_DBNAME}.radar" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh  ${PG_DBSERVER} ${PG_DBNAME} radar /bhmgidb01/dump/radar.dump | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${PG_DBSERVER}.${PG_DBNAME}.radar" | tee -a ${LOG}
endif

echo "--- Finished loading databases " | tee -a ${LOG}

echo "--- Delete Alleles and MCLs ---"  | tee -a ${LOG}
# ID          Key        symbol                    MCLs                 Key
# MGI:4455496 615090     Dsc2<tm1a(KOMP)Wtsi>      EPD0567_2_H12        675705
# MGI:4456717 615974     Cdc14a<tm1a(EUCOMM)Hmgu>  HEPD0647_2_C11       1015174
# MGI:4948619 640323     Nt5c1b<tm1a(KOMP)Wtsi>    EPD0739_2_C12        760816
# MGI:4364141 572080     Sel1l<tm1a(KOMP)Wtsi>     EPD0284_3_D08        573061
# MGI:4841035 622369     Spink14<tm1a(KOMP)Wtsi>   EPD0652_1_D10        710953

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

delete from ALL_Allele_CellLine
where _MutantCellLine_key in (675705, 1015174, 760816, 573061, 710953);

delete from ALL_CellLine
where _CellLine_key in (675705, 1015174, 760816, 573061, 710953);

delete from ALL_Allele
where _Allele_key in (615090, 615974, 640323, 572080, 622369);

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
