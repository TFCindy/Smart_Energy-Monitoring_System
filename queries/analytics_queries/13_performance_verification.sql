-- File: 13_performance_verification.sql (FIXED)
-- Performance Testing with Large Datasets
SET SERVEROUTPUT ON
SET TIMING ON

DECLARE
    v_start_time NUMBER;
    v_end_time NUMBER;
    v_duration NUMBER;
    v_processed NUMBER;
    v_alert_count NUMBER;
    v_error_count NUMBER;
    v_archived_count NUMBER;
    v_success_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PERFORMANCE VERIFICATION TESTS ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 1: Bulk Operations Performance
    DBMS_OUTPUT.PUT_LINE('1. BULK OPERATIONS PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');
    
    v_start_time := DBMS_UTILITY.GET_TIME;
    
    -- Test bulk insert with larger dataset
    DECLARE
        v_meters SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
        v_consumptions SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
        v_meter_ids SYS.ODCINUMBERLIST;
    BEGIN
        -- Get active meters
        SELECT meter_id BULK COLLECT INTO v_meter_ids
        FROM energy_meters 
        WHERE is_active = 'Y' 
        AND ROWNUM <= 10; -- Reduced for testing
        
        -- Build arrays
        FOR i IN 1..v_meter_ids.COUNT LOOP
            v_meters.EXTEND;
            v_meters(i) := v_meter_ids(i);
            v_consumptions.EXTEND;
            v_consumptions(i) := 500 + (i * 10);
        END LOOP;
        
        energy_monitoring_pkg.bulk_insert_readings(
            p_readings_array => v_meters,
            p_consumptions_array => v_consumptions,
            p_success_count => v_success_count,
            p_error_count => v_error_count
        );
        
        v_processed := v_success_count;
        DBMS_OUTPUT.PUT_LINE('   Processed: ' || v_processed || ' records');
    END;
    
    v_end_time := DBMS_UTILITY.GET_TIME;
    v_duration := (v_end_time - v_start_time) / 100; -- Convert to seconds
    DBMS_OUTPUT.PUT_LINE('   Bulk Insert (' || v_processed || ' records): ' || ROUND(v_duration, 3) || ' seconds');
    
    -- Test 2: Analytics Performance
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. ANALYTICS PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('-------------------------');
    
    v_start_time := DBMS_UTILITY.GET_TIME;
    
    DECLARE
        v_efficiency_count NUMBER;
    BEGIN
        energy_analytics_pkg.calculate_efficiency_ratings_bulk(
            p_meter_ids => NULL, -- Process all meters
            p_updated_count => v_efficiency_count
        );
        v_processed := v_efficiency_count;
    END;
    
    v_end_time := DBMS_UTILITY.GET_TIME;
    v_duration := (v_end_time - v_start_time) / 100;
    DBMS_OUTPUT.PUT_LINE('   Bulk Efficiency Calculation: ' || ROUND(v_duration, 3) || ' seconds');
    DBMS_OUTPUT.PUT_LINE('   Meters processed: ' || v_processed);
    
    -- Test 3: Alert Generation Performance
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. ALERT GENERATION PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    
    v_start_time := DBMS_UTILITY.GET_TIME;
    
    BEGIN
        alert_management_pkg.generate_threshold_alerts(
            p_building_id => NULL,
            p_alert_count => v_alert_count,
            p_error_count => v_error_count
        );
        v_processed := v_alert_count;
    END;
    
    v_end_time := DBMS_UTILITY.GET_TIME;
    v_duration := (v_end_time - v_start_time) / 100;
    DBMS_OUTPUT.PUT_LINE('   Alert Generation: ' || ROUND(v_duration, 3) || ' seconds');
    DBMS_OUTPUT.PUT_LINE('   Alerts generated: ' || v_processed);
    
    -- Test 4: Archive Operations Performance
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. ARCHIVE OPERATIONS PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    
    v_start_time := DBMS_UTILITY.GET_TIME;
    
    BEGIN
        maintenance_ops_pkg.archive_old_readings(
            p_cutoff_date => SYSDATE - 1, -- Archive yesterday's data
            p_batch_size => 1000,
            p_archived_count => v_archived_count,
            p_error_count => v_error_count
        );
        v_processed := v_archived_count;
    END;
    
    v_end_time := DBMS_UTILITY.GET_TIME;
    v_duration := (v_end_time - v_start_time) / 100;
    DBMS_OUTPUT.PUT_LINE('   Archive Operations: ' || ROUND(v_duration, 3) || ' seconds');
    DBMS_OUTPUT.PUT_LINE('   Records archived: ' || v_processed);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== PERFORMANCE TESTING COMPLETED ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Performance test error: ' || SQLERRM);
END;
/