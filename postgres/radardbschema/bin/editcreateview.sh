#!/bin/sh

#
# create 'view' scripts
#

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# edit "create" views from sybase to postgres
#

#
# copy mgddbschema/view/*_create.object to postgres directory
#
cd ${POSTGRESVIEW}
cp ${RADAR_DBSCHEMADIR}/view/${findObject} .

#
# convert each mgd-format view script to a postgres script
#

for i in ${findObject}
do

ed $i <<END
g/csh -f -x/s//sh/g
g/& source/s//./g
g/create view /s//create view mgd./g
g/^go/s///g
g/active = 1/s//active = true/g
g/private = 1/s//private = true/g
g/private = 0/s//private = false/g
g/preferred = 1/s//preferred = true/g
g/preferred = 0/s//preferred = false/g
g/preferred = 1/s//preferred = true/g
g/isObsolete = 1/s//isObsolete = true/g
g/isObsolete = 0/s//isObsolete = false/g
g/isMutant = 1/s//isMutant = true/g
g/isMutant = 0/s//isMutant = false/g
g/isNeverUsed = 1/s//isNeverUsed = true/g
g/isNeverUsed = 0/s//isNeverUsed = false/g
g/isReviewArticle = 1/s//isReviewArticle = true/g
g/isReviewArticle = 0/s//isReviewArticle = false/g
g/\"03\/13\/2002\"/s//03\/13\/2002/g
g/offset/s//cmOffset/g
g/convert(varchar(5), t.stage)/s//cast(t.stage as varchar(5))/g
g/convert(varchar(30), a.accID)/s//cast(a.accID as varchar(30))/g
g/convert(varchar(10), r._Class_key)/s//cast( r._Class_key as varchar(10))/g
g/convert(varchar(5), tag)/s//cast(tag as varchar(5))/g
g/convert(char(10), h.event_date, 101)/s//cast(h.event_date as char(10))/g
g/convert(varchar(10), r._Class_key)/s//cast(r._Class_key as varchar(10))/g
g/convert(varchar(10), r._Refs_key)/s//cast(r._Refs_key as varchar(10))/g
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${RADAR_DBSERVER} \${RADAR_DBNAME} \$0

.
/^use
d
d
d
.
/^checkpoint
;d
.
a
;

EOSQL
.
w
q
END

done

