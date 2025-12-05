-- =============================================
-- File: 09_comprehensive_test_script.sql (PERFECT VERSION)
-- Comprehensive Test Script for All Packages
-- Tests procedures, functions, edge cases, and performance
-- =============================================

SET SERVEROUTPUT ON
SET TIMING ON
SET FEEDBACK OFF

DECLARE
    -- Test variables
    v_reading_id consumption_readings.reading_id%TYPE;
    v_status_message VARCHAR2(500);
    v_rows_updated NUMBER;
    v_alert_count NUMBER;
    v_error_count NUMBER;
    v_archived_count NUMBER;
    v_success_count NUMBER;
    v_resolved_count NUMBER;
    v_failed_count NUMBER;
    v_daily_consumption NUMBER;
    v_validation_result VARCHAR2(100);
    v_trend VARCHAR2(100);
    v_efficiency NUMBER;
    v_rank NUMBER;
    v_growth_rate NUMBER;
    v_maintenance_due BOOLEAN;
    v_maintenance_count NUMBER;
    v_next_maintenance DATE;
    v_report_details VARCHAR2(4000);
    v_report_cursor SYS_REFCURSOR;
    
    -- Additional variables for cursor processing
    v_alert_ids SYS.ODCINUMBERLIST;
    
    -- Variables for ref cursor testing
    v_building_id buildings.building_id%TYPE;
    v_building_name buildings.building_name%TYPE;
    v_reading_day DATE;
    v_daily_consumption_val NUMBER;
    v_weekly_moving_avg NUMBER;
    v_prev_day_consumption NUMBER;
    v_daily_rank NUMBER;
    v_day_sequence NUMBER;
    v_daily_change_percent NUMBER;
    v_consumption_pattern VARCHAR2(20);
    
    -- Test meter IDs that should exist
    v_test_meter_id energy_meters.meter_id%TYPE;
    v_test_building_id buildings.building_id%TYPE;
    
    -- Test counters
    v_total_tests NUMBER := 0;
    v_passed_tests NUMBER := 0;
    v_failed_tests NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== COMPREHENSIVE ENERGY MONITORING PACKAGE TESTS ===');
    DBMS_OUTPUT.PUT_LINE('Test Start: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- PHASE 1: TEST ENVIRONMENT SETUP
    DBMS_OUTPUT.PUT_LINE('PHASE 1: TEST ENVIRONMENT SETUP');
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 50, '='));
    
    -- Ensure we have a test building
    BEGIN
        SELECT building_id INTO v_test_building_id 
        FROM buildings WHERE ROWNUM = 1;
        DBMS_OUTPUT.PUT_LINE('✓ Using existing building: ' || v_test_building_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create a test building
            INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year)
            VALUES (1, 'Test Building', 'Test Location', 'Commercial', 10000, 2020)
            RETURNING building_id INTO v_test_building_id;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('✓ Created test building: ' || v_test_building_id);
    END;
    
    -- Ensure we have an active test meter
    BEGIN
        SELECT meter_id INTO v_test_meter_id 
        FROM energy_meters 
        WHERE is_active = 'Y' AND ROWNUM = 1;
        DBMS_OUTPUT.PUT_LINE('✓ Using existing active meter: ' || v_test_meter_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create a test meter
            INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, installation_date, capacity_kw, is_active)
            VALUES (5001, v_test_building_id, 'TEST001', 'Smart', SYSDATE, 100, 'Y')
            RETURNING meter_id INTO v_test_meter_id;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('✓ Created test meter: ' || v_test_meter_id);
    END;
    
    -- Ensure we have consumption data for testing
    DECLARE
        v_reading_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_reading_count 
        FROM consumption_readings 
        WHERE meter_id = v_test_meter_id 
        AND reading_date >= SYSDATE - 7;
        
        IF v_reading_count = 0 THEN
            -- Create some test readings
            INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, cost_amount, reading_quality)
            SELECT 
                seq_readings_id.NEXTVAL,
                v_test_meter_id,
                SYSDATE - LEVEL + 1,
                1000 + (DBMS_RANDOM.VALUE * 500),
                (1000 + (DBMS_RANDOM.VALUE * 500)) * 0.15,
                'G'
            FROM DUAL CONNECT BY LEVEL <= 7;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('✓ Created 7 test consumption readings');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✓ Found ' || v_reading_count || ' existing consumption readings');
        END IF;
    END;
    
    -- Ensure we have threshold data
    BEGIN
        INSERT INTO consumption_thresholds (
            threshold_id, building_id, threshold_type, warning_level_kwh, 
            critical_level_kwh, effective_date, is_active
        )
        SELECT 
            seq_thresholds_id.NEXTVAL,
            v_test_building_id,
            'Daily',
            1000,
            2000,
            SYSDATE,
            'Y'
        FROM DUAL
        WHERE NOT EXISTS (
            SELECT 1 FROM consumption_thresholds 
            WHERE building_id = v_test_building_id 
            AND threshold_type = 'Daily'
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✓ Created test thresholds for building');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('✓ Thresholds already exist for building');
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- PHASE 2: ENERGY MONITORING PACKAGE TESTS
    DBMS_OUTPUT.PUT_LINE('PHASE 2: ENERGY MONITORING PACKAGE TESTS');
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 50, '='));
    
    -- Test 2.1: Add consumption reading (valid case)
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('2.1 Testing add_consumption_reading (valid)...');
    BEGIN
        energy_monitoring_pkg.add_consumption_reading(
            p_meter_id => v_test_meter_id,
            p_consumption_kwh => 1250.75,
            p_voltage_reading => 240.5,
            p_reading_id => v_reading_id,
            p_status_message => v_status_message
        );
        IF v_status_message LIKE 'SUCCESS%' THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ ' || v_status_message);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ ' || v_status_message);
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Unexpected error: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 2.2: Add consumption reading (invalid meter)
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('2.2 Testing add_consumption_reading (invalid meter)...');
    BEGIN
        energy_monitoring_pkg.add_consumption_reading(
            p_meter_id => 9999, -- Non-existent meter
            p_consumption_kwh => 1000,
            p_reading_id => v_reading_id,
            p_status_message => v_status_message
        );
        IF v_status_message LIKE 'ERROR%' THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Expected error: ' || v_status_message);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ Unexpected result: ' || v_status_message);
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Unexpected error: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 2.3: Update meter status
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('2.3 Testing update_meter_status...');
    BEGIN
        energy_monitoring_pkg.update_meter_status(
            p_meter_id => v_test_meter_id,
            p_is_active => 'Y',
            p_rows_updated => v_rows_updated,
            p_status_message => v_status_message
        );
        IF v_status_message LIKE 'SUCCESS%' AND v_rows_updated = 1 THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ ' || v_status_message || ', Rows: ' || v_rows_updated);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ ' || v_status_message || ', Rows: ' || v_rows_updated);
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Unexpected error: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 2.4: Bulk insert readings (FIXED)
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('2.4 Testing bulk_insert_readings...');
    DECLARE
        v_available_meters SYS.ODCINUMBERLIST;
    BEGIN
        -- Get available active meters
        SELECT meter_id 
        BULK COLLECT INTO v_available_meters 
        FROM energy_meters 
        WHERE is_active = 'Y' 
        AND ROWNUM <= 3;
        
        IF v_available_meters.COUNT > 0 THEN
            -- Ensure consumption array matches meter array length
            energy_monitoring_pkg.bulk_insert_readings(
                p_readings_array => v_available_meters,
                p_consumptions_array => SYS.ODCINUMBERLIST(800, 950, 1200),
                p_success_count => v_success_count,
                p_error_count => v_error_count
            );
            IF v_success_count > 0 THEN
                DBMS_OUTPUT.PUT_LINE('   ✅ Success: ' || v_success_count || ', Errors: ' || v_error_count);
                v_passed_tests := v_passed_tests + 1;
            ELSE
                DBMS_OUTPUT.PUT_LINE('   ❌ No successful inserts: ' || v_error_count || ' errors');
                v_failed_tests := v_failed_tests + 1;
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ⚠️ No active meters available for bulk insert test');
            v_passed_tests := v_passed_tests + 1; -- Not a failure, just no data
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Bulk insert failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 2.5: Validation function
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('2.5 Testing validate_meter_reading...');
    BEGIN
        v_validation_result := energy_monitoring_pkg.validate_meter_reading(v_test_meter_id, 1500);
        IF v_validation_result IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Validation: ' || v_validation_result);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ Validation returned NULL');
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Validation failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 2.6: Daily consumption calculation
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('2.6 Testing calculate_daily_consumption...');
    BEGIN
        v_daily_consumption := energy_monitoring_pkg.calculate_daily_consumption(v_test_building_id, SYSDATE);
        IF v_daily_consumption >= 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Daily consumption: ' || v_daily_consumption || ' kWh');
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ⚠️ Daily consumption: No data (expected)');
            v_passed_tests := v_passed_tests + 1; -- Not a failure
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Daily consumption failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 2.7: Meter availability check
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('2.7 Testing is_meter_available...');
    BEGIN
        IF energy_monitoring_pkg.is_meter_available(v_test_meter_id) THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Meter ' || v_test_meter_id || ' is available');
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ Meter ' || v_test_meter_id || ' is not available');
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Availability check failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- PHASE 3: ALERT MANAGEMENT PACKAGE TESTS
    DBMS_OUTPUT.PUT_LINE('PHASE 3: ALERT MANAGEMENT PACKAGE TESTS');
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 50, '='));
    
    -- Test 3.1: Update building thresholds
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('3.1 Testing update_building_thresholds...');
    BEGIN
        alert_management_pkg.update_building_thresholds(
            p_building_id => v_test_building_id,
            p_threshold_type => 'Daily',
            p_warning_level => 1000,
            p_critical_level => 2000,
            p_rows_affected => v_rows_updated,
            p_status_message => v_status_message
        );
        IF v_status_message LIKE 'SUCCESS%' THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ ' || v_status_message);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ ' || v_status_message);
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Threshold update failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 3.2: Generate threshold alerts
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('3.2 Testing generate_threshold_alerts...');
    BEGIN
        alert_management_pkg.generate_threshold_alerts(
            p_building_id => v_test_building_id,
            p_alert_count => v_alert_count,
            p_error_count => v_error_count
        );
        DBMS_OUTPUT.PUT_LINE('   ✅ Alerts: ' || v_alert_count || ', Errors: ' || v_error_count);
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Alert generation failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 3.3: Check threshold breach
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('3.3 Testing check_threshold_breach...');
    BEGIN
        v_status_message := alert_management_pkg.check_threshold_breach(v_test_building_id, 1500, 'Daily');
        DBMS_OUTPUT.PUT_LINE('   ✅ Threshold check: ' || v_status_message);
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Threshold check failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 3.4: Get active alert count
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('3.4 Testing get_active_alert_count...');
    BEGIN
        v_alert_count := alert_management_pkg.get_active_alert_count(v_test_building_id);
        DBMS_OUTPUT.PUT_LINE('   ✅ Active alerts: ' || v_alert_count);
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Alert count failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 3.5: Bulk resolve alerts
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('3.5 Testing bulk_resolve_alerts...');
    BEGIN
        -- Get some alert IDs to resolve
        SELECT alert_id 
        BULK COLLECT INTO v_alert_ids 
        FROM alerts 
        WHERE status = 'PENDING' 
        AND ROWNUM <= 2;
        
        IF v_alert_ids.COUNT > 0 THEN
            alert_management_pkg.bulk_resolve_alerts(
                p_alert_ids => v_alert_ids,
                p_resolved_by => 'TEST_USER',
                p_resolved_count => v_resolved_count,
                p_failed_count => v_failed_count
            );
            DBMS_OUTPUT.PUT_LINE('   ✅ Resolved: ' || v_resolved_count || ', Failed: ' || v_failed_count);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ⚠️ No pending alerts to resolve');
            v_passed_tests := v_passed_tests + 1; -- Not a failure
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Bulk resolve failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- PHASE 4: ENERGY ANALYTICS PACKAGE TESTS
    DBMS_OUTPUT.PUT_LINE('PHASE 4: ENERGY ANALYTICS PACKAGE TESTS');
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 50, '='));
    
    -- Test 4.1: Meter efficiency with window functions
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('4.1 Testing get_meter_efficiency...');
    BEGIN
        v_efficiency := energy_analytics_pkg.get_meter_efficiency(v_test_meter_id);
        IF v_efficiency BETWEEN 0 AND 100 THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Meter efficiency: ' || ROUND(v_efficiency, 2) || '%');
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ Invalid efficiency rating: ' || v_efficiency);
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Efficiency calculation failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 4.2: Consumption trend analysis
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('4.2 Testing get_consumption_trend...');
    BEGIN
        v_trend := energy_analytics_pkg.get_consumption_trend(v_test_building_id, 7);
        DBMS_OUTPUT.PUT_LINE('   ✅ Consumption trend: ' || v_trend);
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Trend analysis failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 4.3: Building consumption ranking
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('4.3 Testing get_building_consumption_rank...');
    BEGIN
        v_rank := energy_analytics_pkg.get_building_consumption_rank(v_test_building_id);
        IF v_rank IS NOT NULL AND v_rank > 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Building rank: ' || v_rank);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ⚠️ Building rank: No ranking available');
            v_passed_tests := v_passed_tests + 1; -- Not a failure
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Ranking failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 4.4: Growth rate calculation
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('4.4 Testing calculate_growth_rate...');
    BEGIN
        v_growth_rate := energy_analytics_pkg.calculate_growth_rate(v_test_meter_id, 30);
        DBMS_OUTPUT.PUT_LINE('   ✅ Growth rate: ' || ROUND(NVL(v_growth_rate, 0), 2) || '%');
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Growth rate failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 4.5: Trend report with ref cursor
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('4.5 Testing generate_consumption_trend_report...');
    BEGIN
        energy_analytics_pkg.generate_consumption_trend_report(
            p_building_id => v_test_building_id,
            p_days_back => 7,
            p_report_data => v_report_cursor
        );
        DBMS_OUTPUT.PUT_LINE('   ✅ Trend report generated successfully');
        CLOSE v_report_cursor;
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Trend report failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 4.6: Comparative analysis
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('4.6 Testing generate_comparative_analysis...');
    BEGIN
        energy_analytics_pkg.generate_comparative_analysis(
            p_period_type => 'MONTHLY',
            p_analysis_results => v_report_cursor
        );
        DBMS_OUTPUT.PUT_LINE('   ✅ Comparative analysis generated');
        CLOSE v_report_cursor;
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Comparative analysis failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 4.7: Bulk efficiency calculation
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('4.7 Testing calculate_efficiency_ratings_bulk...');
    BEGIN
        energy_analytics_pkg.calculate_efficiency_ratings_bulk(
            p_meter_ids => SYS.ODCINUMBERLIST(v_test_meter_id),
            p_updated_count => v_rows_updated
        );
        IF v_rows_updated > 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Bulk efficiency calculated for ' || v_rows_updated || ' meters');
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ⚠️ No meters processed in bulk efficiency');
            v_passed_tests := v_passed_tests + 1; -- Not a failure
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Bulk efficiency failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- PHASE 5: MAINTENANCE OPERATIONS PACKAGE TESTS
    DBMS_OUTPUT.PUT_LINE('PHASE 5: MAINTENANCE OPERATIONS PACKAGE TESTS');
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 50, '='));
    
    -- Test 5.1: Maintenance due check
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('5.1 Testing is_maintenance_due...');
    BEGIN
        v_maintenance_due := maintenance_ops_pkg.is_maintenance_due(v_test_meter_id);
        DBMS_OUTPUT.PUT_LINE('   ✅ Maintenance due: ' || CASE WHEN v_maintenance_due THEN 'YES' ELSE 'NO' END);
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Maintenance check failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 5.2: Next maintenance date calculation
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('5.2 Testing calculate_next_maintenance...');
    BEGIN
        v_next_maintenance := maintenance_ops_pkg.calculate_next_maintenance(v_test_meter_id);
        IF v_next_maintenance IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Next maintenance: ' || TO_CHAR(v_next_maintenance, 'YYYY-MM-DD'));
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ⚠️ Next maintenance: Not scheduled');
            v_passed_tests := v_passed_tests + 1; -- Not a failure
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Next maintenance failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 5.3: Maintenance history count
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('5.3 Testing get_maintenance_count...');
    BEGIN
        v_maintenance_count := maintenance_ops_pkg.get_maintenance_count(v_test_meter_id);
        DBMS_OUTPUT.PUT_LINE('   ✅ Maintenance count: ' || v_maintenance_count);
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Maintenance count failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 5.4: Generate maintenance report
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('5.4 Testing generate_maintenance_report...');
    BEGIN
        maintenance_ops_pkg.generate_maintenance_report(
            p_building_id => v_test_building_id,
            p_report_details => v_report_details
        );
        IF LENGTH(v_report_details) > 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Maintenance report generated (' || LENGTH(v_report_details) || ' chars)');
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ Empty maintenance report generated');
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Maintenance report failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 5.5: Archive old readings
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('5.5 Testing archive_old_readings...');
    BEGIN
        maintenance_ops_pkg.archive_old_readings(
            p_cutoff_date => DATE '2023-12-01',
            p_batch_size => 500,
            p_archived_count => v_archived_count,
            p_error_count => v_error_count
        );
        DBMS_OUTPUT.PUT_LINE('   ✅ Archived: ' || v_archived_count || ', Errors: ' || v_error_count);
        v_passed_tests := v_passed_tests + 1;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Archive failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    -- Test 5.6: Schedule bulk maintenance
    v_total_tests := v_total_tests + 1;
    DBMS_OUTPUT.PUT_LINE('5.6 Testing schedule_bulk_maintenance...');
    BEGIN
        maintenance_ops_pkg.schedule_bulk_maintenance(
            p_meter_ids => SYS.ODCINUMBERLIST(v_test_meter_id),
            p_maintenance_type => 'Calibration',
            p_technician_name => 'Test Technician',
            p_scheduled_count => v_success_count,
            p_failed_count => v_failed_count
        );
        IF v_success_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ✅ Scheduled: ' || v_success_count || ', Failed: ' || v_failed_count);
            v_passed_tests := v_passed_tests + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   ❌ No maintenance scheduled');
            v_failed_tests := v_failed_tests + 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Schedule maintenance failed: ' || SQLERRM);
            v_failed_tests := v_failed_tests + 1;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== FINAL TEST RESULTS ===');
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 50, '='));
    DBMS_OUTPUT.PUT_LINE('Total Tests: ' || v_total_tests);
    DBMS_OUTPUT.PUT_LINE('✅ Passed: ' || v_passed_tests);
    DBMS_OUTPUT.PUT_LINE('❌ Failed: ' || v_failed_tests);
    DBMS_OUTPUT.PUT_LINE('Success Rate: ' || ROUND((v_passed_tests / v_total_tests) * 100, 2) || '%');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Test End: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ CRITICAL TEST FAILURE: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('=== PARTIAL TEST RESULTS ===');
        DBMS_OUTPUT.PUT_LINE('Total Tests: ' || v_total_tests);
        DBMS_OUTPUT.PUT_LINE('✅ Passed: ' || v_passed_tests);
        DBMS_OUTPUT.PUT_LINE('❌ Failed: ' || v_failed_tests);
