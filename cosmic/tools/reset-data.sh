basedir=/export/d1/quarknet
portal=$basedir"/portal"
usersqldir=$basedir"/jakarta-tomcat-5.0.18/webapps/cosmic"
now=`date '+%Y_%m%d'`
olduser="vds8084"
newuser="vds8084"
oldvdsdb=$olduser"_2004_0805"
newvdsdb=$newuser"_"$now
olduserdb="userdb8084_2004_0805"
newuserdb="userdb8084_"$now

umask 002

#new rc.data
cd $portal/vds/var
grep -v $basedir rc.data >rc.data.new
cp rc.data rc.data.$now
mv rc.data.new rc.data
chgrp quarknet rc.data.$now rc.data
chmod g+w rc.data.$now rc.data

#make an empty portal/cosmic dir
cd $portal
mv cosmic cosmic.$now
mkdir cosmic
chgrp quarknet cosmic
chmod g+w cosmic

#make clean users dir. also make the "guest" and "fermigroup" directorys
mv users users.$now
mkdir users
mkdir users/AY2004
mkdir users/AY2004/IL
mkdir users/AY2004/IL/Chicago
mkdir users/AY2004/IL/Chicago/UofC
mkdir users/AY2004/IL/Chicago/UofC/Physics7
mkdir users/AY2004/IL/Chicago/UofC/Physics7/group2
mkdir users/AY2004/IL/Chicago/UofC/Physics7/group2/cosmic/
mkdir users/AY2004/IL/Chicago/UofC/Physics7/group2/cosmic/scratch
mkdir users/AY2004/IL/Chicago/UofC/Physics7/group2/cosmic/plots
mkdir users/AY2004/IL/Chicago/UofC/Physics7/group2/cosmic/posters
mkdir users/AY2004/IL/Batavia
mkdir users/AY2004/IL/Batavia/Fermilab
mkdir users/AY2004/IL/Batavia/Fermilab/Jordan
mkdir users/AY2004/IL/Batavia/Fermilab/Jordan/fermigroup
mkdir users/AY2004/IL/Batavia/Fermilab/Jordan/fermigroup/cosmic
mkdir users/AY2004/IL/Batavia/Fermilab/Jordan/fermigroup/cosmic/scratch
mkdir users/AY2004/IL/Batavia/Fermilab/Jordan/fermigroup/cosmic/plots
mkdir users/AY2004/IL/Batavia/Fermilab/Jordan/fermigroup/cosmic/posters
chgrp -R quarknet users
chmod -R g+w users


#copy the postgres database to a new one WITH NO METADATA
cd $usersqldir
/export/d2/pgsql/bin/pg_dump $oldvdsdb --blobs -f $oldvdsdb.dump.tar --format=t --no-owner -U $olduser
/export/d2/pgsql/bin/psql -U $newuser -c "CREATE DATABASE $newvdsdb WITH TEMPLATE = template0;"
/export/d2/pgsql/bin/pg_restore -d $newvdsdb --no-owner -U $newuser $oldvdsdb.dump.tar
echo "TRUNCATE TABLE anno_bool;
TRUNCATE TABLE anno_date;
TRUNCATE TABLE anno_float;
TRUNCATE TABLE anno_int;
TRUNCATE TABLE anno_lfn;
TRUNCATE TABLE anno_string;
SELECT setval('anno_id_seq', 1);" > wipemeta.sql
/export/d2/pgsql/bin/psql -U $newuser -d $newvdsdb -f wipemeta.sql

#create clean postgres userdb
/export/d2/pgsql/bin/psql -U $newuser -c "CREATE DATABASE $newuserdb;"
/export/d2/pgsql/bin/psql -U $newuser -d $newuserdb -f userdb.sql

echo "new vds database: $newvdsdb"
echo "new user database: $newuserdb"

#remember to change the userdb database name in common.jsp
#remember to change the vds database name in $portal/vds/etc/properties
