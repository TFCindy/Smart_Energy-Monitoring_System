-- =============================================
-- File: 17_audit_logging_function.sql
-- Comprehensive Audit Logging Function
-- =============================================

-- First, drop if exists (optional)
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE audit_utils_pkg';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Create package specification FIRST
CREATE OR REPLACE PACKAGE audit_utils_pkg IS
    
    -- Function to check if today is a restricted day
    FUNCTION is_restricted_day RETURN BOOLEAN;
    
    -- Function to log audit entries
    PROCEDURE log_audit_event(
        p_table_name IN VARCHAR2,
        p_operation_type IN VARCHAR2,
        p_record_id IN VARCHAR2 DEFAULT NULL,
        p_old_values IN CLOB DEFAULT NULL,
        p_new_values IN CLOB DEFAULT NULL,
        p_is_restricted IN CHAR DEFAULT 'N',
        p_restriction_reason IN VARCHAR2 DEFAULT NULL,
        p_status IN VARCHAR2 DEFAULT 'ATTEMPTED',
        p_error_message IN VARCHAR2 DEFAULT NULL
    );
    
    -- Function to check if date is a holiday
    FUNCTION is_public_holiday(p_check_date IN DATE DEFAULT SYSDATE) RETURN BOOLEAN;
    
    -- Procedure to get restriction details
    PROCEDURE get_restriction_details(
        p_is_restricted OUT BOOLEAN,
        p_reason OUT VARCHAR2,
        p_day_of_week OUT VARCHAR2,
        p_is_holiday OUT BOOLEAN
    );

END audit_utils_pkg;
/

-- Make sure the specification is committed
COMMIT;

-- Now create the package body
CREATE OR REPLACE PACKAGE BODY audit_utils_pkg IS

    -- Function to check if date is a holiday (upcoming month only)
    FUNCTION is_public_holiday(p_check_date IN DATE DEFAULT SYSDATE) RETURN BOOLEAN IS
        v_holiday_count NUMBER;
    BEGIN
        -- Check if date is a holiday in the upcoming month
        SELECT COUNT(*)
        INTO v_holiday_count
        FROM public_holidays
        WHERE holiday_date = TRUNC(p_check_date)
          AND holiday_date BETWEEN TRUNC(SYSDATE) AND ADD_MONTHS(TRUNC(SYSDATE), 1);
        
        RETURN (v_holiday_count > 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_public_holiday;

    -- Function to check if today is a restricted day
    FUNCTION is_restricted_day RETURN BOOLEAN IS
        v_day_of_week VARCHAR2(10);
        v_is_holiday BOOLEAN;
    BEGIN
        -- Get day of week
        SELECT TO_CHAR(SYSDATE, 'DY') INTO v_day_of_week FROM DUAL;
        
        -- Check if weekday (Monday to Friday)
        IF v_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
            -- Weekdays are ALWAYS restricted regardless of holidays
            -- According to requirement: "CANNOT INSERT/UPDATE/DELETE on WEEKDAYS AND on PUBLIC HOLIDAYS"
            RETURN TRUE;
        END IF;
        
        -- Check if weekend is a holiday
        v_is_holiday := is_public_holiday(SYSDATE);
        RETURN v_is_holiday; -- Restricted only if it's a holiday on weekend
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_restricted_day;

    -- Procedure to get restriction details
    PROCEDURE get_restriction_details(
        p_is_restricted OUT BOOLEAN,
        p_reason OUT VARCHAR2,
        p_day_of_week OUT VARCHAR2,
        p_is_holiday OUT BOOLEAN
    ) IS
    BEGIN
        -- Get day of week
        SELECT TO_CHAR(SYSDATE, 'DY') INTO p_day_of_week FROM DUAL;
        
        -- Check if holiday (upcoming month only)
        p_is_holiday := is_public_holiday(SYSDATE);
        
        -- Determine restriction based on requirement
        IF p_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
            p_is_restricted := TRUE;
            p_reason := 'Weekday (Monday-Friday) - RESTRICTED';
        ELSE -- Weekend
            IF p_is_holiday THEN
                p_is_restricted := TRUE;
                p_reason := 'Weekend but public holiday (upcoming month) - RESTRICTED';
            ELSE
                p_is_restricted := FALSE;
                p_reason := 'Weekend (Saturday-Sunday) - ALLOWED';
            END IF;
        END IF;
        
    END get_restriction_details;

    -- Function to log audit entries
    PROCEDURE log_audit_event(
        p_table_name IN VARCHAR2,
        p_operation_type IN VARCHAR2,
        p_record_id IN VARCHAR2 DEFAULT NULL,
        p_old_values IN CLOB DEFAULT NULL,
        p_new_values IN CLOB DEFAULT NULL,
        p_is_restricted IN CHAR DEFAULT 'N',
        p_restriction_reason IN VARCHAR2 DEFAULT NULL,
        p_status IN VARCHAR2 DEFAULT 'ATTEMPTED',
        p_error_message IN VARCHAR2 DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_day_of_week VARCHAR2(10);
        v_is_holiday CHAR(1);
        v_restriction_reason VARCHAR2(200);
        v_error_msg VARCHAR2(4000);
    BEGIN
        -- Get day of week
        SELECT TO_CHAR(SYSDATE, 'DY') INTO v_day_of_week FROM DUAL;
        
        -- Check if holiday (upcoming month only)
        v_is_holiday := CASE WHEN is_public_holiday(SYSDATE) THEN 'Y' ELSE 'N' END;
        
        -- If restriction reason not provided, generate one
        IF p_restriction_reason IS NULL AND p_is_restricted = 'Y' THEN
            v_restriction_reason := 'Operation ' || p_operation_type || ' restricted on ' || v_day_of_week;
            IF v_is_holiday = 'Y' THEN
                v_restriction_reason := v_restriction_reason || ' (Public Holiday in upcoming month)';
            END IF;
        ELSE
            v_restriction_reason := p_restriction_reason;
        END IF;
        
        -- Insert audit record
        INSERT INTO energy_audit_log (
            table_name, operation_type, user_name,
            session_id, os_user, machine_name,
            record_id, old_values, new_values,
            restriction_reason, is_restricted,
            day_of_week, is_holiday, status, error_message
        ) VALUES (
            p_table_name, p_operation_type, USER,
            SYS_CONTEXT('USERENV', 'SESSIONID'),
            SYS_CONTEXT('USERENV', 'OS_USER'),
            SYS_CONTEXT('USERENV', 'HOST'),
            p_record_id, p_old_values, p_new_values,
            v_restriction_reason, p_is_restricted,
            v_day_of_week, v_is_holiday, p_status, p_error_message
        );
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- If audit logging fails, try to at least output to console
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Audit logging failed for ' || p_table_name || ': ' || SQLERRM);
                -- Store error message in variable first
                v_error_msg := 'Audit logging error: ' || SQLERRM;
                -- Attempt minimal logging
                INSERT INTO energy_audit_log (
                    table_name, operation_type, user_name, status, error_message
                ) VALUES (
                    p_table_name, p_operation_type, USER, 'FAILED', v_error_msg
                );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Give up if even minimal logging fails
            END;
    END log_audit_event;

END audit_utils_pkg;
/

-- Test the package compilation
SELECT object_name, object_type, status
FROM user_objects 
WHERE object_name = 'AUDIT_UTILS_PKG';

-- If package is invalid, try to recompile
BEGIN
    DBMS_UTILITY.COMPILE_SCHEMA(USER);
END;
/

-- Verify package status again
SELECT object_name, object_type, status
FROM user_objects 
WHERE object_name = 'AUDIT_UTILS_PKG';