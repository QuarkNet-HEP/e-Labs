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


ALTER TABLE ONLY teacher
  ADD COLUMN forum_id integer;

ALTER TABLE ONLY teacher
  ADD COLUMN authenticator character varying(254) UNIQUE;

-- EOF
