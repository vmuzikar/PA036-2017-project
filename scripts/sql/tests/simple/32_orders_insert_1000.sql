\o /dev/null

SET ROLE tpcc;

\timing ON
SELECT perf_insert_orders(:'orders_table', 1000);
\timing OFF

SELECT perf_orders_clean_up(:'orders_table', 6000);
SET ROLE tpcc;