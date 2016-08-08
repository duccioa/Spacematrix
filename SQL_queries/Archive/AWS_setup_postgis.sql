-- Setup PostGIS on AWS amazon
-- http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS
-- Create the database
-- Install the extensions:
create extension postgis;
create extension fuzzystrmatch;
create extension postgis_tiger_geocoder;
create extension postgis_topology;
alter schema tiger owner to rds_superuser;
alter schema topology owner to rds_superuser;
-- First run on psql the following command
-- psql --host=msc.cnjtjqfjswwv.eu-west-1.rds.amazonaws.com --port=5432 --username=duccioa --password --dbname=msc
-- CREATE FUNCTION exec(text) returns text language plpgsql volatile AS $f$ BEGIN EXECUTE $1; RETURN $1; END; $f$;
-- Then run the following
SELECT exec('ALTER TABLE ' || quote_ident(s.nspname) || '.' || quote_ident(s.relname) || ' OWNER TO rds_superuser;')
  FROM (
    SELECT nspname, relname
    FROM pg_class c JOIN pg_namespace n ON (c.relnamespace = n.oid) 
    WHERE nspname in ('tiger','topology') AND
    relkind IN ('r','S','v') ORDER BY relkind = 'S')
s; 

-- Finally run the following on psql
-- SET search_path=public,tiger;
-- And upload the sql dump
-- psql -f /Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/msc.sql  --host msc.cnjtjqfjswwv.eu-west-1.rds.amazonaws.com --port 5432 --username duccioa --password postgres --dbname msc