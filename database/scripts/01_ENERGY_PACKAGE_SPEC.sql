-- =============================================
-- Energy Monitoring Package Specification
-- Phase VI: PL/SQL Development
-- =============================================

CREATE OR REPLACE PACKAGE energy_monitoring_pkg IS
    
    -- Custom Exceptions
    consumption_too_high EXCEPTION;
    PRAGMA EXCEPTION_INIT(consumption_too_high, -20001);
    invalid_meter_state EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_meter_state, -20002);
    threshold_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(threshold_violation, -20003);

    -- PROCEDURES (5 required)
    
    -- 1. Add new consumption reading with validation
    PROCEDURE add_consumption_reading(
        p_meter_id IN consumption_readings.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE,
        p_reading_date IN consumption_readings.reading_date%TYPE DEFAULT SYSDATE,
        p_reading_id OUT consumption_readings.reading_id%TYPE
    );
    
    -- 2. Update meter status
    PROCEDURE update_meter_status(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_is_active IN energy_meters.is_active%TYPE,
        p_rows_updated OUT NUMBER
    );
    
    -- 3. Generate threshold alerts
    PROCEDURE generate_threshold_alerts(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_alert_count OUT NUMBER
    );
    
    -- 4. Archive old readings
    PROCEDURE archive_old_readings(
        p_cutoff_date IN DATE,
        p_archived_count OUT NUMBER
    );
    
    -- 5. Update building thresholds
    PROCEDURE update_building_thresholds(
        p_building_id IN buildings.building_id%TYPE,
        p_warning_level IN consumption_thresholds.warning_level_kwh%TYPE,
        p_critical_level IN consumption_thresholds.critical_level_kwh%TYPE,
        p_threshold_type IN consumption_thresholds.threshold_type%TYPE DEFAULT 'Daily'
    );

    -- FUNCTIONS (5 required)
    
    -- 1. Calculate daily consumption
    FUNCTION calculate_daily_consumption(
        p_building_id IN buildings.building_id%TYPE,
        p_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER;
    
    -- 2. Validate meter reading
    FUNCTION validate_meter_reading(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE
    ) RETURN VARCHAR2;
    
    -- 3. Get building consumption trend
    FUNCTION get_consumption_trend(
        p_building_id IN buildings.building_id%TYPE,
        p_days IN NUMBER DEFAULT 7
    ) RETURN VARCHAR2;
    
    -- 4. Check maintenance due
    FUNCTION is_maintenance_due(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN BOOLEAN;
    
    -- 5. Get meter efficiency rating
    FUNCTION get_meter_efficiency(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN NUMBER;

END energy_monitoring_pkg;
/