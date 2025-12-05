CREATE OR REPLACE PACKAGE BODY energy_monitoring_pkg IS

    -- PROCEDURE 1: Add new consumption reading with validation
    PROCEDURE add_consumption_reading(
        p_meter_id IN consumption_readings.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE,
        p_reading_date IN consumption_readings.reading_date%TYPE DEFAULT SYSDATE,
        p_reading_id OUT consumption_readings.reading_id%TYPE
    ) IS
        v_meter_active energy_meters.is_active%TYPE;
        v_max_capacity energy_meters.capacity_kw%TYPE;
        v_validation_result VARCHAR2(100);
        v_dummy_count NUMBER;
    BEGIN
        -- Check if meter exists and is active
        BEGIN
            SELECT is_active, capacity_kw 
            INTO v_meter_active, v_max_capacity
            FROM energy_meters 
            WHERE meter_id = p_meter_id;
            
            IF v_meter_active != 'Y' THEN
                RAISE invalid_meter_state;
            END IF;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20004, 'Meter ID ' || p_meter_id || ' not found');
        END;
        
        -- Validate reading using function
        v_validation_result := validate_meter_reading(p_meter_id, p_consumption_kwh);
        
        IF v_validation_result != 'VALID' THEN
            RAISE_APPLICATION_ERROR(-20005, 'Reading validation failed: ' || v_validation_result);
        END IF;
        
        -- Insert the reading
        INSERT INTO consumption_readings (
            reading_id, meter_id, reading_date, consumption_kwh, 
            reading_timestamp, cost_amount, reading_quality
        ) VALUES (
            seq_readings_id.NEXTVAL, p_meter_id, p_reading_date, p_consumption_kwh,
            SYSTIMESTAMP, p_consumption_kwh * 0.15, -- Simple cost calculation
            CASE WHEN p_consumption_kwh > NVL(v_max_capacity, 1000) * 24 THEN 'S' ELSE 'G' END
        )
        RETURNING reading_id INTO p_reading_id;
        
        -- Generate alerts if needed
        generate_threshold_alerts(NULL, v_dummy_count);
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Reading ' || p_reading_id || ' added successfully');
        
    EXCEPTION
        WHEN invalid_meter_state THEN
            RAISE_APPLICATION_ERROR(-20002, 'Meter is not active');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20006, 'Error adding consumption reading: ' || SQLERRM);
    END add_consumption_reading;

    -- PROCEDURE 2: Update meter status
    PROCEDURE update_meter_status(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_is_active IN energy_meters.is_active%TYPE,
        p_rows_updated OUT NUMBER
    ) IS
    BEGIN
        UPDATE energy_meters 
        SET is_active = p_is_active,
            calibration_date = CASE WHEN p_is_active = 'Y' THEN SYSDATE ELSE calibration_date END
        WHERE meter_id = p_meter_id;
        
        p_rows_updated := SQL%ROWCOUNT;
        
        IF p_rows_updated = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Meter ' || p_meter_id || ' status updated to ' || p_is_active);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20007, 'Meter ID ' || p_meter_id || ' not found');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20008, 'Error updating meter status: ' || SQLERRM);
    END update_meter_status;

    -- PROCEDURE 3: Generate threshold alerts
    PROCEDURE generate_threshold_alerts(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_alert_count OUT NUMBER
    ) IS
        
        CURSOR threshold_breach_cur IS
            SELECT 
                b.building_id,
                m.meter_id,
                r.reading_date,
                r.consumption_kwh,
                t.warning_level_kwh,
                t.critical_level_kwh,
                CASE 
                    WHEN r.consumption_kwh > t.critical_level_kwh THEN 'CRITICAL'
                    WHEN r.consumption_kwh > t.warning_level_kwh THEN 'WARNING'
                END as alert_type
            FROM buildings b
            JOIN consumption_thresholds t ON b.building_id = t.building_id
            JOIN energy_meters m ON b.building_id = m.building_id
            JOIN consumption_readings r ON m.meter_id = r.meter_id
            WHERE t.is_active = 'Y'
              AND r.reading_date BETWEEN t.effective_date AND NVL(t.expiry_date, SYSDATE)
              AND r.reading_date = TRUNC(SYSDATE) -- Today's readings only
              AND (p_building_id IS NULL OR b.building_id = p_building_id)
              AND r.consumption_kwh > t.warning_level_kwh
              AND NOT EXISTS (
                  SELECT 1 FROM alerts a 
                  WHERE a.building_id = b.building_id 
                    AND a.meter_id = m.meter_id 
                    AND a.alert_type IN ('WARNING', 'CRITICAL')
                    AND TRUNC(a.alert_timestamp) = TRUNC(SYSDATE)
              );
              
        v_alert_rec threshold_breach_cur%ROWTYPE;
        v_alert_id alerts.alert_id%TYPE;
        
    BEGIN
        p_alert_count := 0;
        
        OPEN threshold_breach_cur;
        LOOP
            FETCH threshold_breach_cur INTO v_alert_rec;
            EXIT WHEN threshold_breach_cur%NOTFOUND;
            
            INSERT INTO alerts (
                alert_id, building_id, meter_id, alert_type, 
                consumption_value, threshold_value, severity_level,
                alert_message, status
            ) VALUES (
                seq_alerts_id.NEXTVAL, v_alert_rec.building_id, v_alert_rec.meter_id,
                v_alert_rec.alert_type, v_alert_rec.consumption_kwh,
                CASE 
                    WHEN v_alert_rec.alert_type = 'CRITICAL' THEN v_alert_rec.critical_level_kwh
                    ELSE v_alert_rec.warning_level_kwh
                END,
                CASE v_alert_rec.alert_type 
                    WHEN 'CRITICAL' THEN 'HIGH' 
                    ELSE 'MEDIUM' 
                END,
                'Automated ' || v_alert_rec.alert_type || ' alert: Consumption ' || 
                v_alert_rec.consumption_kwh || ' kWh exceeds ' || 
                CASE v_alert_rec.alert_type 
                    WHEN 'CRITICAL' THEN 'critical' 
                    ELSE 'warning' 
                END || ' level',
                'PENDING'
            )
            RETURNING alert_id INTO v_alert_id;
            
            p_alert_count := p_alert_count + 1;
            DBMS_OUTPUT.PUT_LINE('Generated alert ' || v_alert_id || ' for building ' || v_alert_rec.building_id);
            
        END LOOP;
        CLOSE threshold_breach_cur;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            IF threshold_breach_cur%ISOPEN THEN
                CLOSE threshold_breach_cur;
            END IF;
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20009, 'Error generating alerts: ' || SQLERRM);
    END generate_threshold_alerts;

    -- PROCEDURE 4: Archive old readings (BULK OPERATIONS) - FIXED
    PROCEDURE archive_old_readings(
        p_cutoff_date IN DATE,
        p_archived_count OUT NUMBER
    ) IS
        
        TYPE reading_id_tab IS TABLE OF consumption_readings.reading_id%TYPE;
        v_reading_ids reading_id_tab;
        
        CURSOR old_readings_cur IS
            SELECT reading_id
            FROM consumption_readings
            WHERE reading_date < p_cutoff_date
            AND reading_id NOT IN (SELECT reading_id FROM consumption_archive);
            
    BEGIN
        p_archived_count := 0;
        
        OPEN old_readings_cur;
        LOOP
            FETCH old_readings_cur BULK COLLECT INTO v_reading_ids LIMIT 1000;
            EXIT WHEN v_reading_ids.COUNT = 0;
            
            -- Bulk insert into archive with explicit column mapping
            FORALL i IN 1..v_reading_ids.COUNT
                INSERT INTO consumption_archive (
                    reading_id, meter_id, reading_date, reading_timestamp,
                    consumption_kwh, voltage_reading, current_reading, power_factor,
                    cost_amount, temperature_celsius, reading_quality, created_date
                )
                SELECT 
                    reading_id, meter_id, reading_date, reading_timestamp,
                    consumption_kwh, voltage_reading, current_reading, power_factor,
                    cost_amount, temperature_celsius, reading_quality, created_date
                FROM consumption_readings 
                WHERE reading_id = v_reading_ids(i);
                
            -- Bulk delete from main table
            FORALL i IN 1..v_reading_ids.COUNT
                DELETE FROM consumption_readings 
                WHERE reading_id = v_reading_ids(i);
                
            p_archived_count := p_archived_count + v_reading_ids.COUNT;
            DBMS_OUTPUT.PUT_LINE('Archived ' || v_reading_ids.COUNT || ' readings');
            
        END LOOP;
        CLOSE old_readings_cur;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Total archived: ' || p_archived_count || ' readings');
        
    EXCEPTION
        WHEN OTHERS THEN
            IF old_readings_cur%ISOPEN THEN
                CLOSE old_readings_cur;
            END IF;
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20010, 'Error archiving readings: ' || SQLERRM);
    END archive_old_readings;

    -- PROCEDURE 5: Update building thresholds - FIXED (removed last_updated)
    PROCEDURE update_building_thresholds(
        p_building_id IN buildings.building_id%TYPE,
        p_warning_level IN consumption_thresholds.warning_level_kwh%TYPE,
        p_critical_level IN consumption_thresholds.critical_level_kwh%TYPE,
        p_threshold_type IN consumption_thresholds.threshold_type%TYPE DEFAULT 'Daily'
    ) IS
        v_building_exists NUMBER;
    BEGIN
        -- Validate building exists
        SELECT COUNT(*) INTO v_building_exists
        FROM buildings WHERE building_id = p_building_id;
        
        IF v_building_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Building ID ' || p_building_id || ' not found');
        END IF;
        
        -- Validate critical > warning
        IF p_critical_level <= p_warning_level THEN
            RAISE threshold_violation;
        END IF;
        
        -- Update or insert threshold (removed last_updated reference)
        MERGE INTO consumption_thresholds t
        USING (SELECT p_building_id as building_id FROM dual) src
        ON (t.building_id = src.building_id AND t.threshold_type = p_threshold_type AND t.is_active = 'Y')
        WHEN MATCHED THEN
            UPDATE SET 
                warning_level_kwh = p_warning_level,
                critical_level_kwh = p_critical_level
                -- last_updated column doesn't exist in your table
        WHEN NOT MATCHED THEN
            INSERT (threshold_id, building_id, threshold_type, warning_level_kwh, 
                   critical_level_kwh, effective_date, is_active)
            VALUES (seq_thresholds_id.NEXTVAL, p_building_id, p_threshold_type, 
                   p_warning_level, p_critical_level, SYSDATE, 'Y');
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Thresholds updated for building ' || p_building_id);
        
    EXCEPTION
        WHEN threshold_violation THEN
            RAISE_APPLICATION_ERROR(-20003, 'Critical level must be greater than warning level');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20012, 'Error updating thresholds: ' || SQLERRM);
    END update_building_thresholds;

    -- FUNCTION 1: Calculate daily consumption
    FUNCTION calculate_daily_consumption(
        p_building_id IN buildings.building_id%TYPE,
        p_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER IS
        v_total_consumption NUMBER := 0;
    BEGIN
        SELECT SUM(r.consumption_kwh)
        INTO v_total_consumption
        FROM consumption_readings r
        JOIN energy_meters m ON r.meter_id = m.meter_id
        WHERE m.building_id = p_building_id
        AND TRUNC(r.reading_date) = TRUNC(p_date);
        
        RETURN NVL(v_total_consumption, 0);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calculate_daily_consumption;

    -- FUNCTION 2: Validate meter reading
    FUNCTION validate_meter_reading(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_consumption_kwh IN consumption_readings.consumption_kwh%TYPE
    ) RETURN VARCHAR2 IS
        v_capacity energy_meters.capacity_kw%TYPE;
        v_avg_consumption NUMBER;
        v_std_deviation NUMBER;
    BEGIN
        -- Get meter capacity
        SELECT capacity_kw INTO v_capacity
        FROM energy_meters WHERE meter_id = p_meter_id;
        
        -- Check if reading is within reasonable limits
        IF p_consumption_kwh < 0 THEN
            RETURN 'INVALID: Negative consumption';
        ELSIF p_consumption_kwh = 0 THEN
            RETURN 'WARNING: Zero consumption';
        ELSIF p_consumption_kwh > NVL(v_capacity, 1000) * 24 THEN
            RETURN 'SUSPICIOUS: Exceeds maximum capacity';
        END IF;
        
        -- Statistical validation (check if significantly different from average)
        BEGIN
            SELECT 
                AVG(consumption_kwh),
                STDDEV(consumption_kwh)
            INTO v_avg_consumption, v_std_deviation
            FROM consumption_readings
            WHERE meter_id = p_meter_id
            AND reading_date >= SYSDATE - 30;
            
            IF v_std_deviation > 0 AND ABS(p_consumption_kwh - v_avg_consumption) > (3 * v_std_deviation) THEN
                RETURN 'SUSPICIOUS: Statistical outlier';
            END IF;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- No historical data, skip statistical check
        END;
        
        RETURN 'VALID';
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'ERROR: Validation failed';
    END validate_meter_reading;

    -- FUNCTION 3: Get building consumption trend
    FUNCTION get_consumption_trend(
        p_building_id IN buildings.building_id%TYPE,
        p_days IN NUMBER DEFAULT 7
    ) RETURN VARCHAR2 IS
        v_current_avg NUMBER;
        v_previous_avg NUMBER;
        v_trend_percent NUMBER;
    BEGIN
        -- Current period average (last p_days/2 days)
        SELECT AVG(consumption_kwh)
        INTO v_current_avg
        FROM consumption_readings r
        JOIN energy_meters m ON r.meter_id = m.meter_id
        WHERE m.building_id = p_building_id
        AND r.reading_date BETWEEN SYSDATE - (p_days/2) AND SYSDATE;
        
        -- Previous period average (p_days/2 days before that)
        SELECT AVG(consumption_kwh)
        INTO v_previous_avg
        FROM consumption_readings r
        JOIN energy_meters m ON r.meter_id = m.meter_id
        WHERE m.building_id = p_building_id
        AND r.reading_date BETWEEN SYSDATE - p_days AND SYSDATE - (p_days/2);
        
        IF v_previous_avg = 0 OR v_previous_avg IS NULL THEN
            RETURN 'NO_DATA';
        END IF;
        
        v_trend_percent := ((v_current_avg - v_previous_avg) / v_previous_avg) * 100;
        
        IF v_trend_percent > 10 THEN
            RETURN 'INCREASING';
        ELSIF v_trend_percent < -10 THEN
            RETURN 'DECREASING';
        ELSE
            RETURN 'STABLE';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'ERROR';
    END get_consumption_trend;

    -- FUNCTION 4: Check maintenance due (returns BOOLEAN)
    FUNCTION is_maintenance_due(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN BOOLEAN IS
        v_last_maintenance DATE;
        v_maintenance_interval NUMBER := 180; -- 6 months
    BEGIN
        SELECT MAX(maintenance_date)
        INTO v_last_maintenance
        FROM maintenance_logs
        WHERE meter_id = p_meter_id;
        
        IF v_last_maintenance IS NULL THEN
            -- No maintenance record, check installation date
            SELECT installation_date
            INTO v_last_maintenance
            FROM energy_meters
            WHERE meter_id = p_meter_id;
        END IF;
        
        RETURN (SYSDATE - v_last_maintenance) >= v_maintenance_interval;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_maintenance_due;

    -- FUNCTION 5: Get meter efficiency rating (WINDOW FUNCTIONS)
    FUNCTION get_meter_efficiency(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN NUMBER IS
        v_efficiency_rating NUMBER;
    BEGIN
        WITH meter_stats AS (
            SELECT 
                meter_id,
                consumption_kwh,
                -- Window function: Rank readings by consumption
                RANK() OVER (PARTITION BY meter_id ORDER BY consumption_kwh DESC) as consumption_rank,
                -- Window function: Calculate running average
                AVG(consumption_kwh) OVER (PARTITION BY meter_id ORDER BY reading_date 
                                         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as weekly_avg,
                -- Window function: Compare to previous reading
                LAG(consumption_kwh) OVER (PARTITION BY meter_id ORDER BY reading_date) as prev_reading,
                -- Window function: Row number for sequencing
                ROW_NUMBER() OVER (PARTITION BY meter_id ORDER BY reading_date DESC) as recency_rank
            FROM consumption_readings
            WHERE reading_date >= SYSDATE - 30
        ),
        efficiency_calc AS (
            SELECT 
                meter_id,
                -- Calculate stability (lower variance = better efficiency)
                100 - (STDDEV(consumption_kwh) / NULLIF(AVG(consumption_kwh), 0) * 100) as stability_score,
                -- Calculate consistency (how often readings are within expected range)
                COUNT(CASE WHEN ABS(consumption_kwh - weekly_avg) / NULLIF(weekly_avg, 0) < 0.2 THEN 1 END) 
                / NULLIF(COUNT(*), 0) * 100 as consistency_score
            FROM meter_stats
            WHERE recency_rank <= 20  -- Last 20 readings
            GROUP BY meter_id
        )
        SELECT (stability_score * 0.6 + consistency_score * 0.4)
        INTO v_efficiency_rating
        FROM efficiency_calc
        WHERE meter_id = p_meter_id;
        
        RETURN NVL(v_efficiency_rating, 50); -- Default rating if no data
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 50; -- Default average rating
    END get_meter_efficiency;

END energy_monitoring_pkg;
/