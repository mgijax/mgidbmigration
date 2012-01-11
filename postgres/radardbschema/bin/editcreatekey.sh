#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject1=$1_create.object
    findObject2=$1_drop.object
else
    findObject1=*_create.object
    findObject2=*_drop.object
fi

#
# edit "sp_primarykey" and "sp_foreignkey" from sybase to postgres
#

#
# copy radardbschema/key/*_create.object to postgres directory
# copy radardbschema/key/*_drop.object to postgres directory
#
cd ${POSTGRESKEY}
cp ${RADAR_DBSCHEMADIR}/key/${findObject1} .
cp ${RADAR_DBSCHEMADIR}/key/${findObject2} .

#
# convert each radar-format key script to a postgres script
#
# sp_primarykey MRK_Marker, _Marker_key
# to
# ALTER TABLE MRK_Marker ADD PRIMARY KEY (_Marker_key);
#
# sp_foreignkey ALL_Allele, MRK_Marker, _Marker_key
# to
# ALTER TABLE ALL_Allele 
#	ADD CONSTRAINT ALL_Allele_Marker_key_fkey 
#	FOREIGN KEY (_Marker_key) REFERENCES MRK_Marker ON DELETE CASCADE;
#
# add: );
# add: ) REFERENCE ${t} ON DELETE CASCADE;
#
# sp_dropkey foreign, ALL_Allele, MRK_Marker
# to
# ALTER TABLE ALL_Allele DROP CONSTRAINT xxxxx
#

for i in ${findObject1}
do

# master table name
t=`basename $i _create.object`

# primary key table name + key
pkey=`grep "sp_primarykey" ${i} | sed "s/sp_primarykey //g" | cut -f1,2 -d"," | sed "s/, /+/g"`

# foreign key table name + key
fkey=`grep "sp_foreignkey" ${i} | sed "s/sp_foreignkey //g" | cut -f1,3 -d"," | sed "s/, /+/g"`

ed $i <<END
g/csh -f -x/s//sh/g
g/source/s//./g
g/sp_primarykey ${t}, /s//ALTER TABLE radar.${t} ADD PRIMARY KEY (/
g/PRIMARY KEY/s/$/);/
g/sp_foreignkey/s//ALTER TABLE radar./
g/, ${t}, /s// ADD FOREIGN KEY (/
g/ALTER TABLE radar. /s//ALTER TABLE radar./
g/FOREIGN KEY/s/$/) REFERENCES radar.${t} ON DELETE CASCADE;/
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
g/^go/s///g
/^checkpoint
;d
a
EOSQL
.
w
q
END

#
# edit the drop script for the master table
#

dropScript=${t}_drop.object
ed ${dropScript} <<END
g/csh -f -x/s//sh/g
g/& source/s//./g
g/sp_dropkey foreign, /d
g/sp_dropkey primary, /s//ALTER TABLE radar./
g/, ${t}/s// DROP CONSTRAINT/
g/ALTER TABLE radar.${t}/s//ALTER TABLE radar.${t} DROP CONSTRAINT ${t}_pkey CASCADE;/

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
g/^go/d
g/^$/d
/^checkpoint
;d
a

EOSQL
.
w
q
END

#
# for each foreign key
#
# fkey = ALL_Marker_Assoc+_Marker_key
#
# ALTER TABLE ALL_Marker_Assoc DROP CONSTRAIN
# convert to
# ALTER TABLE ALL_Marker_Assoc DROP CONSTRAIN ALL_Marker_Assoc__Marker_key_fkey CASCADE
#

# for each foreign key

for f in ${fkey}
do

#t2 = table name
t2=`echo ${f} | cut -f1 -d"+"`

#f2 = foreign key
f2=`echo ${f} | sed "s/+/_/g`

ed ${dropScript} <<END
/cat
a

ALTER TABLE radar.${t2} DROP CONSTRAINT ${f2}_fkey CASCADE;
.
w
q
END
done

done

