echo "[INFO] Loading all triggers and views without foreign key sql scripts"

export TABLE_CUSTOMERS="customer_view"
export TABLE_ORDERS="orders_view"
time load_sql_scripts ${PATH_SQL_VIEW}