#!/bin/csh -f -x

#
# To migrate to new database segments we do this:
#
#	1.  BCP out existing database table.
#
#	2.  Drop all existing tables in the JSAM database 
#	    created during our previous migration.
#	
#	2.  Create the old schema tables
#
#	3.  Load the old schema tables from the BCP files from step 1.
#
#	4.  Create indexes, views, stored procedures, triggers on the tables.
#
#	5.  Bind rules and defaults on the tables.
#
#

cd `dirname $0` && source ./Configuration

setenv LOG	`pwd`/$0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo 'Start Data Load...' | tee -a ${LOG}

#
# Create a script for truncating the database log
#

cat > ${WORKDIR}/truncateLog.sql << EOSQL
dump transaction ${DBNAME} with truncate_only
go
EOSQL

echo 'Load Empty Database...' | tee -a ${LOG}
./load_dev2db.csh dev2mgdempty.backup | tee -a ${LOG}
date | tee -a ${LOG}

echo 'Create data files...' | tee -a ${LOG}
#rm -rf ${DATADIR}/*
#bcpout.csh ${existingmgddbschema} all ${DATADIR} | tee -a ${LOG}
#date | tee -a ${LOG}

echo 'Creating tables...' | tee -a ${LOG}
date | tee -a ${LOG}
${oldmgddbschema}/table/table_create.csh | tee -a ${LOG}

echo 'Loading tables...' | tee -a ${LOG}
date | tee -a ${LOG}
foreach i (${DATADIR}/*.bcp)
set table=`basename $i .bcp`
cat ${DBPASSWORDFILE} | bcp ${DBNAME}..$table in $i -e errors -S${DBSERVER} -U${DBUSER} -c -t"&=&" -r"#=#\n" | tee -a ${LOG}
cat ${DBPASSWORDFILE} | isql -S${DBSERVER} -U${DBUSER} -i ${WORKDIR}/truncateLog.sql | tee -a ${LOG}
end

echo 'Binding rules...' | tee -a ${LOG}
date | tee -a ${LOG}
${oldmgddbschema}/rule/rule_bind.csh | tee -a ${LOG}

echo 'Binding defaults...' | tee -a ${LOG}
date | tee -a ${LOG}
${oldmgddbschema}/default/default_bind.csh | tee -a ${LOG}

echo 'Indexing tables...' | tee -a ${LOG}
date | tee -a ${LOG}
${oldmgddbschema}/index/index_create.csh | tee -a ${LOG}

echo 'Creating Views...' | tee -a ${LOG}
date | tee -a ${LOG}
${oldmgddbschema}/view/view_create.csh | tee -a ${LOG}

echo 'Creating Stored Procedures...' | tee -a ${LOG}
date | tee -a ${LOG}
${oldmgddbschema}/procedure/procedure_create.csh | tee -a ${LOG}

echo 'Creating Triggers...' | tee -a ${LOG}
date | tee -a ${LOG}
${oldmgddbschema}/trigger/trigger_create.csh | tee -a ${LOG}

echo 'Making a binary dump...' | tee -a ${LOG}
./dump_dev2db.csh dev2mgd.backup

echo 'End Data Load.' | tee -a ${LOG}
date | tee -a ${LOG}

