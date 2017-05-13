CREATE OR REPLACE FUNCTION access_control_update_delete() RETURNS trigger AS $terminator$
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
            IF pg_has_role(user_role, OLD.record_update,'member') THEN
                UPDATE customer
                SET
                    c_id = NEW.c_id,
                    c_d_id = NEW.c_d_id,
                    c_w_id = NEW.c_w_id,
                    c_first = NEW.c_first,
                    c_middle = NEW.c_middle,
                    c_last = NEW.c_last,
                    c_street_1 = NEW.c_street_1,
                    c_street_2 = NEW.c_street_2,
                    c_city = NEW.c_city,
                    c_state = NEW.c_state,
                    c_zip = NEW.c_zip,
                    c_phone = NEW.c_phone,
                    c_since = NEW.c_since,
                    c_credit = NEW.c_credit,
                    c_credit_lim = NEW.c_credit_lim,
                    c_discount = NEW.c_discount,
                    c_balance = NEW.c_balance,
                    c_ytd_payment = NEW.c_ytd_payment,
                    c_payment_cnt = NEW.c_payment_cnt,
                    c_delivery_cnt = NEW.c_delivery_cnt,
                    c_data = NEW.c_data,
                    record_update = NEW.record_update,
                    record_delete = NEW.record_delete,
                    record_select = NEW.record_select
                WHERE
                    c_id = OLD.c_id AND c_d_id = OLD.c_d_id AND c_w_id = OLD.c_w_id;
                RETURN NEW;
            ELSE
                RETURN NULL;
            END IF;
        ELSIF (TG_OP = 'DELETE') THEN
            IF pg_has_role(user_role, OLD.record_delete,'member') THEN
                DELETE FROM customer WHERE c_id = OLD.c_id;
                RETURN OLD;
            ELSE
                RETURN NULL;
            END IF;
        ELSE
            RAISE EXCEPTION 'Unsupported operation: %', TG_OP;
        END IF;
    END;
$terminator$ LANGUAGE plpgsql SECURITY DEFINER;