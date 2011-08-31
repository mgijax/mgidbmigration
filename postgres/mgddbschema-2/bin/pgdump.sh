#!/bin/sh

#
# call pg_dump to dump this schema
#

cd `dirname $0` &. ./Configuration

cd ${MGDDATA}

rm -rf mgdradar.dump

pg_dump -Fc ${MGD_DBNAME} > mgdradar.dump

