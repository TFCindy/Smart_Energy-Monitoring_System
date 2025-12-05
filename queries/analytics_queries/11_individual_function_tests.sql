-- File: 11_individual_function_tests.sql
-- Individual Function/Procedure Tests with Proof
SET SERVEROUTPUT ON
SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
    v_test_result VARCHAR2(4000);
    v_test_count NUMBER := 0;
    v_success_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INDIVIDUAL FUNCTION/PROCEDURE TESTS ===');
    DBMS_OUTPUT.PUT_LINE('Test Date: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 1: Energy Monitoring Package Functions
    DBMS_OUTPUT.PUT_LINE('1. ENERGY MONITORING PACKAGE FUNCTIONS');
    DBMS_OUTPUT.PUT_LINE('======================================');
    
    -- 1.1 validate_meter_reading - Edge Cases
    v_test_count := v_test_count + 1;
    v_test_result := energy_monitoring_pkg.validate_meter_reading(5002, 1000);
    DBMS_OUTPUT.PUT_LINE('1.1 validate_meter_reading(5002, 1000): ' || v_test_result);
    IF v_test_result = 'VALID' THEN v_success_count := v_success_count + 1; END IF;
    
    v_test_count := v_test_count + 1;
    v_test_result := energy_monitoring_pkg.validate_meter_reading(5002, -50);
    DBMS_OUTPUT.PUT_LINE('1.2 validate_meter_reading(5002, -50): ' || v_test_result);
    IF v_test_result LIKE 'INVALID%' THEN v_success_count := v_success_count + 1; END IF;
    
    v_test_count := v_test_count + 1;
    v_test_result := energy_monitoring_pkg.validate_meter_reading(5002, 0);
    DBMS_OUTPUT.PUT_LINE('1.3 validate_meter_reading(5002, 0): ' || v_test_result);
    IF v_test_result LIKE 'WARNING%' THEN v_success_count := v_success_count + 1; END IF;
    
    v_test_count := v_test_count + 1;
    v_test_result := energy_monitoring_pkg.validate_meter_reading(99999, 1000);
    DBMS_OUTPUT.PUT_LINE('1.4 validate_meter_reading(99999, 1000): ' || v_test_result);
    IF v_test_result LIKE 'INVALID%' THEN v_success_count := v_success_count + 1; END IF;
    
    -- 1.2 calculate_daily_consumption
    v_test_count := v_test_count + 1;
    DECLARE
        v_consumption NUMBER;
    BEGIN
        v_consumption := energy_monitoring_pkg.calculate_daily_consumption(1001, SYSDATE);
        DBMS_OUTPUT.PUT_LINE('1.5 calculate_daily_consumption(1001): ' || v_consumption || ' kWh');
        IF v_consumption >= 0 THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    -- 1.3 is_meter_available
    v_test_count := v_test_count + 1;
    DECLARE
        v_available BOOLEAN;
    BEGIN
        v_available := energy_monitoring_pkg.is_meter_available(5002);
        DBMS_OUTPUT.PUT_LINE('1.6 is_meter_available(5002): ' || CASE WHEN v_available THEN 'TRUE' ELSE 'FALSE' END);
        IF v_available THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 2: Alert Management Package Functions
    DBMS_OUTPUT.PUT_LINE('2. ALERT MANAGEMENT PACKAGE FUNCTIONS');
    DBMS_OUTPUT.PUT_LINE('====================================');
    
    -- 2.1 check_threshold_breach
    v_test_count := v_test_count + 1;
    v_test_result := alert_management_pkg.check_threshold_breach(1001, 1500, 'Daily');
    DBMS_OUTPUT.PUT_LINE('2.1 check_threshold_breach(1001, 1500): ' || v_test_result);
    IF v_test_result IN ('WARNING', 'CRITICAL', 'NORMAL') THEN v_success_count := v_success_count + 1; END IF;
    
    -- 2.2 get_active_alert_count
    v_test_count := v_test_count + 1;
    DECLARE
        v_alert_count NUMBER;
    BEGIN
        v_alert_count := alert_management_pkg.get_active_alert_count(1001);
        DBMS_OUTPUT.PUT_LINE('2.2 get_active_alert_count(1001): ' || v_alert_count);
        IF v_alert_count >= 0 THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    -- 2.3 validate_threshold_config
    v_test_count := v_test_count + 1;
    DECLARE
        v_valid BOOLEAN;
    BEGIN
        v_valid := alert_management_pkg.validate_threshold_config(1000, 2000);
        DBMS_OUTPUT.PUT_LINE('2.3 validate_threshold_config(1000, 2000): ' || CASE WHEN v_valid THEN 'VALID' ELSE 'INVALID' END);
        IF v_valid THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 3: Energy Analytics Package Functions
    DBMS_OUTPUT.PUT_LINE('3. ENERGY ANALYTICS PACKAGE FUNCTIONS');
    DBMS_OUTPUT.PUT_LINE('====================================');
    
    -- 3.1 get_meter_efficiency
    v_test_count := v_test_count + 1;
    DECLARE
        v_efficiency NUMBER;
    BEGIN
        v_efficiency := energy_analytics_pkg.get_meter_efficiency(5002);
        DBMS_OUTPUT.PUT_LINE('3.1 get_meter_efficiency(5002): ' || ROUND(v_efficiency, 2) || '%');
        IF v_efficiency BETWEEN 0 AND 100 THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    -- 3.2 get_consumption_trend
    v_test_count := v_test_count + 1;
    v_test_result := energy_analytics_pkg.get_consumption_trend(1001, 7);
    DBMS_OUTPUT.PUT_LINE('3.2 get_consumption_trend(1001): ' || v_test_result);
    IF v_test_result IS NOT NULL THEN v_success_count := v_success_count + 1; END IF;
    
    -- 3.3 get_building_consumption_rank
    v_test_count := v_test_count + 1;
    DECLARE
        v_rank NUMBER;
    BEGIN
        v_rank := energy_analytics_pkg.get_building_consumption_rank(1001);
        DBMS_OUTPUT.PUT_LINE('3.3 get_building_consumption_rank(1001): ' || NVL(TO_CHAR(v_rank), 'No rank'));
        IF v_rank IS NULL OR v_rank > 0 THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    -- 3.4 calculate_growth_rate
    v_test_count := v_test_count + 1;
    DECLARE
        v_growth NUMBER;
    BEGIN
        v_growth := energy_analytics_pkg.calculate_growth_rate(5002, 30);
        DBMS_OUTPUT.PUT_LINE('3.4 calculate_growth_rate(5002): ' || ROUND(NVL(v_growth, 0), 2) || '%');
        IF v_growth IS NOT NULL THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 4: Maintenance Operations Package Functions
    DBMS_OUTPUT.PUT_LINE('4. MAINTENANCE OPERATIONS PACKAGE FUNCTIONS');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    
    -- 4.1 is_maintenance_due
    v_test_count := v_test_count + 1;
    DECLARE
        v_due BOOLEAN;
    BEGIN
        v_due := maintenance_ops_pkg.is_maintenance_due(5002);
        DBMS_OUTPUT.PUT_LINE('4.1 is_maintenance_due(5002): ' || CASE WHEN v_due THEN 'DUE' ELSE 'NOT DUE' END);
        v_success_count := v_success_count + 1; -- Both outcomes are valid
    END;
    
    -- 4.2 calculate_next_maintenance
    v_test_count := v_test_count + 1;
    DECLARE
        v_next_date DATE;
    BEGIN
        v_next_date := maintenance_ops_pkg.calculate_next_maintenance(5002);
        DBMS_OUTPUT.PUT_LINE('4.2 calculate_next_maintenance(5002): ' || TO_CHAR(v_next_date, 'YYYY-MM-DD'));
        IF v_next_date IS NOT NULL THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    -- 4.3 get_maintenance_count
    v_test_count := v_test_count + 1;
    DECLARE
        v_count NUMBER;
    BEGIN
        v_count := maintenance_ops_pkg.get_maintenance_count(5002);
        DBMS_OUTPUT.PUT_LINE('4.3 get_maintenance_count(5002): ' || v_count);
        IF v_count >= 0 THEN v_success_count := v_success_count + 1; END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== INDIVIDUAL FUNCTION TEST RESULTS ===');
    DBMS_OUTPUT.PUT_LINE('Total Tests: ' || v_test_count);
    DBMS_OUTPUT.PUT_LINE('Successful: ' || v_success_count);
    DBMS_OUTPUT.PUT_LINE('Success Rate: ' || ROUND((v_success_count / v_test_count) * 100, 2) || '%');
    
END;
/