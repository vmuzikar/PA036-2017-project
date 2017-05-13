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

-- Function will create customer 
-- @param role_name - Role NAME
CREATE OR REPLACE FUNCTION do_create_customer(role_name TEXT, counter INTEGER) RETURNS void AS $$
BEGIN
    INSERT INTO customer 
        (c_id, c_d_id, c_w_id, 
        c_first, c_middle, c_last, c_street_1,
        record_update, record_delete, record_select) 
    VALUES (6000 + counter,11,2,'PERF_' || CAST(counter as TEXT), 'Md', 'Last_' || CAST(counter as TEXT) , 'S1',
        role_name, role_name, role_name);
END;
$$ LANGUAGE plpgsql;

-- Function will delete customer which id equal to counter
-- @param max_iter - Iter name
CREATE OR REPLACE FUNCTION do_delete_customer(counter integer) RETURNS void AS $$
BEGIN
   DELETE FROM customer WHERE c_id=(6000 + counter);
END;
$$ LANGUAGE plpgsql;

-- Function will delete customer which id equal to counter
-- @param max_iter - Iter name
CREATE OR REPLACE FUNCTION do_update_customer(counter integer) RETURNS void AS $$
BEGIN
   UPDATE customer SET c_first='PUPDATED_' || CAST(counter as TEXT) WHERE c_id = (6000 + counter);
END;
$$ LANGUAGE plpgsql;

-- Function will create customers
-- @param max_iter integer
CREATE OR REPLACE FUNCTION perf_insert_customers(max_iter integer) 
RETURNS void AS
$$ 
DECLARE role_name TEXT;
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
        role_name := get_random_role();
    	PERFORM do_create_customer(role_name, counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_delete_customers(max_iter integer) 
RETURNS void AS
$$ 
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
    	PERFORM do_delete_customer(counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_update_customers(max_iter integer) 
RETURNS void AS
$$ 
DECLARE counter integer = 0;
BEGIN
	WHILE counter != max_iter LOOP
    	PERFORM do_update_customer(counter);
        counter := counter + 1;
  	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION perf_clean_up(max_iter integer) RETURNS void AS $$ 
BEGIN
       DELETE FROM customer WHERE c_id >= max_iter;
END;
$$ LANGUAGE 'plpgsql';

GRANT EXECUTE ON FUNCTION get_random_role() TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_action_query(role_name TEXT, act_query TEXT) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_test(max_iter integer, act_query TEXT) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_insert_customers(max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_delete_customer(max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_delete_customers(max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_clean_up(max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION perf_update_customers(max_iter integer) TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_create_customer(role_name TEXT, counter INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION do_update_customer(counter INTEGER) TO PUBLIC;



SET ROLE tpcc;
