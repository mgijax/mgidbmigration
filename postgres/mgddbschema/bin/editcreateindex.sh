#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# copy mgddbschema/index/*_create.object to postgres directory
#
cd ${POSTGRESINDEX}
cp ${MGD_DBSCHEMADIR}/index/${findObject} .

for i in ${findObject}
do

t=`basename $i _create.object`

ed $i <<END
g/csh -f -x/s//sh/g
g/& source/s///g
g/nonclustered /s///g
g/clustered /s///g
g/idx/s//${t}/g
g/ on seg2/s//;/g
g/ on seg3/s//;/g
g/ on seg4/s//;/g
g/ on seg5/s//;/g
g/ on seg6/s//;/g
g/ on seg7/s//;/g
g/ on seg8/s//;/g
g/ on \${DBCLUSTIDXSEG}/s//;/g
g/on \${DBCLUSTIDXSEG}/s//;/g
g/ on \$DBCLUSTIDXSEG/s//;/g
g/ on \${DBNONCLUSTIDXSEG}/s//;/g
g/ on \$DBNONCLUSTIDXSEG/s//;/g
g/offset/s//mgdoffset/g
g/^go/s///g
/cat
d
.
a
psql -d \${MGD_DBNAME} <<EOSQL 2> \${LOGFILE_PG}/index/$i.log

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
EOSQL
.
w
q
END

done

