#!/bin/csh

source /usr/local/mgi/live/mgiconfig/master.config.csh

./creStats.py ${MGD_DBUSER} ${MGD_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} ${SNP_DBNAME}
