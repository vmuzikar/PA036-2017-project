--\o /dev/null

SET ROLE tpcc;

-- function will get random role
CREATE OR REPLACE FUNCTION get_random_role() RETURNS TEXT AS $$
DECLARE
    rol_name TEXT;
BEGIN
	SELECT rolname INTO rol_name FROM pg_roles WHERE rolname not in ('pg_signal_backend') AND rolsuper=false ORDER BY RANDOM() LIMIT 1;
    RETURN rol_name;
END;
$$ LANGUAGE plpgsql;

-- Function will execute query 
-- @param role_name - Role NAME
CREATE OR REPLACE FUNCTION do_action_query(role_name TEXT, act_query TEXT) RETURNS void AS $$
BEGIN
    EXECUTE 'SET ROLE ' || QUOTE_IDENT(role_name);
    EXECUTE act_query;
END;
$$ LANGUAGE plpgsql;

-- Function will perform performance tests
CREATE OR REPLACE FUNCTION perf_test(max_iter integer, act_query TEXT) 
RETURNS void AS
$$ 
DECLARE role_name TEXT;
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
        role_name := get_random_role();
    	PERFORM do_action_query(role_name, act_query);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

GRANT EXECUTE ON FUNCTION get_random_role() TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_action_query(role_name TEXT, act_query TEXT) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_test(max_iter integer, act_query TEXT) TO PUBLIC;


SET ROLE tpcc;
