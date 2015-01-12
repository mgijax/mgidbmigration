#!/bin/csh

#load_db.csh DEV1_MGI mgd_lec1 /backups/rohan/scrum-dog/mgd.backup

#bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} NOM_Marker

${MGD_DBSCHEMADIR}/index/NOM_Marker_drop.object
${MGD_DBSCHEMADIR}/table/NOM_Marker_truncate.object
bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} NOM_Marker
${MGD_DBSCHEMADIR}/index/NOM_Marker_create.object

