DROP FUNCTION genBCryptPassword() ;
CREATE OR REPLACE FUNCTION genBCryptPassword() RETURNS VOID AS
$BODY$
DECLARE
	r research_group%rowtype;
BEGIN
	FOR r IN SELECT * FROM research_group WHERE hashedpassword IS NULL
	LOOP
		UPDATE research_group SET hashedpassword = crypt(r.password, gen_salt('bf', 12)) WHERE id = r.id;  
	END LOOP;
	RETURN ;
END
$BODY$
LANGUAGE 'plpgsql'; 