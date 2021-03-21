#!/bin/bash

#if [ "$(whoami)" != "postgres" ]; then
#	echo "Script must be run as user postgres"
#	exit 1
#fi

#echo "Script Ok"

sudo -u postgres /usr/local/bin/psql pthier -c 'select pg_kill_all_sessions('"'"'pthier'"'"','"'"'dpdb'"'"');'
sleep 1

sudo -u postgres /usr/local/e192/postgres/bin/pg_ctl -D /run/hecher/postgres-data stop
sudo -u postgres bash -c "rm -r /run/hecher/postgres-data/*"
#sudo -u postgres rm -r /run/hecher/postgres-data/*
sudo -u postgres sudo mkdir -p /run/hecher/postgres-data
sudo -u postgres sudo chown postgres /run/hecher/postgres-data
sudo -u postgres sudo chgrp postgres /run/hecher/postgres-data
sudo -u postgres sudo chmod 700 /run/hecher/postgres-data

#sudo -u postgres mkdir /run/hecher/postgres-data
sudo -u postgres /usr/local/e192/postgres/bin/initdb -D /run/hecher/postgres-data --no-locale 

sudo -u postgres /usr/local/bin/psql postgres -c "create user pthier with password 'pthier';"
#sudo -u postgres /usr/local/e192/postgres/bin/createuser -PE pthier

echo "user Ok"

#sudo -u postgres /usr/local/e192/postgres/bin/dropdb pthier
sudo -u postgres /usr/local/e192/postgres/bin/createdb pthier

echo "db created"

sudo -u postgres /usr/local/e192/postgres/bin/psql pthier <<'EOF'
create or replace function pg_kill_all_sessions(db varchar, application varchar)
returns integer as
$$
begin
return (select count(*) from (select pg_catalog.pg_terminate_backend(pid) from pg_catalog.pg_stat_activity where pid <> pg_backend_pid() and datname = db and application_name = application) k);
end;
$$
language plpgsql security definer volatile set search_path = pg_catalog;

grant execute on function pg_kill_all_sessions(varchar,varchar) to pthier;
EOF



rm -rf /tmp/tmp*
killall -9 python3
killall -9 projMC-1.0
killall -9 clingo
killall -9 miniC2D-1.0.0
killall -9 picosat-965
killall -9 sharpSAT-git
killall -9 cachet-1.21
killall -9 pmc-1.0
killall -9 ganak-1.0
killall -9 sts-1.0
killall -9 projClingo-1.0
