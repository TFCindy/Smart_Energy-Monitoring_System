-- =============================================
-- File: 04_alert_management_pkg_body.sql
-- Alert Management Package Body
-- Implementation of alert generation and threshold management
-- =============================================

CREATE OR REPLACE PACKAGE BODY alert_management_pkg IS

    -- PROCEDURE 1: Generate threshold alerts
    PROCEDURE generate_threshold_alerts(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_alert_count OUT NUMBER,
        p_error_count OUT NUMBER
    ) IS
        CURSOR threshold_breach_cur IS
            SELECT 
                b.building_id,
                m.meter_id,
                r.reading_id,
                r.reading_date,
                r.consumption_kwh,
                t.threshold_type,
                t.warning_level_kwh,
                t.critical_level_kwh,
                -- Window function to rank readings by severity
                RANK() OVER (
                    PARTITION BY b.building_id 
                    ORDER BY (r.consumption_kwh - t.critical_level_kwh) DESC
                ) as severity_rank
            FROM buildings b
            JOIN consumption_thresholds t ON b.building_id = t.building_id
            JOIN energy_meters m ON b.building_id = m.building_id
            JOIN consumption_readings r ON m.meter_id = r.meter_id
            WHERE t.is_active = 'Y'
              AND r.reading_date BETWEEN t.effective_date AND NVL(t.expiry_date, SYSDATE)
              AND (p_building_id IS NULL OR b.building_id = p_building_id)
              AND r.consumption_kwh > t.warning_level_kwh
              AND NOT EXISTS (
                  SELECT 1 FROM alerts a 
                  WHERE a.building_id = b.building_id 
                    AND a.meter_id = m.meter_id 
                    AND a.alert_type IN ('WARNING', 'CRITICAL')
                    AND TRUNC(a.alert_timestamp) = TRUNC(SYSDATE)
                    AND a.status = 'PENDING'
              );
              
        v_alert_rec threshold_breach_cur%ROWTYPE;
        v_alert_id alerts.alert_id%TYPE;
        v_alert_type alerts.alert_type%TYPE;
        v_severity alerts.severity_level%TYPE;
    BEGIN
        p_alert_count := 0;
        p_error_count := 0;
        
        DBMS_OUTPUT.PUT_LINE('Starting alert generation...');
        
        OPEN threshold_breach_cur;
        LOOP
            FETCH threshold_breach_cur INTO v_alert_rec;
            EXIT WHEN threshold_breach_cur%NOTFOUND;
            
            BEGIN
                -- Determine alert type and severity
                IF v_alert_rec.consumption_kwh > v_alert_rec.critical_level_kwh THEN
                    v_alert_type := 'CRITICAL';
                    v_severity := 'HIGH';
                ELSE
                    v_alert_type := 'WARNING';
                    v_severity := 'MEDIUM';
                END IF;
                
                -- Insert alert
                INSERT INTO alerts (
                    alert_id, building_id, meter_id, alert_type, 
                    consumption_value, threshold_value, severity_level,
                    alert_message, status, alert_timestamp
                ) VALUES (
                    seq_alerts_id.NEXTVAL, v_alert_rec.building_id, v_alert_rec.meter_id,
                    v_alert_type, v_alert_rec.consumption_kwh,
                    CASE v_alert_type 
                        WHEN 'CRITICAL' THEN v_alert_rec.critical_level_kwh
                        ELSE v_alert_rec.warning_level_kwh
                    END,
                    v_severity,
                    'Automated ' || v_alert_type || ' alert: Consumption ' || 
                    v_alert_rec.consumption_kwh || ' kWh exceeds threshold',
                    'PENDING', SYSTIMESTAMP
                )
                RETURNING alert_id INTO v_alert_id;
                
                p_alert_count := p_alert_count + 1;
                
                IF MOD(p_alert_count, 5) = 0 THEN
                    DBMS_OUTPUT.PUT_LINE('Generated ' || p_alert_count || ' alerts...');
                END IF;
                
            EXCEPTION
                WHEN OTHERS THEN
                    p_error_count := p_error_count + 1;
                    DBMS_OUTPUT.PUT_LINE('Error creating alert: ' || SQLERRM);
            END;
        END LOOP;
        CLOSE threshold_breach_cur;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Alert generation completed: ' || p_alert_count || ' alerts, ' || p_error_count || ' errors');
        
    EXCEPTION
        WHEN OTHERS THEN
            IF threshold_breach_cur%ISOPEN THEN
                CLOSE threshold_breach_cur;
            END IF;
            p_alert_count := 0;
            p_error_count := 1;
            ROLLBACK;
            RAISE alert_generation_failed;
    END generate_threshold_alerts;

    -- PROCEDURE 2: Update building thresholds
    PROCEDURE update_building_thresholds(
        p_building_id IN buildings.building_id%TYPE,
        p_threshold_type IN consumption_thresholds.threshold_type%TYPE,
        p_warning_level IN consumption_thresholds.warning_level_kwh%TYPE,
        p_critical_level IN consumption_thresholds.critical_level_kwh%TYPE,
        p_effective_date IN consumption_thresholds.effective_date%TYPE DEFAULT SYSDATE,
        p_rows_affected OUT NUMBER,
        p_status_message OUT VARCHAR2
    ) IS
        v_building_exists NUMBER;
        v_config_valid BOOLEAN;
    BEGIN
        -- Validate building exists
        SELECT COUNT(*) INTO v_building_exists
        FROM buildings WHERE building_id = p_building_id;
        
        IF v_building_exists = 0 THEN
            p_status_message := 'ERROR: Building not found';
            p_rows_affected := 0;
            RETURN;
        END IF;
        
        -- Validate threshold configuration
        v_config_valid := validate_threshold_config(p_warning_level, p_critical_level);
        IF NOT v_config_valid THEN
            p_status_message := 'ERROR: Critical level must be greater than warning level';
            p_rows_affected := 0;
            RETURN;
        END IF;
        
        -- Update or insert threshold
        MERGE INTO consumption_thresholds t
        USING (SELECT p_building_id as building_id FROM dual) src
        ON (t.building_id = src.building_id AND t.threshold_type = p_threshold_type)
        WHEN MATCHED THEN
            UPDATE SET 
                warning_level_kwh = p_warning_level,
                critical_level_kwh = p_critical_level,
                effective_date = p_effective_date,
                is_active = 'Y'
        WHEN NOT MATCHED THEN
            INSERT (threshold_id, building_id, threshold_type, warning_level_kwh, 
                   critical_level_kwh, effective_date, is_active)
            VALUES (seq_thresholds_id.NEXTVAL, p_building_id, p_threshold_type, 
                   p_warning_level, p_critical_level, p_effective_date, 'Y');
        
        p_rows_affected := SQL%ROWCOUNT;
        COMMIT;
        p_status_message := 'SUCCESS: Thresholds updated for building ' || p_building_id;
        
    EXCEPTION
        WHEN OTHERS THEN
            p_rows_affected := 0;
            p_status_message := 'ERROR: ' || SQLERRM;
            ROLLBACK;
            RAISE;
    END update_building_thresholds;

    -- PROCEDURE 3: Bulk resolve alerts
    PROCEDURE bulk_resolve_alerts(
        p_alert_ids IN SYS.ODCINUMBERLIST,
        p_resolved_by IN alerts.resolved_by%TYPE,
        p_resolved_count OUT NUMBER,
        p_failed_count OUT NUMBER
    ) IS
    BEGIN
        p_resolved_count := 0;
        p_failed_count := 0;
        
        FORALL i IN 1..p_alert_ids.COUNT SAVE EXCEPTIONS
            UPDATE alerts 
            SET status = 'RESOLVED',
                resolved_date = SYSDATE,
                resolved_by = p_resolved_by
            WHERE alert_id = p_alert_ids(i)
            AND status = 'PENDING';
        
        p_resolved_count := SQL%ROWCOUNT;
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            p_failed_count := p_alert_ids.COUNT - p_resolved_count;
            ROLLBACK;
    END bulk_resolve_alerts;

    -- FUNCTION 1: Check threshold breach
    FUNCTION check_threshold_breach(
        p_building_id IN buildings.building_id%TYPE,
        p_consumption_kwh IN NUMBER,
        p_threshold_type IN consumption_thresholds.threshold_type%TYPE DEFAULT 'Daily'
    ) RETURN VARCHAR2 IS
        v_warning_level consumption_thresholds.warning_level_kwh%TYPE;
        v_critical_level consumption_thresholds.critical_level_kwh%TYPE;
    BEGIN
        SELECT warning_level_kwh, critical_level_kwh
        INTO v_warning_level, v_critical_level
        FROM consumption_thresholds
        WHERE building_id = p_building_id
        AND threshold_type = p_threshold_type
        AND is_active = 'Y'
        AND effective_date <= SYSDATE
        AND (expiry_date IS NULL OR expiry_date >= SYSDATE);
        
        IF p_consumption_kwh > v_critical_level THEN
            RETURN 'CRITICAL';
        ELSIF p_consumption_kwh > v_warning_level THEN
            RETURN 'WARNING';
        ELSE
            RETURN 'NORMAL';
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NO_THRESHOLDS';
        WHEN OTHERS THEN
            RETURN 'ERROR';
    END check_threshold_breach;

    -- FUNCTION 2: Get active alert count
    FUNCTION get_active_alert_count(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL
    ) RETURN NUMBER IS
        v_alert_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_alert_count
        FROM alerts
        WHERE status = 'PENDING'
        AND (p_building_id IS NULL OR building_id = p_building_id);
        
        RETURN v_alert_count;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END get_active_alert_count;

    -- FUNCTION 3: Validate threshold configuration
    FUNCTION validate_threshold_config(
        p_warning_level IN consumption_thresholds.warning_level_kwh%TYPE,
        p_critical_level IN consumption_thresholds.critical_level_kwh%TYPE
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN (p_warning_level > 0 AND p_critical_level > p_warning_level);
    END validate_threshold_config;

END alert_management_pkg;
/