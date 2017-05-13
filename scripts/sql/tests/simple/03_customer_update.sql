\o /dev/null

-- preparation
SELECT do_create_customer(:'customers_table', 'member', 2002);

\timing on
SELECT do_update_customer(:'customers_table', 2002);
\timing off

-- test and deletion
SELECT do_delete_customer(:'customers_table', 2002);
