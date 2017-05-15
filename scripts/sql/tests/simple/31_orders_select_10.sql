\o /dev/null

SET ROLE tpcc;
\timing on
SELECT perf_select_orders(:'orders_table', 10);
\timing off


SET ROLE tpcc;

