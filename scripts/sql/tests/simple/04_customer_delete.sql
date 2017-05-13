\o /dev/null

-- Preparation
SELECT do_create_customer(:'customers_table', 'member', 2000);

-- MEASURE
\timing on

SELECT do_delete_customer(:'customers_table', 2000);

\timing off

