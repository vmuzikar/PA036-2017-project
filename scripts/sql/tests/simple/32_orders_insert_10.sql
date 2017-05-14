\o /dev/null

SET ROLE tpcc;

\timing ON
SELECT perf_insert_orders(:'orders_table', 10);
\timing OFF

SELECT perf_orders_clean_up('orders', 6000);
SET ROLE tpcc;