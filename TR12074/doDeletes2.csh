#!/bin/csh -fx

#
# Migration for TAL TR12074
# (part 1 - optionally load dev database. etc)
#
# delete these cellLines that were not deleted in doDeletes.csh
#Row #	cellline	_cellline_key
#1	EPD0284_3_A05	574309
#2	EPD0284_3_A06	572496
#3	EPD0284_3_A08	568398
#4	EPD0284_3_B06	576676
#5	EPD0284_3_D05	566065
#6	EPD0284_3_D06	563262
#7	EPD0284_3_D07	570918
#8	EPD0284_3_E08	569117
#9	EPD0284_3_F06	575780
#10	EPD0284_3_F08	564773
#11	EPD0284_3_H05	572927
#12	EPD0284_3_H08	566861
#13	EPD0567_2_D09	683757
#14	EPD0567_2_E09	675124
#15	EPD0567_2_E10	685359
#16	EPD0567_2_E11	683480
#17	EPD0567_2_F09	683767
#18	EPD0567_2_F10	685323
#19	EPD0567_2_F11	676108
#20	EPD0567_2_F12	683510
#21	EPD0567_2_H11	675316
#22	EPD0652_1_A09	708042
#23	EPD0652_1_E10	709434
#24	EPD0652_1_G09	709523
#25	EPD0652_1_G10	708011
#26	EPD0652_1_H11	709477
#27	EPD0652_1_H12	709390
#28	EPD0739_2_A10	792690
#29	EPD0739_2_F10	792812
#30	EPD0739_2_H12	760854
#31	HEPD0623_4_D10	1003061
#32	HEPD0623_4_G09	684000
#33	HEPD0623_4_H09	684190 

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

delete from ALL_CellLine
where _CellLine_key in (574309,
572496,
568398,
576676,
566065,
563262,
570918,
569117,
575780,
564773,
572927,
566861,
683757,
675124,
685359,
683480,
683767,
685323,
676108,
683510,
675316,
708042,
709434,
709523,
708011,
709477,
709390,
792690,
792812,
760854,
1003061,
684000,
684190);

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
