-- =============================================
-- File: 01_energy_monitoring_pkg_spec.sql
-- Energy Monitoring Package Specification
-- Core consumption operations and validations
-- =============================================

CREATE OR REPLACE PACKAGE energy_monitoring_pkg IS
    
    -- Custom Exceptions
    invalid_consumption_data EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_consumption_data, -20001);
    meter_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(meter_not_found, -20002);
    meter_inactive EXCEPTION;
    PRAGMA EXCEPTION_INIT(meter_inactive, -20003);

    -- PROCEDURE 1: Add consumption reading with comprehensive validation
    PROCEDURE add_consumption_reading(
        p_meter_id IN consumption_readings.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE,
        p_voltage_reading IN consumption_readings.voltage_reading%TYPE DEFAULT NULL,
        p_reading_date IN consumption_readings.reading_date%TYPE DEFAULT SYSDATE,
        p_reading_id OUT consumption_readings.reading_id%TYPE,
        p_status_message OUT VARCHAR2
    );
    
    -- PROCEDURE 2: Update meter status with calibration tracking
    PROCEDURE update_meter_status(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_is_active IN energy_meters.is_active%TYPE,
        p_calibration_date IN energy_meters.calibration_date%TYPE DEFAULT NULL,
        p_rows_updated OUT NUMBER,
        p_status_message OUT VARCHAR2
    );
    
    -- PROCEDURE 3: Bulk insert consumption readings
    PROCEDURE bulk_insert_readings(
        p_readings_array IN SYS.ODCINUMBERLIST, -- meter_ids
        p_consumptions_array IN SYS.ODCINUMBERLIST, -- consumption values
        p_success_count OUT NUMBER,
        p_error_count OUT NUMBER
    );

    -- FUNCTION 1: Validate meter reading against business rules
    FUNCTION validate_meter_reading(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE
    ) RETURN VARCHAR2;
    
    -- FUNCTION 2: Calculate daily consumption for building
    FUNCTION calculate_daily_consumption(
        p_building_id IN buildings.building_id%TYPE,
        p_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER;
    
    -- FUNCTION 3: Check if meter exists and is active
    FUNCTION is_meter_available(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN BOOLEAN;

END energy_monitoring_pkg;
/