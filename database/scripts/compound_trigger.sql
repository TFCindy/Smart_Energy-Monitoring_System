-- =============================================
-- File: 21_compound_trigger.sql
-- Step 6: Compound Trigger for Comprehensive DML Restriction
-- =============================================

-- Compound trigger for a key table (using BUILDINGS as example)
-- This is more efficient than multiple simple triggers

CREATE OR REPLACE TRIGGER trg_compound_buildings_restrict
FOR INSERT OR UPDATE OR DELETE ON buildings
COMPOUND TRIGGER

    -- Global variables shared across all timing points
    TYPE t_operation_rec IS RECORD (
        operation_type VARCHAR2(10),
        record_id NUMBER,
        building_name VARCHAR2(100)
    );
    
    TYPE t_operations_table IS TABLE OF t_operation_rec;
    g_operations t_operations_table := t_operations_table();
    
    v_restriction_reason VARCHAR2(500);
    v_is_dml_allowed BOOLEAN;
    
    -- BEFORE STATEMENT: Check once per statement
    BEFORE STATEMENT IS
    BEGIN
        -- Check restriction once for the entire statement
        v_is_dml_allowed := is_dml_allowed();
        v_restriction_reason := check_dml_restriction();
        
        IF NOT v_is_dml_allowed THEN
            -- Log the statement-level restriction
            audit_utils_pkg.log_audit_event(
                p_table_name => 'BUILDINGS',
                p_operation_type => 
                    CASE 
                        WHEN INSERTING THEN 'INSERT'
                        WHEN UPDATING THEN 'UPDATE'
                        WHEN DELETING THEN 'DELETE'
                    END,
                p_is_restricted => 'Y',
                p_restriction_reason => 'Statement blocked: ' || v_restriction_reason,
                p_status => 'BLOCKED'
            );
            
            -- Raise error at statement level
            RAISE_APPLICATION_ERROR(-20020, 
                'DML statement on BUILDINGS table not allowed. ' ||
                'Reason: ' || SUBSTR(v_restriction_reason, INSTR(v_restriction_reason, ':') + 2)
            );
        END IF;
        
        -- Initialize operations table
        g_operations.DELETE;
        
    END BEFORE STATEMENT;
    
    -- BEFORE EACH ROW: Collect row-level information
    BEFORE EACH ROW IS
    BEGIN
        -- Store row information
        IF INSERTING THEN
            g_operations.EXTEND;
            g_operations(g_operations.LAST).operation_type := 'INSERT';
            g_operations(g_operations.LAST).record_id := :NEW.building_id;
            g_operations(g_operations.LAST).building_name := :NEW.building_name;
        ELSIF UPDATING THEN
            g_operations.EXTEND;
            g_operations(g_operations.LAST).operation_type := 'UPDATE';
            g_operations(g_operations.LAST).record_id := :NEW.building_id;
            g_operations(g_operations.LAST).building_name := :NEW.building_name;
        ELSE -- DELETING
            g_operations.EXTEND;
            g_operations(g_operations.LAST).operation_type := 'DELETE';
            g_operations(g_operations.LAST).record_id := :OLD.building_id;
            g_operations(g_operations.LAST).building_name := :OLD.building_name;
        END IF;
    END BEFORE EACH ROW;
    
    -- AFTER EACH ROW: Log each successful row operation
    AFTER EACH ROW IS
    BEGIN
        -- Log successful row operation
        IF INSERTING THEN
            audit_utils_pkg.log_audit_event(
                p_table_name => 'BUILDINGS',
                p_operation_type => 'INSERT',
                p_record_id => :NEW.building_id,
                p_is_restricted => 'N',
                p_status => 'COMPLETED'
            );
        ELSIF UPDATING THEN
            audit_utils_pkg.log_audit_event(
                p_table_name => 'BUILDINGS',
                p_operation_type => 'UPDATE',
                p_record_id => :NEW.building_id,
                p_is_restricted => 'N',
                p_status => 'COMPLETED'
            );
        ELSE -- DELETING
            audit_utils_pkg.log_audit_event(
                p_table_name => 'BUILDINGS',
                p_operation_type => 'DELETE',
                p_record_id => :OLD.building_id,
                p_is_restricted => 'N',
                p_status => 'COMPLETED'
            );
        END IF;
    END AFTER EACH ROW;
    
    -- AFTER STATEMENT: Log summary of operations
    AFTER STATEMENT IS
        v_total_rows NUMBER;
    BEGIN
        v_total_rows := g_operations.COUNT;
        
        -- Log statement summary (optional)
        IF v_total_rows > 0 THEN
            audit_utils_pkg.log_audit_event(
                p_table_name => 'BUILDINGS',
                p_operation_type => g_operations(1).operation_type || '_BATCH',
                p_record_id => 'BATCH:' || v_total_rows,
                p_is_restricted => 'N',
                p_restriction_reason => 'Completed batch of ' || v_total_rows || ' rows',
                p_status => 'COMPLETED'
            );
        END IF;
        
    END AFTER STATEMENT;

END trg_compound_buildings_restrict;
/

