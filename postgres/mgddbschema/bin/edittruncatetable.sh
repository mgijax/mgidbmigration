#!/bin/sh

cd `dirname $0` && . ../Configuration

#
# edit "truncate" tables from sybase to postgres 
#

#
# copy mgddbschema/table/*_truncate.object to postgres directory
#
cd ${POSTGRESTABLE}
cp ${MGD_DBSCHEMADIR}/table/*truncate.object .

#
# convert each mgd-format table script to a postgres script
#

for i in *truncate.object
do

ed $i <<END
g/csh -f -x/s//sh/g
g/ source/s// ./g
g/truncate table /s//truncate table mgd./g
g/partition/d
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${MGD_DBSERVER} \${MGD_DBNAME} \$0

.
/^use
d
d
/go
d
a
;
.
/checkpoint
;d
a
EOSQL
.
w
q
END

done

