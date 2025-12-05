-- File: 12_edge_cases_test.sql
-- Edge Cases and Boundary Testing
SET SERVEROUTPUT ON

DECLARE
    v_result VARCHAR2(100);
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== EDGE CASES AND BOUNDARY TESTING ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Edge Case 1: Extreme consumption values
    DBMS_OUTPUT.PUT_LINE('1. EXTREME CONSUMPTION VALUES');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');
    v_result := energy_monitoring_pkg.validate_meter_reading(5002, 999999);
    DBMS_OUTPUT.PUT_LINE('   Very high consumption (999999): ' || v_result);
    
    v_result := energy_monitoring_pkg.validate_meter_reading(5002, 0.001);
    DBMS_OUTPUT.PUT_LINE('   Very low consumption (0.001): ' || v_result);
    
    -- Edge Case 2: NULL and invalid parameters
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. NULL AND INVALID PARAMETERS');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');
    BEGIN
        v_result := energy_monitoring_pkg.validate_meter_reading(NULL, 1000);
        DBMS_OUTPUT.PUT_LINE('   NULL meter_id: ' || v_result);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   NULL meter_id: Properly handled exception');
    END;
    
    -- Edge Case 3: Date boundary tests
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. DATE BOUNDARY TESTS');
    DBMS_OUTPUT.PUT_LINE('-----------------------');
    v_count := energy_monitoring_pkg.calculate_daily_consumption(1001, DATE '1900-01-01');
    DBMS_OUTPUT.PUT_LINE('   Ancient date consumption: ' || v_count || ' kWh');
    
    v_count := energy_monitoring_pkg.calculate_daily_consumption(1001, SYSDATE + 365);
    DBMS_OUTPUT.PUT_LINE('   Future date consumption: ' || v_count || ' kWh');
    
    -- Edge Case 4: Threshold boundary tests
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. THRESHOLD BOUNDARY TESTS');
    DBMS_OUTPUT.PUT_LINE('----------------------------');
    v_result := alert_management_pkg.check_threshold_breach(1001, 999, 'Daily');
    DBMS_OUTPUT.PUT_LINE('   Just below warning (999): ' || v_result);
    
    v_result := alert_management_pkg.check_threshold_breach(1001, 1001, 'Daily');
    DBMS_OUTPUT.PUT_LINE('   Just above warning (1001): ' || v_result);
    
    v_result := alert_management_pkg.check_threshold_breach(1001, 2001, 'Daily');
    DBMS_OUTPUT.PUT_LINE('   Just above critical (2001): ' || v_result);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== EDGE CASE TESTING COMPLETED ===');
    
END;
/