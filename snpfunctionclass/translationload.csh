#!/bin/csh -f

#
# Wrapper script to create & load new translations
#
# Usage:  translationload.csh
#

setenv CONFIGFILE $1

source ${CONFIGFILE}

rm -rf ${TRANSLOG}
touch ${TRANSLOG}

date >& ${TRANSLOG}

# print the environment to the log
env | sort >>& ${TRANSLOG}
echo "invoking translationload.py"

${PYTHON} ${TRANSLATIONLOAD}/translationload.py >>& ${TRANSLOG}

date >>& ${TRANSLOG}

