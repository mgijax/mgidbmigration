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

echo "--- Delete MGI IDs ---"  | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0
/* Arl5a<tm1e(EUCOMM)Hmgu>  */
update ACC_Accession
set accID = 'MGI:4842132', prefixPart = 'MGI:', numericPart = 4842132
where _Accession_key = 787228497;

/* Cfap46<tm1a(EUCOMM)Hmgu>  */
update ACC_Accession
set accID = 'MGI:4435139', prefixPart = 'MGI:', numericPart = 4435139
where _Accession_key = 787228506;

/* Gpr35<tm1e(EUCOMM)Wtsi>  */
update ACC_Accession
set accID = 'MGI:4938582', prefixPart = 'MGI:', numericPart = 4938582
where _Accession_key = 787228517;

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
