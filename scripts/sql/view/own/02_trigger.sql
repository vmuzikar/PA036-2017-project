CREATE TRIGGER update_delete_trigger
    INSTEAD OF UPDATE OR DELETE ON customer_view
    FOR EACH ROW EXECUTE PROCEDURE access_control_update_delete();