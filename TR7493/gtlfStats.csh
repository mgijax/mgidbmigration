#!/bin/csh

#source /usr/local/mgi/live/mgiconfig/master.config.csh
#source /home/mhall/devwi/mgiconfig/master.config.csh

source ../Configuration

./gtlfStats.py ${MGD_DBUSER} ${MGD_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} ${SNP_DBNAME}