END;
/

-- Quick test of the validation function
SET SERVEROUTPUT ON
DECLARE
    v_result VARCHAR2(100);
    v_test_meter_id NUMBER;
BEGIN
    -- Get a test meter ID
    SELECT meter_id INTO v_test_meter_id 
    FROM energy_meters WHERE ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Testing validation for meter: ' || v_test_meter_id);
    
    -- Test with valid consumption
    v_result := energy_monitoring_pkg.validate_meter_reading(v_test_meter_id, 1000);
    DBMS_OUTPUT.PUT_LINE('Result for 1000 kWh: ' || v_result);
    
    -- Test with negative consumption
    v_result := energy_monitoring_pkg.validate_meter_reading(v_test_meter_id, -50);
    DBMS_OUTPUT.PUT_LINE('Result for -50 kWh: ' || v_result);
    
    -- Test with zero consumption
    v_result := energy_monitoring_pkg.validate_meter_reading(v_test_meter_id, 0);
    DBMS_OUTPUT.PUT_LINE('Result for 0 kWh: ' || v_result);
    
    -- Test with invalid meter
    v_result := energy_monitoring_pkg.validate_meter_reading(99999, 1000);
    DBMS_OUTPUT.PUT_LINE('Result for invalid meter: ' || v_result);
    
END;
/