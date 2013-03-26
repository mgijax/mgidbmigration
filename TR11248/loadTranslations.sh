#!/bin/sh 
#
#   $Header
#   $Name
# loadTranslations.sh
##############################################################################
#
# Purpose: Load SNP translations
#
Usage="loadTranslations.sh [-f -v]"
# where:
#       -f run the fxnClass translationload
#       -v run the varClass translationload
#  Env Vars:  None
#
#  Inputs:
#
#       - Configuration files
#       - Configured translation input file
#  Outputs:
#       - logs
#       - bcp files
#       - MGI_Translation and MGI_TranslationType records in a database
#  Exit Codes:
#       0 = Successful completion
#       1 = An error occurred
#       2 = Usage error occured
#  Assumes:
#        - DLA standards are being followed for environment variable name
#        - all config files are in the same directory as this script
#  Implementation:
#
#  Notes:  None
#
###########################################################################

cd `dirname $0`/..
LOG=`pwd`/loadTranslations.log
rm -f ${LOG}
date | tee -a ${LOG}

#
#  Verify the argument(s) to the shell script.
#
doFxn=yes

set -- `getopt fv $*`
if [ $? != 0 ]
then
    echo ${Usage}
    exit 2
fi

for i in $*
do
    case $i in
        -f) doFxn=yes; shift;;
        --) shift; break;;
    esac
done

#
#  Establish the configuration file names
#
CONFIG_LOAD=`pwd`/dbsnpload.config
CONFIG_FXNCLASS=`pwd`/fxnClassTrans.config

#
#  Make sure the configuration files are readable.
#
if [ ! -r ${CONFIG_LOAD} ]
then
    echo "Cannot read configuration file: ${CONFIG_LOAD}" | tee -a ${LOG}
    exit 1
fi

if [ ! -r ${CONFIG_FXNCLASS} ]
then
    echo "Cannot read configuration file: ${CONFIG_FXNCLASS}" | tee -a ${LOG}
    exit 1
fi

#
# Source load configuration file
#
. ${CONFIG_LOAD}

# create translation output directory, if necessary
TRANS_OUTPUTDIR=${OUTPUTDIR}/translationload

if [ ! -d ${TRANS_OUTPUTDIR} ]
then
  echo "...creating translation output directory ${TRANS_OUTPUTDIR}"
  mkdir -p ${TRANS_OUTPUTDIR}
fi

checkstatus ()
{

    if [ $1 -ne 0 ]
    then
        echo "$2 Failed. Return status: $1" | tee -a  ${LOADTRANSLOG}
        exit 1
    fi
    echo "$2 completed successfully" | tee -a  ${LOADTRANSLOG}

}

#
# main
#


if [ ${doFxn} = "yes" ]
then
    echo "Running function class translationload " | tee -a $LOADTRANSLOG
    ${TRANSLATIONLOAD}/translationload.csh ${CONFIG_FXNCLASS}
    STAT=$?
    msg="fxnClass translation load "
    checkstatus  ${STAT} "${msg}"
fi
