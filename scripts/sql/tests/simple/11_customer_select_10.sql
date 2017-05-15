\o /dev/null

SET ROLE tpcc;
\timing on
SELECT perf_select(:'customers_table', 10);
\timing off


SET ROLE tpcc;