-- Create a second compound trigger for ENERGY_METERS table
CREATE OR REPLACE TRIGGER trg_compound_energy_meters_restrict
FOR INSERT OR UPDATE OR DELETE ON energy_meters
COMPOUND TRIGGER

    v_restriction_reason VARCHAR2(500);
    v_is_dml_allowed BOOLEAN;
    
    -- BEFORE STATEMENT
    BEFORE STATEMENT IS
    BEGIN
        v_is_dml_allowed := is_dml_allowed();
        v_restriction_reason := check_dml_restriction();
        
        IF NOT v_is_dml_allowed THEN
            audit_utils_pkg.log_audit_event(
                p_table_name => 'ENERGY_METERS',
                p_operation_type => 
                    CASE 
                        WHEN INSERTING THEN 'INSERT'
                        WHEN UPDATING THEN 'UPDATE'
                        WHEN DELETING THEN 'DELETE'
                    END,
                p_is_restricted => 'Y',
                p_restriction_reason => 'Statement blocked: ' || v_restriction_reason,
                p_status => 'BLOCKED'
            );
            
            RAISE_APPLICATION_ERROR(-20021, 
                'DML statement on ENERGY_METERS table not allowed. ' ||
                'Reason: ' || SUBSTR(v_restriction_reason, INSTR(v_restriction_reason, ':') + 2)
            );
        END IF;
    END BEFORE STATEMENT;
    
    -- AFTER EACH ROW
    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            audit_utils_pkg.log_audit_event(
                p_table_name => 'ENERGY_METERS',
                p_operation_type => 'INSERT',
                p_record_id => :NEW.meter_id,
                p_is_restricted => 'N',
                p_status => 'COMPLETED'
            );
        ELSIF UPDATING THEN
            audit_utils_pkg.log_audit_event(
                p_table_name => 'ENERGY_METERS',
                p_operation_type => 'UPDATE',
                p_record_id => :NEW.meter_id,
                p_is_restricted => 'N',
                p_status => 'COMPLETED'
            );
        ELSE -- DELETING
            audit_utils_pkg.log_audit_event(
                p_table_name => 'ENERGY_METERS',
                p_operation_type => 'DELETE',
                p_record_id => :OLD.meter_id,
                p_is_restricted => 'N',
                p_status => 'COMPLETED'
            );
        END IF;
    END AFTER EACH ROW;

END trg_compound_energy_meters_restrict;
/

-- Test the compound triggers
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Compound Triggers ===');
    DBMS_OUTPUT.PUT_LINE('Current day: ' || TO_CHAR(SYSDATE, 'DAY'));
    DBMS_OUTPUT.PUT_LINE('DML Allowed: ' || CASE WHEN is_dml_allowed() THEN 'YES' ELSE 'NO' END);
    DBMS_OUTPUT.PUT_LINE('Restriction: ' || check_dml_restriction());
    
    -- Try multi-row insert (will be blocked on weekdays)
    BEGIN
        INSERT INTO buildings (building_id, building_name, location) 
        SELECT 10000 + LEVEL, 'Test Building ' || LEVEL, 'Location ' || LEVEL
        FROM dual
        CONNECT BY LEVEL <= 3;
        
        DBMS_OUTPUT.PUT_LINE('✓ Multi-row INSERT succeeded');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✗ Multi-row INSERT blocked: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== Checking Audit Log ===');
    
END;
/

-- Check audit log for recent entries
SELECT 
    audit_id,
    table_name,
    operation_type,
    is_restricted,
    day_of_week,
    is_holiday,
    restriction_reason,
    TO_CHAR(audit_timestamp, 'HH24:MI:SS') as time
FROM energy_audit_log 
WHERE audit_timestamp > SYSDATE - 1/24  -- Last hour
ORDER BY audit_timestamp DESC;

-- View trigger status
SELECT 
    trigger_name,
    table_name,
    trigger_type,
    status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_COMPOUND%'
ORDER BY table_name;

-- Test on a weekend (simulate by temporarily disabling restriction check)
-- First, let's create a test function that simulates weekend
CREATE OR REPLACE FUNCTION test_is_weekend RETURN BOOLEAN IS
    v_day VARCHAR2(10);
BEGIN
    SELECT TO_CHAR(SYSDATE, 'DY') INTO v_day FROM DUAL;
    RETURN (v_day IN ('SAT', 'SUN'));
END;
/

BEGIN
    IF test_is_weekend() THEN
        DBMS_OUTPUT.PUT_LINE('Today is weekend - DML should be allowed (unless holiday)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Today is weekday - DML should be blocked');
    END IF;
END;
/

COMMIT;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Step 6: Compound Triggers COMPLETED ===');
    DBMS_OUTPUT.PUT_LINE('Created compound triggers for:');
    DBMS_OUTPUT.PUT_LINE('1. BUILDINGS table');
    DBMS_OUTPUT.PUT_LINE('2. ENERGY_METERS table');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Note: DML operations are currently: ' || 
        CASE WHEN is_dml_allowed() THEN 'ALLOWED' ELSE 'BLOCKED' END);
END;
/

SELECT trigger_name, table_name, trigger_type, status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_%_DML_RESTRICT'
ORDER BY table_name;

-- Run this for clean output
SELECT 
    'Compound Trigger' as type,
    trigger_name,
    table_name,
    status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_COMPOUND%'
ORDER BY table_name;

SELECT 
    TO_CHAR(SYSDATE, 'DD-MON-YYYY DAY') as current_date,
    check_dml_restriction() as restriction_status,
    CASE WHEN is_dml_allowed() THEN 'ALLOWED' ELSE 'BLOCKED' END as dml_permission
FROM dual;