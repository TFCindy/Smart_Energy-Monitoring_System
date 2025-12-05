-- =============================================
-- File: 20_simple_triggers.sql
-- Step 5: Simple Triggers for Business Rule Enforcement
-- =============================================

-- First, let's verify our restriction functions exist
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Verifying Restriction Functions ===');
    
    -- Test the functions
    DBMS_OUTPUT.PUT_LINE('1. is_dml_allowed(): ' || 
        CASE WHEN is_dml_allowed() THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('2. check_dml_restriction(): ' || check_dml_restriction());
END;
/

-- =============================================
-- 1. TRIGGER FOR BUILDINGS TABLE
-- =============================================

CREATE OR REPLACE TRIGGER trg_buildings_dml_restrict
BEFORE INSERT OR UPDATE OR DELETE ON buildings
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);
    v_record_id VARCHAR2(100);
    v_restriction_reason VARCHAR2(500);
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation_type := 'INSERT';
        v_record_id := :NEW.building_id;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :NEW.building_id;
    ELSE -- DELETING
        v_operation_type := 'DELETE';
        v_record_id := :OLD.building_id;
    END IF;
    
    -- Check if DML is allowed
    IF NOT is_dml_allowed() THEN
        -- Get restriction reason
        v_restriction_reason := check_dml_restriction();
        
        -- Log the blocked attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'BUILDINGS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'Y',
            p_restriction_reason => v_restriction_reason,
            p_status => 'BLOCKED'
        );
        
        -- Raise error to prevent DML
        RAISE_APPLICATION_ERROR(-20010, 
            'DML operation ' || v_operation_type || ' on BUILDINGS table not allowed. ' ||
            'Reason: ' || SUBSTR(v_restriction_reason, INSTR(v_restriction_reason, ':') + 2)
        );
    ELSE
        -- DML is allowed, log successful attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'BUILDINGS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'N',
            p_status => 'COMPLETED'
        );
    END IF;
END trg_buildings_dml_restrict;
/

-- =============================================
-- 2. TRIGGER FOR ENERGY_METERS TABLE
-- =============================================

CREATE OR REPLACE TRIGGER trg_energy_meters_dml_restrict
BEFORE INSERT OR UPDATE OR DELETE ON energy_meters
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);
    v_record_id VARCHAR2(100);
    v_restriction_reason VARCHAR2(500);
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation_type := 'INSERT';
        v_record_id := :NEW.meter_id;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :NEW.meter_id;
    ELSE -- DELETING
        v_operation_type := 'DELETE';
        v_record_id := :OLD.meter_id;
    END IF;
    
    -- Check if DML is allowed
    IF NOT is_dml_allowed() THEN
        -- Get restriction reason
        v_restriction_reason := check_dml_restriction();
        
        -- Log the blocked attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'ENERGY_METERS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'Y',
            p_restriction_reason => v_restriction_reason,
            p_status => 'BLOCKED'
        );
        
        -- Raise error to prevent DML
        RAISE_APPLICATION_ERROR(-20011, 
            'DML operation ' || v_operation_type || ' on ENERGY_METERS table not allowed. ' ||
            'Reason: ' || SUBSTR(v_restriction_reason, INSTR(v_restriction_reason, ':') + 2)
        );
    ELSE
        -- DML is allowed, log successful attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'ENERGY_METERS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'N',
            p_status => 'COMPLETED'
        );
    END IF;
END trg_energy_meters_dml_restrict;
/

-- =============================================
-- 3. TRIGGER FOR CONSUMPTION_READINGS TABLE
-- =============================================

CREATE OR REPLACE TRIGGER trg_consumption_readings_dml_restrict
BEFORE INSERT OR UPDATE OR DELETE ON consumption_readings
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);
    v_record_id VARCHAR2(100);
    v_restriction_reason VARCHAR2(500);
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation_type := 'INSERT';
        v_record_id := :NEW.reading_id;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :NEW.reading_id;
    ELSE -- DELETING
        v_operation_type := 'DELETE';
        v_record_id := :OLD.reading_id;
    END IF;
    
    -- Check if DML is allowed
    IF NOT is_dml_allowed() THEN
        -- Get restriction reason
        v_restriction_reason := check_dml_restriction();
        
        -- Log the blocked attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'CONSUMPTION_READINGS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'Y',
            p_restriction_reason => v_restriction_reason,
            p_status => 'BLOCKED'
        );
        
        -- Raise error to prevent DML
        RAISE_APPLICATION_ERROR(-20012, 
            'DML operation ' || v_operation_type || ' on CONSUMPTION_READINGS table not allowed. ' ||
            'Reason: ' || SUBSTR(v_restriction_reason, INSTR(v_restriction_reason, ':') + 2)
        );
    ELSE
        -- DML is allowed, log successful attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'CONSUMPTION_READINGS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'N',
            p_status => 'COMPLETED'
        );
    END IF;
END trg_consumption_readings_dml_restrict;
/

-- =============================================
-- 4. TRIGGER FOR CONSUMPTION_THRESHOLDS TABLE
-- =============================================

