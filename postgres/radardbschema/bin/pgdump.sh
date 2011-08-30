#!/bin/sh

#
# call pg_dump to dump this schema
#

cd `dirname $0` &. ./Configuration

cd ${RADARDATA}

rm -rf radar.dump

pg_dump -Fc -n radar ${RADAR_DBNAME} > radar.dump

