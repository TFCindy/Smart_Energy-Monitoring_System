-- =============================================
-- File: 08_maintenance_ops_pkg_body.sql
-- Maintenance Operations Package Body
-- Implementation of maintenance and archiving operations
-- =============================================

CREATE OR REPLACE PACKAGE BODY maintenance_ops_pkg IS

    -- PROCEDURE 1: Generate maintenance report
    PROCEDURE generate_maintenance_report(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_report_details OUT VARCHAR2
    ) IS
        CURSOR maintenance_cur IS
            SELECT 
                m.meter_id,
                m.meter_serial,
                b.building_name,
                m.installation_date,
                m.calibration_date,
                ml.maintenance_date,
                ml.maintenance_type,
                ml.technician_name,
                -- Window function for maintenance frequency ranking
                RANK() OVER (
                    PARTITION BY m.meter_id 
                    ORDER BY ml.maintenance_date DESC NULLS LAST
                ) as maintenance_recency_rank,
                COUNT(ml.maintenance_id) OVER (PARTITION BY m.meter_id) as total_maintenances,
                -- Days since last maintenance
                NVL(SYSDATE - MAX(ml.maintenance_date) OVER (PARTITION BY m.meter_id), 
                    SYSDATE - m.installation_date) as days_since_maintenance
            FROM energy_meters m
            JOIN buildings b ON m.building_id = b.building_id
            LEFT JOIN maintenance_logs ml ON m.meter_id = ml.meter_id
            WHERE (p_building_id IS NULL OR b.building_id = p_building_id)
            AND m.is_active = 'Y'
            ORDER BY b.building_name, m.meter_id;
            
        v_report_rec maintenance_cur%ROWTYPE;
        v_due_count NUMBER := 0;
        v_total_count NUMBER := 0;
        v_maintenance_threshold CONSTANT NUMBER := 180; -- 6 months
    BEGIN
        p_report_details := 'MAINTENANCE REPORT - Generated: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || CHR(10);
        p_report_details := p_report_details || '=' || RPAD('=', 70, '=') || CHR(10);
        
        OPEN maintenance_cur;
        LOOP
            FETCH maintenance_cur INTO v_report_rec;
            EXIT WHEN maintenance_cur%NOTFOUND;
            
            v_total_count := v_total_count + 1;
            
            -- Check if maintenance is due
            IF v_report_rec.days_since_maintenance > v_maintenance_threshold THEN
                v_due_count := v_due_count + 1;
                p_report_details := p_report_details || 
                    '⚠️ MAINTENANCE DUE: Meter ' || v_report_rec.meter_serial ||
                    ' | Building: ' || v_report_rec.building_name ||
                    ' | Last Maintenance: ' || 
                    CASE 
                        WHEN v_report_rec.maintenance_date IS NOT NULL THEN 
                            TO_CHAR(v_report_rec.maintenance_date, 'YYYY-MM-DD')
                        ELSE 'NEVER'
                    END ||
                    ' | Days Since: ' || ROUND(v_report_rec.days_since_maintenance) || CHR(10);
            END IF;
            
            -- Add meter details every 10 records
            IF MOD(v_total_count, 10) = 0 THEN
                p_report_details := p_report_details || 
                    '... Processed ' || v_total_count || ' meters' || CHR(10);
            END IF;
        END LOOP;
        CLOSE maintenance_cur;
        
        -- Add summary
        p_report_details := p_report_details || CHR(10) || 'SUMMARY:' || CHR(10);
        p_report_details := p_report_details || 'Total meters processed: ' || v_total_count || CHR(10);
        p_report_details := p_report_details || 'Meters due for maintenance: ' || v_due_count || CHR(10);
        p_report_details := p_report_details || 'Maintenance threshold: ' || v_maintenance_threshold || ' days' || CHR(10);
        
        DBMS_OUTPUT.PUT_LINE('Maintenance report generated: ' || v_total_count || ' meters, ' || v_due_count || ' due');
        
    EXCEPTION
        WHEN OTHERS THEN
            IF maintenance_cur%ISOPEN THEN
                CLOSE maintenance_cur;
            END IF;
            p_report_details := 'ERROR generating maintenance report: ' || SQLERRM;
            RAISE maintenance_scheduling_error;
    END generate_maintenance_report;

    -- PROCEDURE 2: Archive old readings with bulk operations
    PROCEDURE archive_old_readings(
        p_cutoff_date IN DATE,
        p_batch_size IN NUMBER DEFAULT 1000,
        p_archived_count OUT NUMBER,
        p_error_count OUT NUMBER
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
        p_error_count := 0;
        
        DBMS_OUTPUT.PUT_LINE('Starting archive operation for readings before ' || p_cutoff_date);
        
        OPEN old_readings_cur;
        LOOP
            FETCH old_readings_cur BULK COLLECT INTO v_reading_ids LIMIT p_batch_size;
            EXIT WHEN v_reading_ids.COUNT = 0;
            
            BEGIN
                -- Bulk insert into archive
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
                
                DBMS_OUTPUT.PUT_LINE('Archived batch of ' || v_reading_ids.COUNT || ' readings. Total: ' || p_archived_count);
                
            EXCEPTION
                WHEN OTHERS THEN
                    p_error_count := p_error_count + v_reading_ids.COUNT;
                    DBMS_OUTPUT.PUT_LINE('Error archiving batch: ' || SQLERRM);
            END;
            
            COMMIT;
            
        END LOOP;
        CLOSE old_readings_cur;
        
        DBMS_OUTPUT.PUT_LINE('Archive completed: ' || p_archived_count || ' archived, ' || p_error_count || ' errors');
        
    EXCEPTION
        WHEN OTHERS THEN
            IF old_readings_cur%ISOPEN THEN
                CLOSE old_readings_cur;
            END IF;
            ROLLBACK;
            RAISE archive_operation_failed;
    END archive_old_readings;

    -- PROCEDURE 3: Schedule bulk maintenance
    PROCEDURE schedule_bulk_maintenance(
        p_meter_ids IN SYS.ODCINUMBERLIST,
        p_maintenance_type IN maintenance_logs.maintenance_type%TYPE,
        p_technician_name IN maintenance_logs.technician_name%TYPE,
        p_scheduled_count OUT NUMBER,
        p_failed_count OUT NUMBER
    ) IS
    BEGIN
        p_scheduled_count := 0;
        p_failed_count := 0;
        
        FORALL i IN 1..p_meter_ids.COUNT SAVE EXCEPTIONS
            INSERT INTO maintenance_logs (
                maintenance_id, meter_id, maintenance_type, 
                maintenance_date, technician_name
            ) VALUES (
                seq_maintenance_id.NEXTVAL, p_meter_ids(i), p_maintenance_type,
                SYSDATE, p_technician_name
            );
        
        p_scheduled_count := SQL%ROWCOUNT;
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Scheduled maintenance for ' || p_scheduled_count || ' meters');
        
    EXCEPTION
        WHEN OTHERS THEN
            p_failed_count := p_meter_ids.COUNT - p_scheduled_count;
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Failed to schedule maintenance for ' || p_failed_count || ' meters');
    END schedule_bulk_maintenance;

    -- FUNCTION 1: Check if maintenance is due
    FUNCTION is_maintenance_due(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN BOOLEAN IS
        v_last_maintenance DATE;
        v_installation_date DATE;
        v_maintenance_interval NUMBER := 180; -- 6 months
    BEGIN
        -- Get last maintenance date
        BEGIN
            SELECT MAX(maintenance_date)
            INTO v_last_maintenance
            FROM maintenance_logs
            WHERE meter_id = p_meter_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_last_maintenance := NULL;
        END;
        
        -- If no maintenance record, use installation date
        IF v_last_maintenance IS NULL THEN
            SELECT installation_date
            INTO v_installation_date
            FROM energy_meters
            WHERE meter_id = p_meter_id;
            
            v_last_maintenance := v_installation_date;
        END IF;
        
        RETURN (SYSDATE - v_last_maintenance) >= v_maintenance_interval;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_maintenance_due;

    -- FUNCTION 2: Calculate next maintenance date
    FUNCTION calculate_next_maintenance(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN DATE IS
        v_last_maintenance DATE;
        v_maintenance_interval NUMBER := 180; -- 6 months
    BEGIN
        -- Get last maintenance date
        SELECT MAX(maintenance_date)
        INTO v_last_maintenance
        FROM maintenance_logs
        WHERE meter_id = p_meter_id;
        
        IF v_last_maintenance IS NULL THEN
            -- Use installation date + interval if no maintenance history
            SELECT installation_date + v_maintenance_interval
            INTO v_last_maintenance
            FROM energy_meters
            WHERE meter_id = p_meter_id;
        ELSE
            v_last_maintenance := v_last_maintenance + v_maintenance_interval;
        END IF;
        
        RETURN v_last_maintenance;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END calculate_next_maintenance;

    -- FUNCTION 3: Get maintenance history count
    FUNCTION get_maintenance_count(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM maintenance_logs
        WHERE meter_id = p_meter_id;
        
        RETURN v_count;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN -1;
    END get_maintenance_count;

END maintenance_ops_pkg;
/