CREATE OR REPLACE TRIGGER trg_consumption_thresholds_dml_restrict
BEFORE INSERT OR UPDATE OR DELETE ON consumption_thresholds
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);
    v_record_id VARCHAR2(100);
    v_restriction_reason VARCHAR2(500);
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation_type := 'INSERT';
        v_record_id := :NEW.threshold_id;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :NEW.threshold_id;
    ELSE -- DELETING
        v_operation_type := 'DELETE';
        v_record_id := :OLD.threshold_id;
    END IF;
    
    -- Check if DML is allowed
    IF NOT is_dml_allowed() THEN
        -- Get restriction reason
        v_restriction_reason := check_dml_restriction();
        
        -- Log the blocked attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'CONSUMPTION_THRESHOLDS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'Y',
            p_restriction_reason => v_restriction_reason,
            p_status => 'BLOCKED'
        );
        
        -- Raise error to prevent DML
        RAISE_APPLICATION_ERROR(-20013, 
            'DML operation ' || v_operation_type || ' on CONSUMPTION_THRESHOLDS table not allowed. ' ||
            'Reason: ' || SUBSTR(v_restriction_reason, INSTR(v_restriction_reason, ':') + 2)
        );
    ELSE
        -- DML is allowed, log successful attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'CONSUMPTION_THRESHOLDS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'N',
            p_status => 'COMPLETED'
        );
    END IF;
END trg_consumption_thresholds_dml_restrict;
/

-- =============================================
-- 5. TRIGGER FOR MAINTENANCE_LOGS TABLE
-- =============================================

CREATE OR REPLACE TRIGGER trg_maintenance_logs_dml_restrict
BEFORE INSERT OR UPDATE OR DELETE ON maintenance_logs
FOR EACH ROW
DECLARE
    v_operation_type VARCHAR2(10);
    v_record_id VARCHAR2(100);
    v_restriction_reason VARCHAR2(500);
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation_type := 'INSERT';
        v_record_id := :NEW.maintenance_id;
    ELSIF UPDATING THEN
        v_operation_type := 'UPDATE';
        v_record_id := :NEW.maintenance_id;
    ELSE -- DELETING
        v_operation_type := 'DELETE';
        v_record_id := :OLD.maintenance_id;
    END IF;
    
    -- Check if DML is allowed
    IF NOT is_dml_allowed() THEN
        -- Get restriction reason
        v_restriction_reason := check_dml_restriction();
        
        -- Log the blocked attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'MAINTENANCE_LOGS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'Y',
            p_restriction_reason => v_restriction_reason,
            p_status => 'BLOCKED'
        );
        
        -- Raise error to prevent DML
        RAISE_APPLICATION_ERROR(-20014, 
            'DML operation ' || v_operation_type || ' on MAINTENANCE_LOGS table not allowed. ' ||
            'Reason: ' || SUBSTR(v_restriction_reason, INSTR(v_restriction_reason, ':') + 2)
        );
    ELSE
        -- DML is allowed, log successful attempt
        audit_utils_pkg.log_audit_event(
            p_table_name => 'MAINTENANCE_LOGS',
            p_operation_type => v_operation_type,
            p_record_id => v_record_id,
            p_is_restricted => 'N',
            p_status => 'COMPLETED'
        );
    END IF;
END trg_maintenance_logs_dml_restrict;
/

-- =============================================
-- VERIFY ALL TRIGGERS WERE CREATED
-- =============================================

SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Simple Triggers Created Successfully ===');
    DBMS_OUTPUT.PUT_LINE('Created triggers for:');
    DBMS_OUTPUT.PUT_LINE('1. BUILDINGS table');
    DBMS_OUTPUT.PUT_LINE('2. ENERGY_METERS table');
    DBMS_OUTPUT.PUT_LINE('3. CONSUMPTION_READINGS table');
    DBMS_OUTPUT.PUT_LINE('4. CONSUMPTION_THRESHOLDS table');
    DBMS_OUTPUT.PUT_LINE('5. MAINTENANCE_LOGS table');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Current restriction status: ' || check_dml_restriction());
    DBMS_OUTPUT.PUT_LINE('DML Allowed: ' || CASE WHEN is_dml_allowed() THEN 'YES' ELSE 'NO' END);
END;
/

-- Check trigger status
SELECT trigger_name, table_name, status, trigger_type
FROM user_triggers
WHERE trigger_name LIKE 'TRG_%_DML_RESTRICT'
ORDER BY table_name;

-- Test the triggers (this will fail on weekdays, succeed on weekends)
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Testing Triggers ===');
    
    -- This test will either succeed or fail based on current day
    BEGIN
        -- Try to insert a test record (this will be blocked or allowed)
        INSERT INTO buildings (building_id, building_name, location) 
        VALUES (9999, 'Test Building', 'Test Location');
        
        DBMS_OUTPUT.PUT_LINE('✓ INSERT allowed on BUILDINGS table');
        ROLLBACK; -- Clean up if allowed
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✗ INSERT blocked: ' || SQLERRM);
    END;
    
END;
/

COMMIT;

-- Add this at the end of your script instead of the standalone DBMS_OUTPUT line:
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Step 5: Simple Triggers COMPLETED ===');
END;
/