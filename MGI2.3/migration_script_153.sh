#!/bin/sh

# Migration script for schema changes (see tr153)
# Oct. 21, 1999: JCG

scripts=/opt/sybase/admin
path=/opt/sybase/bin

server=$1
database=$2

(cat /opt/sybase/admin/.mgd_dbo_password
cat << EOSQL
use $database
go
EOSQL
) | $path/isql -I/opt/sybase/interfaces -Umgd_dbo -S$server -D$database -i./migration_script_153.sql
/opt/sybase/admin/permissions/HMD.grant $server $database
#/opt/sybase/admin/views/views.sh $server $database
