-- alter teacher table to add forum id and authenticator
--
-- This is the minimum needed to allow seamless single-sign-on
-- from the e-Lab to the BOINC forums.   The authenticator is a 
-- secret token unique to each BOINC user which can be used in a
-- cookie to provide automatic authentication.
--
-- Example: psql -h data1 -d userdb_cosmic2_testing -U portal2006_2022 \
--               -f add_authenticator.sql
--
--
-- Eric Myers <myers@spy-hill.net>  - 22 May 2009


-- The "authenticator" is a 32 character hex number which is unique
-- to an individual and is a secret used for authentication.  
-- Ideally this column should be UNIQUE, but we have multiple teachers
-- with the same e-mail address in the existing database, so until
-- we cull duplicates do not make it UNIQUE.

ALTER TABLE ONLY teacher
  DROP COLUMN authenticator;
ALTER TABLE ONLY teacher
  ADD COLUMN authenticator character varying(254); 

-- This is the user ID in the forums.  We save it for future use should
-- we want to be able to index into that database directly.

ALTER TABLE ONLY teacher
  DROP COLUMN forum_id;
ALTER TABLE ONLY teacher
  ADD COLUMN forum_id integer;

-- EOF 

