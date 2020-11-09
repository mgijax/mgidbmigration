#!/bin/sh 

#
# quick and dirty script thatcatenates /data/mrkcoord/current files into one 
# file, QC's that file, then publishes that file
#

###----------------------###
###--- initialization ---###
###----------------------###

#  If the MGICONFIG environment variable does not have a local override,
#  use the default "live" settings.
#
if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

echo ${MGICONFIG}
. ${MGICONFIG}/master.config.sh
echo "MRKCOORDLOAD: $MRKCOORDLOAD"

# set up a log file for the shell script in case there is an error
#  during configuration and initialization.
#
cd `dirname $0`
LOG=`pwd`/mrkcoordload_prep.log
rm -f ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting mrkcoordload_prep.csh' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

currentdir=/data/mrkcoord/current/
qcdir=/data/mrkcoord/current_qc/
catfile=/data/mrkcoord/current_qc/mrkcoordload_catenated.txt

# remove all old reports and the catenated file
cd "$qcdir"
rm *

first=1

for i in `ls $currentdir*`
do
    echo $i
    if [ $first -eq 1 ]
    then
        cat $i > "$catfile"
        first=0
    else
        tail -n +2 $i >> "$catfile"
    fi
done

date | tee -a ${LOG}
echo "${MRKCOORDLOAD}/bin/runMrkCoordQC"
echo $catfile

${MRKCOORDLOAD}/bin/runMrkCoordQC $catfile
STAT=$?
echo "STAT: $STAT"
if [ ${STAT} -eq 1 ]
then
    exit 1
else 
    echo "${MRKCOORDLOAD}/bin/publishCoordFile"
    ${MRKCOORDLOAD}/bin/publishCoordFile $catfile
    if [ ${STAT} -eq 1 ]
    then
        exit 1
    fi

fi

echo '--- finished mrkcoordload_prep.csh' | tee -a ${LOG}
