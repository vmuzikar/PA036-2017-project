\o /dev/null

SET ROLE tpcc;
\timing on
SELECT perf_select(:'customers_table', 1000);
\timing off


SET ROLE tpcc;


