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

${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE BIB_Refs ALTER COLUMN _primary TYPE text;
ALTER TABLE BIB_Refs ALTER COLUMN journal TYPE text;
ALTER TABLE BIB_Refs ALTER COLUMN vol TYPE text;
ALTER TABLE BIB_Refs ALTER COLUMN issue TYPE text;
ALTER TABLE BIB_Refs ALTER COLUMN date TYPE text;
ALTER TABLE BIB_Refs ALTER COLUMN pgs TYPE text;
ALTER TABLE BIB_Books ALTER COLUMN book_au TYPE text;
ALTER TABLE BIB_Books ALTER COLUMN book_title TYPE text;
ALTER TABLE BIB_Books ALTER COLUMN place TYPE text;
ALTER TABLE BIB_Books ALTER COLUMN publisher TYPE text;
ALTER TABLE BIB_Books ALTER COLUMN series_ed TYPE text;
ALTER TABLE BIB_Citation_Cache ALTER COLUMN reviewStatus TYPE text;
ALTER TABLE BIB_Citation_Cache ALTER COLUMN journal TYPE text;
ALTER TABLE BIB_DataSet ALTER COLUMN abbreviation TYPE text;
ALTER TABLE BIB_ReviewStatus ALTER COLUMN name TYPE text;

ALTER TABLE CRS_Cross ALTER COLUMN type TYPE text;
ALTER TABLE CRS_Cross ALTER COLUMN abbrevHO TYPE text;
ALTER TABLE CRS_Cross ALTER COLUMN abbrevHT TYPE text;
ALTER TABLE CRS_Cross ALTER COLUMN whoseCross TYPE text;
ALTER TABLE CRS_Matrix ALTER COLUMN otherSymbol TYPE text;
ALTER TABLE CRS_Progeny ALTER COLUMN name TYPE text;

ALTER TABLE RI_RISet ALTER COLUMN designation TYPE text;
ALTER TABLE RI_RISet ALTER COLUMN abbrev1 TYPE text;
ALTER TABLE RI_RISet ALTER COLUMN abbrev2 TYPE text;

ALTER TABLE WKS_Rosetta ALTER COLUMN wks_markerSymbol TYPE text;
ALTER TABLE WKS_Rosetta ALTER COLUMN wks_markerURL TYPE text;

EOSQL

${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG

date |tee -a $LOG

