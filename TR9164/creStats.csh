#!/bin/csh

# Please note that if this isn't run versus production/test you will get two
# errors when running the statistics.  The will both be in reference to stats
# for the snp database.  These errors are normal and should be ignored.

source ../Configuration

./creStats.py ${MGD_DBUSER} ${MGD_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} ${SNP_DBNAME}
