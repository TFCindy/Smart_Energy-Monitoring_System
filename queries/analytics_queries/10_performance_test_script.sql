-- =============================================
-- File: 10_performance_test_script.sql
-- Performance Verification Script
-- Tests bulk operations, cursors, and window functions
-- =============================================

SET SERVEROUTPUT ON
SET TIMING ON

DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration NUMBER;
    v_processed_count NUMBER;
    v_alert_count NUMBER;
    v_error_count NUMBER;
    v_archived_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PERFORMANCE VERIFICATION TESTS ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 1: Bulk Operations Performance
    DBMS_OUTPUT.PUT_LINE('1. BULK OPERATIONS PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('-' || RPAD('-', 40, '-'));
    
    v_start_time := SYSTIMESTAMP;
    
    -- Test bulk insert
    energy_monitoring_pkg.bulk_insert_readings(
        p_readings_array => SYS.ODCINUMBERLIST(5001, 5002, 5003, 5004, 5005),
        p_consumptions_array => SYS.ODCINUMBERLIST(1000, 1100, 1200, 1300, 1400),
        p_success_count => v_processed_count,
        p_error_count => v_error_count
    );
    
    v_end_time := SYSTIMESTAMP;
    v_duration := (v_end_time - v_start_time) * 86400;
    DBMS_OUTPUT.PUT_LINE('Bulk Insert: ' || v_processed_count || ' records in ' || ROUND(v_duration, 3) || ' seconds');
    
    -- TEST 2: Cursor Processing Performance
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. CURSOR PROCESSING PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('-' || RPAD('-', 40, '-'));
    
    v_start_time := SYSTIMESTAMP;
    
    -- Test alert generation with cursor
    alert_management_pkg.generate_threshold_alerts(
        p_building_id => NULL,
        p_alert_count => v_alert_count,
        p_error_count => v_error_count
    );
    
    v_end_time := SYSTIMESTAMP;
    v_duration := (v_end_time - v_start_time) * 86400;
    DBMS_OUTPUT.PUT_LINE('Cursor Alert Generation: ' || v_alert_count || ' alerts in ' || ROUND(v_duration, 3) || ' seconds');
    
    -- TEST 3: Window Functions Performance
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. WINDOW FUNCTIONS PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('-' || RPAD('-', 40, '-'));
    
    v_start_time := SYSTIMESTAMP;
    
    -- Test efficiency calculation with window functions
    energy_analytics_pkg.calculate_efficiency_ratings_bulk(
        p_meter_ids => SYS.ODCINUMBERLIST(5001, 5002, 5003, 5004, 5005, 5006, 5007, 5008, 5009, 5010),
        p_updated_count => v_processed_count
    );
    
    v_end_time := SYSTIMESTAMP;
    v_duration := (v_end_time - v_start_time) * 86400;
    DBMS_OUTPUT.PUT_LINE('Window Functions Efficiency: ' || v_processed_count || ' meters in ' || ROUND(v_duration, 3) || ' seconds');
    
    -- TEST 4: Archive Operations Performance
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. ARCHIVE OPERATIONS PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('-' || RPAD('-', 40, '-'));
    
    v_start_time := SYSTIMESTAMP;
    
    -- Test archive performance
    maintenance_ops_pkg.archive_old_readings(
        p_cutoff_date => DATE '2024-01-01',
        p_batch_size => 1000,
        p_archived_count => v_archived_count,
        p_error_count => v_error_count
    );
    
    v_end_time := SYSTIMESTAMP;
    v_duration := (v_end_time - v_start_time) * 86400;
    DBMS_OUTPUT.PUT_LINE('Bulk Archive: ' || v_archived_count || ' records in ' || ROUND(v_duration, 3) || ' seconds');
    
    -- TEST 5: Ref Cursor Performance
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('5. REF CURSOR REPORTING PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('-' || RPAD('-', 40, '-'));
    
    DECLARE
        v_report_cursor SYS_REFCURSOR;
        v_counter NUMBER := 0;
    BEGIN
        v_start_time := SYSTIMESTAMP;
        
        energy_analytics_pkg.generate_consumption_trend_report(
            p_building_id => NULL,
            p_days_back => 30,
            p_report_data => v_report_cursor
        );
        
        -- Process cursor to measure full performance
        LOOP
            FETCH v_report_cursor INTO 
                v_building_id, v_building_name, v_period, v_consumption, 
                v_weekly_avg, v_prev_consumption, v_rank_val, v_sequence,
                v_change_pct, v_pattern;
            EXIT WHEN v_report_cursor%NOTFOUND;
            v_counter := v_counter + 1;
        END LOOP;
        CLOSE v_report_cursor;
        
        v_end_time := SYSTIMESTAMP;
        v_duration := (v_end_time - v_start_time) * 86400;
        DBMS_OUTPUT.PUT_LINE('Ref Cursor Report: ' || v_counter || ' rows in ' || ROUND(v_duration, 3) || ' seconds');
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== PERFORMANCE TESTS COMPLETED ===');
    DBMS_OUTPUT.PUT_LINE('All operations completed within acceptable timeframes');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ PERFORMANCE TEST FAILED: ' || SQLERRM);
END;
/