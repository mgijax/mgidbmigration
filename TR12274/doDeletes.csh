#!/bin/csh -fx

#
# Migration for TAL TR12274  These alleles have separate _allele_keys, but the same allele symbol.
#
# delete these alleles and cellLines:
# IDs | Key | symbol | MCL Keys
# MGI:4842132, MGI:5698064 | 623466, 863806 | Arl5a<tm1e(EUCOMM)Hmgu> | HEPD0669_4_F09, HEPD0917_6_H03, HEPD0917_6_E02, HEPD0917_6_D01, HEPD0917_6_A03, HEPD0917_6_A02 | 713991,  1005410, 1005411, 1005412, 1005413, 1005414

# MGI:5308327, MGI:4435139 | 610260, 816583 | Cfap46<tm1a(EUCOMM)Hmgu> | HEPD0584_1_B03, HEPD0584_1_D04, HEPD0584_1_G03, HEPD0584_1_A03, HEPD0584_1_B04, HEPD0584_1_G01, HEPD0724_3_F02, HEPD0724_3_D04, HEPD0724_3_D03, HEPD0724_3_C02, HEPD0724_3_B04 | 643320, 644739, 648410, 651202, 653136, 655911, 973791, 973792, 973793, 973794, 973795

# MGI:4938582, MGI:5563209 | 842311, 842356 | Gpr35<tm1e(EUCOMM)Wtsi> | EPD0911_1_G03, EPD0911_1_E02, EPD0911_1_E01, EPD0911_1_C04, EPD0911_1_C01, EPD0911_1_B02, EPD0911_1_B01, EPD0717_2_E04, EPD0717_2_A03 | 1012247, 1012248, 1012240, 1012241, 1012242, 1012243, 1012244, 1012245, 1012246 

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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

delete from ALL_Allele_CellLine
where _MutantCellLine_key in (713991, 1005410, 1005411, 1005412, 1005413, 1005414, 643320, 644739, 648410, 651202, 653136, 655911, 973791, 973792, 973793, 973794, 973795, 1012247, 1012248, 1012240, 1012241, 1012242, 1012243, 1012244, 1012245, 1012246);


delete from ALL_Allele
where _Allele_key in ( 623466, 863806, 610260, 816583, 842311, 842356 );

delete from ALL_CellLine
where _CellLine_key  in (713991, 1005410, 1005411, 1005412, 1005413, 1005414, 643320, 644739, 648410, 651202, 653136, 655911, 973791, 973792, 973793, 973794, 973795, 1012247, 1012248, 1012240, 1012241, 1012242, 1012243, 1012244, 1012245, 1012246);

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
