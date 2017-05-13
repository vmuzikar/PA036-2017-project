CREATE OR REPLACE VIEW customer_view WITH (security_barrier) AS
    SELECT * FROM customer WHERE pg_has_role(record_select, 'member');