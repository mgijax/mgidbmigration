#!/bin/sh

# run against a 3.54 database from the dbutils/mgd/ directory which contains
# the 4.0 mgddbschema and mgddbperms products

# check that we can find both the schema and permissions directories

if [ ! -d mgddbschema ]; then
	echo "Cannot find mgddbschema directory"
	exit 1
fi

if [ ! -d mgddbperms ]; then
	echo "Cannot find mgddbperms directory"
	exit 1
fi

# create tables, keys, indexes, triggers, views, and
# stored procedures

cd mgddbschema/table
MGI_Statistic_create.object
MGI_StatisticSql_create.object
MGI_Measurement_create.object

cd ../key
MGI_Statistic_create.object
MGI_StatisticSql_create.object
MGI_Measurement_create.object

cd ../index
MGI_Statistic_create.object
MGI_StatisticSql_create.object
MGI_Measurement_create.object

cd ../trigger
MGI_Statistic_create.object

cd ../procedure
MGI_recordMeasurement_create.object
MGI_deletePrivateData_drop.object
MGI_deletePrivateData_create.object

cd ../view
MGI_Statistic_View_create.object

# grant permissions on tables, views, and stored procedures

cd ../../mgddbperms/public/table
MGI_Statistic_grant.object
MGI_StatisticSql_grant.object
MGI_Measurement_grant.object

cd ../view
MGI_Statistic_View_grant.object

cd ../procedure
MGI_recordMeasurement_grant.object
MGI_deletePrivateData_grant.object

# go back to start directory

cd ../..
echo "Finished migrating database to 4.0 schema"
