SET ROLE tpcc;

CREATE OR REPLACE FUNCTION get_random_role() RETURNS TEXT AS $$
DECLARE
    rol_name TEXT;
BEGIN
	SELECT rolname INTO rol_name FROM pg_roles WHERE rolname not in ('pg_signal_backend') AND rolsuper=false ORDER BY RANDOM() LIMIT 1;
    RETURN rol_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION do_action(role_name TEXT) RETURNS void AS $$
BEGIN
    EXECUTE 'SET ROLE ' || QUOTE_IDENT(role_name);
    PERFORM * from customer LIMIT 1;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION perf_test(max_iter integer)
RETURNS void AS
$$ 
DECLARE role_name TEXT;
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
        role_name := get_random_role();
    	PERFORM do_action(role_name);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

\timing on \o /dev/null;
SELECT perf_test(1000);
\timing off \o /dev/null;


SET ROLE tpcc;


