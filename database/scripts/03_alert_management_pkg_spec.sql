-- =============================================
-- File: 03_alert_management_pkg_spec.sql
-- Alert Management Package Specification
-- Threshold monitoring and alert generation
-- =============================================

CREATE OR REPLACE PACKAGE alert_management_pkg IS
    
    -- Custom Exceptions
    threshold_config_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(threshold_config_error, -20101);
    alert_generation_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(alert_generation_failed, -20102);

    -- PROCEDURE 1: Generate threshold alerts with cursor processing
    PROCEDURE generate_threshold_alerts(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_alert_count OUT NUMBER,
        p_error_count OUT NUMBER
    );
    
    -- PROCEDURE 2: Update building thresholds with validation
    PROCEDURE update_building_thresholds(
        p_building_id IN buildings.building_id%TYPE,
        p_threshold_type IN consumption_thresholds.threshold_type%TYPE,
        p_warning_level IN consumption_thresholds.warning_level_kwh%TYPE,
        p_critical_level IN consumption_thresholds.critical_level_kwh%TYPE,
        p_effective_date IN consumption_thresholds.effective_date%TYPE DEFAULT SYSDATE,
        p_rows_affected OUT NUMBER,
        p_status_message OUT VARCHAR2
    );
    
    -- PROCEDURE 3: Resolve alerts in bulk
    PROCEDURE bulk_resolve_alerts(
        p_alert_ids IN SYS.ODCINUMBERLIST,
        p_resolved_by IN alerts.resolved_by%TYPE,
        p_resolved_count OUT NUMBER,
        p_failed_count OUT NUMBER
    );

    -- FUNCTION 1: Check consumption against thresholds
    FUNCTION check_threshold_breach(
        p_building_id IN buildings.building_id%TYPE,
        p_consumption_kwh IN NUMBER,
        p_threshold_type IN consumption_thresholds.threshold_type%TYPE DEFAULT 'Daily'
    ) RETURN VARCHAR2;
    
    -- FUNCTION 2: Get active alert count for building
    FUNCTION get_active_alert_count(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL
    ) RETURN NUMBER;
    
    -- FUNCTION 3: Validate threshold configuration
    FUNCTION validate_threshold_config(
        p_warning_level IN consumption_thresholds.warning_level_kwh%TYPE,
        p_critical_level IN consumption_thresholds.critical_level_kwh%TYPE
    ) RETURN BOOLEAN;

END alert_management_pkg;
/