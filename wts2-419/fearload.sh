#!/bin/sh

#
# This script is a wrapper around the process that loads 
# Feature Relationships
#
#
#     fearload.sh 
#

cd `dirname $0`/..
CONFIG_LOAD=${FEARLOAD}/fearload.config

cd `dirname $0`
LOG=${FEARLOAD}/fearload.log
rm -rf ${LOG}

USAGE='Usage: fearload.sh'
SCHEMA='mgd'

#
#  Verify the argument(s) to the shell script.
#
if [ $# -ne 0 ]
then
    echo ${USAGE} | tee -a ${LOG}
    exit 1
fi

#
# verify & source the configuration file
#

if [ ! -r ${CONFIG_LOAD} ]
then
    echo "Cannot read configuration file: ${CONFIG_LOAD}"
    exit 1
fi

. ${CONFIG_LOAD}

#
# Just a verification of where we are at
#

echo "MGD_DBSERVER: ${MGD_DBSERVER}"
echo "MGD_DBNAME: ${MGD_DBNAME}"

#
#  Source the DLA library functions.
#

if [ "${DLAJOBSTREAMFUNC}" != "" ]
then
    if [ -r ${DLAJOBSTREAMFUNC} ]
    then
        . ${DLAJOBSTREAMFUNC}
    else
        echo "Cannot source DLA functions script: ${DLAJOBSTREAMFUNC}" | tee -a ${LOG}
        exit 1
    fi
else
    echo "Environment variable DLAJOBSTREAMFUNC has not been defined." | tee -a ${LOG}
    exit 1
fi

#
# verify input file exists and is readable
#

if [ ! -r ${INPUT_FILE_DEFAULT} ]
then
    # set STAT for endJobStream.py
    STAT=1
    checkStatus ${STAT} "Cannot read from input file: ${INPUT_FILE_DEFAULT}"
fi

#
# createArchive including OUTPUTDIR, startLog, getConfigEnv
# sets "JOBKEY"
#

preload ${OUTPUTDIR}

#
# rm all files/dirs from OUTPUTDIR
#

cleanDir ${OUTPUTDIR}

#
# run the load
#
echo "" >> ${LOG_DIAG}
date >> ${LOG_DIAG}
echo "Run fearload.py"  | tee -a ${LOG_DIAG}
${PYTHON} ${FEARLOAD}/bin/fearload.py  
STAT=$?
checkStatus ${STAT} "${FEARLOAD}/bin/fearload.py"

#
# Do Deletes
#
# check for empty file
# get password from password file
# execute sql file
echo "PGPASSFILE: ${PGPASSFILE}"
if [ -s "${DELETE_SQL}" ]
then
    echo "" >> ${LOG_DIAG}
    date >> ${LOG_DIAG}
    echo 'Deleting Relationships'  >> ${LOG_DIAG}
    #isql -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P`cat ${MGD_DBPASSWORDFILE}` -w300 -i ${DELETE_SQL} >> ${LOG_DIAG}
    psql -U${MGD_DBUSER} -h${MGD_DBSERVER} -d${MGD_DBNAME} -f ${DELETE_SQL} -e >> ${LOG_DIAG} 2>&1

fi

#
# Do BCP
#

# BCP delimiters
COLDELIM="\t"
LINEDELIM="\n"

TABLE=MGI_Relationship

if [ -s "${OUTPUTDIR}/${TABLE}.bcp" ]
then
    echo "" >> ${LOG_DIAG}
    date >> ${LOG_DIAG}
    echo 'BCP in Relationships'  >> ${LOG_DIAG}


    # Drop indexes
    ${MGD_DBSCHEMADIR}/index/${TABLE}_drop.object >> ${LOG_DIAG}

    # BCP new data

    ${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${TABLE} ${OUTPUTDIR} ${TABLE}.bcp ${COLDELIM} ${LINEDELIM} ${SCHEMA} >> ${LOG_DIAG}

    # Create indexes
    ${MGD_DBSCHEMADIR}/index/${TABLE}_create.object >> ${LOG_DIAG}
fi

TABLE=MGI_Relationship_Property
if [ -s "${OUTPUTDIR}/${TABLE}.bcp" ]
then
    # Drop indexes
    ${MGD_DBSCHEMADIR}/index/${TABLE}_drop.object >> ${LOG_DIAG}

    # BCP new data
    ${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${TABLE} ${OUTPUTDIR} ${TABLE}.bcp ${COLDELIM} ${LINEDELIM} ${SCHEMA} >> ${LOG_DIAG}

    # Create indexes
    ${MGD_DBSCHEMADIR}/index/${TABLE}_create.object >> ${LOG_DIAG}
fi

TABLE=MGI_Note
if [ -s "${OUTPUTDIR}/${TABLE}.bcp" ]
then
    # Drop indexes
    ${MGD_DBSCHEMADIR}/index/${TABLE}_drop.object >> ${LOG_DIAG}

    # BCP new data
    ${PG_DBUTILS}/bin/bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${TABLE} ${OUTPUTDIR} ${TABLE}.bcp ${COLDELIM} ${LINEDELIM} ${SCHEMA} >> ${LOG_DIAG}

    # Create indexes
    ${MGD_DBSCHEMADIR}/index/${TABLE}_create.object >> ${LOG_DIAG}
fi

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 >> ${LOG_DIAG}
select setval('mgi_relationship_seq', (select max(_Relationship_key) from MGI_Relationship));
select setval('mgi_relationship_property_seq', (select max(_RelationshipProperty_key) from MGI_Relationship_Property));
select setval('mgi_note_seq', (select max(_Note_key) from MGI_Note));
EOSQL

# run postload cleanup and email logs

shutDown

