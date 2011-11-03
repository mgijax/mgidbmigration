#!/usr/local/bin/python

#
# create .txt file of:
#
#	MGI_Table.table_name
#	MGI_Tables.description
#

import sys 
import os
import string
import db
import mgi_utils

#
# Main
#

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

db.useOneConnection(1)

fp = open('comments.txt', 'w')

results = db.sql('select table_name, description from MGI_Tables', 'auto')

for r in results:

    tableName = r['table_name']
    description = r['description']

    if description != None:
    	description = string.replace(description, "'", "''")

    fp.write("COMMENT ON TABLE mgd." + \
	tableName + \
	" IS '" + \
	mgi_utils.prvalue(description) + \
	"';\n")

results = db.sql('select table_name, column_name, description from MGI_Columns', 'auto')

for r in results:

    tableName = r['table_name']
    columnName = r['column_name']
    description = r['description']

    if description != None:
    	description = string.replace(description, "'", "''")
    	description = string.replace(description, "offset", "cmOffset")

    fp.write("COMMENT ON COLUMN "+
	tableName + "." + \
	columnName + \
	" IS '" + \
	mgi_utils.prvalue(description) + \
	"';\n")

fp.close()
db.useOneConnection(0)

