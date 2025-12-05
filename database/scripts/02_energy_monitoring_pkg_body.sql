-- Step 1: First, drop the package body if it exists
DROP PACKAGE BODY energy_monitoring_pkg;

-- Step 2: Then create the complete package body directly
CREATE OR REPLACE PACKAGE BODY energy_monitoring_pkg IS

    -- PROCEDURE 1: Add consumption reading
    PROCEDURE add_consumption_reading(
        p_meter_id IN consumption_readings.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE,
        p_voltage_reading IN consumption_readings.voltage_reading%TYPE DEFAULT NULL,
        p_reading_date IN consumption_readings.reading_date%TYPE DEFAULT SYSDATE,
        p_reading_id OUT consumption_readings.reading_id%TYPE,
        p_status_message OUT VARCHAR2
    ) IS
        v_meter_exists BOOLEAN;
        v_validation_result VARCHAR2(100);
        v_cost_amount NUMBER(10,2);
        v_retry_count NUMBER := 0;
        v_max_retries CONSTANT NUMBER := 3;
    BEGIN
        -- Input validation
        IF p_meter_id IS NULL OR p_consumption_kwh IS NULL THEN
            RAISE invalid_consumption_data;
        END IF;
        
        -- Check meter availability
        v_meter_exists := is_meter_available(p_meter_id);
        IF NOT v_meter_exists THEN
            RAISE meter_not_found;
        END IF;
        
        -- Validate reading
        v_validation_result := validate_meter_reading(p_meter_id, p_consumption_kwh);
        IF v_validation_result != 'VALID' THEN
            p_status_message := 'Validation failed: ' || v_validation_result;
            RETURN;
        END IF;
        
        -- Calculate cost
        v_cost_amount := p_consumption_kwh * 0.15;
        
        -- Retry logic for concurrent inserts
        WHILE v_retry_count < v_max_retries LOOP
            BEGIN
                INSERT INTO consumption_readings (
                    reading_id, meter_id, reading_date, consumption_kwh,
                    voltage_reading, cost_amount, reading_quality,
                    reading_timestamp
                ) VALUES (
                    seq_readings_id.NEXTVAL, p_meter_id, p_reading_date, p_consumption_kwh,
                    p_voltage_reading, v_cost_amount, 'G',
                    SYSTIMESTAMP
                )
                RETURNING reading_id INTO p_reading_id;
                
                p_status_message := 'SUCCESS: Reading ' || p_reading_id || ' added';
                EXIT;
                
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    v_retry_count := v_retry_count + 1;
                    IF v_retry_count = v_max_retries THEN
                        RAISE;
                    END IF;
                WHEN OTHERS THEN
                    RAISE;
            END;
        END LOOP;
        
        COMMIT;
        
    EXCEPTION
        WHEN invalid_consumption_data THEN
            p_status_message := 'ERROR: Invalid consumption data provided';
            ROLLBACK;
        WHEN meter_not_found THEN
            p_status_message := 'ERROR: Meter ' || p_meter_id || ' not found or inactive';
            ROLLBACK;
        WHEN OTHERS THEN
            p_status_message := 'ERROR: ' || SQLERRM;
            ROLLBACK;
            RAISE;
    END add_consumption_reading;

    -- PROCEDURE 2: Update meter status
    PROCEDURE update_meter_status(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_is_active IN energy_meters.is_active%TYPE,
        p_calibration_date IN energy_meters.calibration_date%TYPE DEFAULT NULL,
        p_rows_updated OUT NUMBER,
        p_status_message OUT VARCHAR2
    ) IS
        v_current_status energy_meters.is_active%TYPE;
    BEGIN
        SELECT is_active INTO v_current_status
        FROM energy_meters
        WHERE meter_id = p_meter_id;
        
        UPDATE energy_meters 
        SET is_active = p_is_active,
            calibration_date = CASE 
                WHEN p_calibration_date IS NOT NULL THEN p_calibration_date
                WHEN p_is_active = 'Y' AND v_current_status = 'N' THEN SYSDATE
                ELSE calibration_date 
            END
        WHERE meter_id = p_meter_id;
        
        p_rows_updated := SQL%ROWCOUNT;
        
        IF p_rows_updated = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
        
        COMMIT;
        p_status_message := 'SUCCESS: Meter ' || p_meter_id || ' updated to ' || p_is_active;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status_message := 'ERROR: Meter ' || p_meter_id || ' not found';
            p_rows_updated := 0;
            ROLLBACK;
        WHEN OTHERS THEN
            p_status_message := 'ERROR: ' || SQLERRM;
            p_rows_updated := 0;
            ROLLBACK;
            RAISE;
    END update_meter_status;

    -- PROCEDURE 3: Bulk insert readings
    PROCEDURE bulk_insert_readings(
        p_readings_array IN SYS.ODCINUMBERLIST,
        p_consumptions_array IN SYS.ODCINUMBERLIST,
        p_success_count OUT NUMBER,
        p_error_count OUT NUMBER
    ) IS
        TYPE reading_rec IS RECORD (
            meter_id NUMBER,
            consumption_kwh NUMBER,
            reading_date DATE,
            cost_amount NUMBER,
            reading_quality VARCHAR2(1)
        );
        TYPE reading_tab IS TABLE OF reading_rec;
        v_readings reading_tab := reading_tab();
    BEGIN
        p_success_count := 0;
        p_error_count := 0;
        
        IF p_readings_array IS NULL OR p_consumptions_array IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'Input arrays cannot be NULL');
        END IF;
        
        IF p_readings_array.COUNT != p_consumptions_array.COUNT THEN
            RAISE_APPLICATION_ERROR(-20011, 'Input arrays must have same length');
        END IF;
        
        v_readings.EXTEND(p_readings_array.COUNT);
        
        FOR i IN 1..p_readings_array.COUNT LOOP
            BEGIN
                IF p_readings_array(i) IS NULL THEN
                    p_error_count := p_error_count + 1;
                    CONTINUE;
                END IF;
                
                DECLARE
                    v_meter_exists NUMBER;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_meter_exists
                    FROM energy_meters
                    WHERE meter_id = p_readings_array(i)
                    AND is_active = 'Y';
                    
                    IF v_meter_exists = 0 THEN
                        p_error_count := p_error_count + 1;
                        CONTINUE;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        p_error_count := p_error_count + 1;
                        CONTINUE;
                END;
                
                v_readings(i).meter_id := p_readings_array(i);
                v_readings(i).consumption_kwh := p_consumptions_array(i);
                v_readings(i).reading_date := SYSDATE;
                v_readings(i).cost_amount := p_consumptions_array(i) * 0.15;
                v_readings(i).reading_quality := 'G';
                
                p_success_count := p_success_count + 1;
                
            EXCEPTION
                WHEN OTHERS THEN
                    p_error_count := p_error_count + 1;
            END;
        END LOOP;
        
        IF v_readings.COUNT > 0 THEN
            FORALL i IN 1..v_readings.COUNT
                INSERT INTO consumption_readings (
                    reading_id, meter_id, reading_date, consumption_kwh,
                    cost_amount, reading_quality, reading_timestamp
                ) VALUES (
                    seq_readings_id.NEXTVAL, 
                    v_readings(i).meter_id, 
                    v_readings(i).reading_date,
                    v_readings(i).consumption_kwh, 
                    v_readings(i).cost_amount,
                    v_readings(i).reading_quality, 
                    SYSTIMESTAMP
                );
        END IF;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            p_success_count := 0;
            p_error_count := p_readings_array.COUNT;
            ROLLBACK;
            RAISE;
    END bulk_insert_readings;

    -- FUNCTION 1: Validate meter reading (FIXED - SIMPLE VERSION)
    FUNCTION validate_meter_reading(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE
    ) RETURN VARCHAR2 IS
        v_dummy NUMBER;
    BEGIN
        IF p_consumption_kwh < 0 THEN
            RETURN 'INVALID: Negative consumption';
        ELSIF p_consumption_kwh = 0 THEN
            RETURN 'WARNING: Zero consumption';
        END IF;
        
        BEGIN
            SELECT 1 INTO v_dummy
            FROM energy_meters 
            WHERE meter_id = p_meter_id 
            AND is_active = 'Y';
            
            RETURN 'VALID';
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'INVALID: Meter not found or inactive';
            WHEN OTHERS THEN
                RETURN 'ERROR: Meter check failed';
        END;
        
    END validate_meter_reading;

    -- FUNCTION 2: Calculate daily consumption
    FUNCTION calculate_daily_consumption(
        p_building_id IN buildings.building_id%TYPE,
        p_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER IS
        v_total_consumption NUMBER := 0;
        v_building_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_building_exists
        FROM buildings WHERE building_id = p_building_id;
        
        IF v_building_exists = 0 THEN
            RETURN -1;
        END IF;
        
        SELECT SUM(r.consumption_kwh)
        INTO v_total_consumption
        FROM consumption_readings r
        JOIN energy_meters m ON r.meter_id = m.meter_id
        WHERE m.building_id = p_building_id
        AND TRUNC(r.reading_date) = TRUNC(p_date);
        
        RETURN NVL(v_total_consumption, 0);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -999;
    END calculate_daily_consumption;

    -- FUNCTION 3: Check meter availability
    FUNCTION is_meter_available(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN BOOLEAN IS
        v_is_active energy_meters.is_active%TYPE;
        v_meter_count NUMBER;
    BEGIN
        SELECT COUNT(*), MAX(is_active)
        INTO v_meter_count, v_is_active
        FROM energy_meters
        WHERE meter_id = p_meter_id;
        
        RETURN (v_meter_count > 0 AND v_is_active = 'Y');
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_meter_available;

END energy_monitoring_pkg;
/