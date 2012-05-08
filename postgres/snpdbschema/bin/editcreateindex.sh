#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# copy snpdbschema/index/*_create.object to postgres directory
#
cd ${POSTGRESINDEX}
cp ${SNPBE_DBSCHEMADIR}/index/${findObject} .

for i in ${findObject}
do

t=`basename $i _create.object`

ed $i <<END
g/csh -f -x/s//sh/g
g/ source/s// ./g
g/nonclustered /s///g
g/clustered /s///g
g/idx/s//${t}/g
g/ on seg9/s//;/g
g/ on seg10/s//;/g
g/ on seg1/s//;/g
g/ on /s// on snp./g
g/^go/s///g
/cat
d
.
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \${SNPBE_DBSERVER} \${SNPBE_DBNAME} \$0

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

