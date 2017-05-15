\o /dev/null

-- Preparation
SELECT do_create_order(:'orders_table', 'member', 2000);

-- MEASURE
\timing on

SELECT do_delete_order(:'orders_table', 2000);

\timing off

