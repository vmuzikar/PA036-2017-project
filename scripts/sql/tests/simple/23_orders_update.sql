\o /dev/null

-- preparation
SELECT do_create_order(:'orders_table', 'member', 2002);

\timing on
SELECT do_update_order(:'orders_table', 2002);
\timing off

-- test and deletion
SELECT do_delete_order('orders', 2002);
