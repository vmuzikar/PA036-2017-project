-- Auxiliary function similar to pg_has_role except it works with 'customer' table
CREATE OR REPLACE FUNCTION customer_has_role(user_role name, operation text, c_id numeric, c_d_id numeric, c_w_id numeric) RETURNS boolean AS $terminator$
    DECLARE
        permissions varchar;
    BEGIN
        EXECUTE 'SELECT record_' || operation
                || ' FROM customer'
                || ' WHERE c_id = $1 AND c_d_id = $2 AND c_w_id = $3'
                USING c_id, c_d_id, c_w_id
                INTO permissions;
                
        RETURN pg_has_role(user_role, permissions, 'member');
    END;
$terminator$ LANGUAGE plpgsql;

-- Creating the view for accessing the data (instead of querying the table directly)
CREATE OR REPLACE VIEW orders_view WITH (security_barrier) AS
    SELECT * FROM orders WHERE customer_has_role(current_user, 'select', o_c_id, o_d_id, o_w_id);

-- Trigger function for UPDATE and DELETE operations
CREATE OR REPLACE FUNCTION orders_access_control_update_delete() RETURNS trigger AS $terminator$
    DECLARE
        user_role text := current_setting('role');
    BEGIN
        /*
          Since this function is running with the rights of it's creator, we can't rely on current_user.
          But we still need to know the user who is executing the trigger.
          There are two possible scenarios how to gain a role:
            1) SET ROLE xxx - for this case we use current_setting('role')
            2) Login a the user directly - in this case we need session_user
        */
        IF user_role = 'none' THEN
            user_role := session_user;
        END IF;
        
        IF (TG_OP = 'UPDATE') THEN
            IF customer_has_role(user_role, 'update', OLD.o_c_id, OLD.o_d_id, OLD.o_w_id) THEN
                UPDATE order
                SET
                    o_id = NEW.o_id,
                    o_w_id = NEW.o_w_id,
                    o_d_id = NEW.o_d_id,
                    o_c_id = NEW.o_c_id,
                    o_carrier_id = NEW.o_carrier_id,
                    o_ol_cnt = NEW.o_ol_cnt,
                    o_all_local = NEW.o_all_local,
                    o_entry_d = NEW.o_entry_d
                WHERE
                    o_w_id = OLD.o_w_id AND o_d_id = OLD.o_d_id AND o_id = OLD.o_id;
                RETURN NEW;
            ELSE
                RETURN NULL;
            END IF;
        ELSIF (TG_OP = 'DELETE') THEN
            IF customer_has_role(user_role, 'delete', OLD.o_c_id, OLD.o_d_id, OLD.o_w_id) THEN
                DELETE FROM order WHERE o_w_id = OLD.o_w_id AND o_d_id = OLD.o_d_id AND o_id = OLD.o_id;
                RETURN OLD;
            ELSE
                RETURN NULL;
            END IF;
        ELSE
            RAISE EXCEPTION 'Unsupported operation: %', TG_OP;
        END IF;
    END;
$terminator$ LANGUAGE plpgsql SECURITY DEFINER;

-- The trigger definition
CREATE TRIGGER update_delete_trigger
    INSTEAD OF UPDATE OR DELETE ON orders_view
    FOR EACH ROW EXECUTE PROCEDURE orders_access_control_update_delete();