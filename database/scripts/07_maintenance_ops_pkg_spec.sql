-- =============================================
-- File: 07_maintenance_ops_pkg_spec.sql
-- Maintenance Operations Package Specification
-- Maintenance scheduling, meter management, and archiving
-- =============================================

CREATE OR REPLACE PACKAGE maintenance_ops_pkg IS
    
    -- Custom Exceptions
    maintenance_scheduling_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(maintenance_scheduling_error, -20301);
    archive_operation_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(archive_operation_failed, -20302);

    -- PROCEDURE 1: Generate maintenance report with cursor processing
    PROCEDURE generate_maintenance_report(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_report_details OUT VARCHAR2
    );
    
    -- PROCEDURE 2: Archive old readings with bulk operations
    PROCEDURE archive_old_readings(
        p_cutoff_date IN DATE,
        p_batch_size IN NUMBER DEFAULT 1000,
        p_archived_count OUT NUMBER,
        p_error_count OUT NUMBER
    );
    
    -- PROCEDURE 3: Schedule maintenance for multiple meters
    PROCEDURE schedule_bulk_maintenance(
        p_meter_ids IN SYS.ODCINUMBERLIST,
        p_maintenance_type IN maintenance_logs.maintenance_type%TYPE,
        p_technician_name IN maintenance_logs.technician_name%TYPE,
        p_scheduled_count OUT NUMBER,
        p_failed_count OUT NUMBER
    );

    -- FUNCTION 1: Check if maintenance is due
    FUNCTION is_maintenance_due(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN BOOLEAN;
    
    -- FUNCTION 2: Calculate next maintenance date
    FUNCTION calculate_next_maintenance(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN DATE;
    
    -- FUNCTION 3: Get maintenance history count
    FUNCTION get_maintenance_count(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN NUMBER;

END maintenance_ops_pkg;
/