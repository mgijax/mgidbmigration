#!/bin/sh

#
# Migration for MGI 2.7
#

SYBASE=/opt/sybase
PYTHONPATH=/usr/local/mgi/lib/python
PATH=$PATH:.:/usr/bin:$SYBASE/bin
MIGRATION=`dirname $0`

cd $MIGRATION

export SYBASE
export PYTHONPATH
export PATH
export MIGRATION

DSQUERY=$1
MGD=$2
NOMEN=$3
STRAINS=$4

LOG_FILE=MGI.log
PROD_DATABASE=mgd

DBO_SCRIPTS=$SYBASE/admin
DB_PWD_FILE=$DBO_SCRIPTS/.mgd_dbo_password

export DSQUERY
export MGD
export NOMEN
export STRAINS
export LOG_FILE


rm -rf $LOG_FILE
touch  $LOG_FILE
 
echo "$0 Script Starting..."
echo "***************************" >> $LOG_FILE 2>&1
echo "******$0 Script Starting..." >> $LOG_FILE 2>&1
echo "***************************" >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1

echo "Database Server:  $DSQUERY"
echo "MGD Database:     $MGD"    
echo "Nomen Database:   $NOMEN"  
echo "Strains Database: $STRAINS"
echo "Database Server:  $DSQUERY" >> $LOG_FILE 2>&1
echo "MGD Database:     $MGD"     >> $LOG_FILE 2>&1
echo "Nomen Database:   $NOMEN"   >> $LOG_FILE 2>&1
echo "Strains Database: $STRAINS" >> $LOG_FILE 2>&1
 
SCRIPTS=/usr/local/mgi/dbutils/dbschema-MGI2.7

#
# For integration testing purposes...comment out before production load
#
echo "Databases Loading ..."
echo "*************************" >> $LOG_FILE 2>&1
echo "*****Databases Loading..." >> $LOG_FILE 2>&1
echo "*************************" >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1

if test "$MGD" != "$PROD_DATABASE"
then
   echo "Development Database - Loading $MGD..."
   $SYBASE/admin/utilities/load_devdb.sh $MGD     mgd.backup     mgd_dbo >> $LOG_FILE 2>&1
   echo "Development Database - Loading $NOMEN..."
   $SYBASE/admin/utilities/load_devdb.sh $NOMEN   nomen.backup   mgd_dbo >> $LOG_FILE 2>&1
   cat $DB_PWD_FILE | $SYBASE/admin/utilities/nomen_set_perms_dev $DSQUERY $NOMEN mgd_dbo >> $LOG_FILE 2>&1
   echo "Development Database - Loading $STRAINS..."
   $SYBASE/admin/utilities/load_devdb.sh $STRAINS strains.backup mgd_dbo >> $LOG_FILE 2>&1
   cat $DB_PWD_FILE | $SYBASE/admin/utilities/strains_set_perms_dev $DSQUERY $STRAINS mgd_dbo >> $LOG_FILE 2>&1
else
   echo "Production Database - Not Loading..."
fi

echo "Data Migration Running..."
echo "******************************" >> $LOG_FILE 2>&1
echo "*****Data Migration Running..." >> $LOG_FILE 2>&1
echo "******************************" >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1
$MIGRATION/tr2217References.sql $DSQUERY $MGD >> $LOG_FILE 2>&1
$MIGRATION/tr2217Notes.sql      $DSQUERY $MGD >> $LOG_FILE 2>&1
$MIGRATION/tr2217Allele.sql     $DSQUERY $MGD >> $LOG_FILE 2>&1
$MIGRATION/tr2237.sql           $DSQUERY $MGD >> $LOG_FILE 2>&1

#
# Re-run all triggers, sps, views....
#
echo "Trigger, View, and Stored Proc Scripts Running..."
echo "******************************************************" >> $LOG_FILE 2>&1
echo "*****Trigger, View, and Stored Proc Scripts Running..." >> $LOG_FILE 2>&1
echo "******************************************************" >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1
$SCRIPTS/triggers/mgd/triggers.sh         $DSQUERY $MGD >> $LOG_FILE 2>&1
$SCRIPTS/views/mgd/views.sh               $DSQUERY $MGD >> $LOG_FILE 2>&1
$SCRIPTS/procedures/mgd/procedures.sh     $DSQUERY $MGD >> $LOG_FILE 2>&1

$SCRIPTS/triggers/nomen/triggers.sh       $DSQUERY $NOMEN $MGD >> $LOG_FILE 2>&1
$SCRIPTS/views/nomen/views.sh             $DSQUERY $NOMEN $MGD >> $LOG_FILE 2>&1
$SCRIPTS/procedures/nomen/procedures.sh   $DSQUERY $NOMEN $MGD >> $LOG_FILE 2>&1

$SCRIPTS/triggers/strains/triggers.sh     $DSQUERY $STRAINS $MGD >> $LOG_FILE 2>&1
$SCRIPTS/views/strains/views.sh           $DSQUERY $STRAINS $MGD >> $LOG_FILE 2>&1
$SCRIPTS/procedures/strains/procedures.sh $DSQUERY $STRAINS $MGD >> $LOG_FILE 2>&1

#TAKE OUT!!! Only for Development
echo "addTestAlleleSet.sql Running..."
echo "addTestAlleleSet.sql Running..." >> $LOG_FILE 2>&1
if test "$MGD" != "$PROD_DATABASE"
then
   echo "Test Database - Running addTestAlleleSet.sql..."
   echo "Test Database - Running addTestAlleleSet.sql..." >> $LOG_FILE 2>&1
   $MIGRATION/addTestAlleleSet.sql $DSQUERY $MGD >> $LOG_FILE 2>&1
else
   echo "Production Database - Not running addTestAlleleSet.sql..."
fi

echo "MGI DB Info Updating..."
echo "****************************" >> $LOG_FILE 2>&1
echo "*****MGI DB Info Updating..." >> $LOG_FILE 2>&1
echo "****************************" >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1
$MIGRATION/updateMGI.sql $DSQUERY $MGD $NOMEN $STRAINS "MGI 2.7" >> $LOG_FILE 2>&1

#TAKE OUT!!! Only for Development
echo "mrkref.sh running..."
echo "****************************" >> $LOG_FILE 2>&1
echo "*****mrkref.sh running..."    >> $LOG_FILE 2>&1
echo "****************************" >> $LOG_FILE 2>&1
if test "$MGD" != "$PROD_DATABASE"
then
   echo "Test Database - Running mrkref.sh..."
   echo "Test Database - Running mrkref.sh..." >> $LOG_FILE 2>&1
   /usr/local/mgi/dbutils/mrkrefload/mrkref.sh >> $LOG_FILE 2>&1
   cd `dirname %0`
else
   echo "Production Database - Not Running mrkref.sh..."
   echo "Production Database - Not Running mrkref.sh..." >> $LOG_FILE 2>&1
fi

echo "$0 Script Completed..."
echo "***************************" >> $LOG_FILE 2>&1
echo "*****$0 Script Completed..." >> $LOG_FILE 2>&1
echo "***************************" >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1
