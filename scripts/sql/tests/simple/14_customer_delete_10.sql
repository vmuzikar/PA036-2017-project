\o /dev/null

SET ROLE tpcc;

SELECT perf_insert_customers(:'customers_table', 10);

\timing on
SELECT perf_delete_customers(:'customers_table', 10);
\timing off

-- SELECT perf_clean_up(:'customers_table', 6000);


SET ROLE tpcc;