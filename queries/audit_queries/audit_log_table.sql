-- =============================================
-- File: 16_audit_log_table.sql
-- Comprehensive Audit Logging Table
-- =============================================

-- Create comprehensive audit log table
CREATE TABLE energy_audit_log (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    audit_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE', 'BLOCKED')),
    user_name VARCHAR2(100) DEFAULT USER NOT NULL,
    session_id NUMBER DEFAULT SYS_CONTEXT('USERENV', 'SESSIONID'),
    os_user VARCHAR2(100) DEFAULT SYS_CONTEXT('USERENV', 'OS_USER'),
    machine_name VARCHAR2(100) DEFAULT SYS_CONTEXT('USERENV', 'HOST'),
    
    -- Record details
    record_id VARCHAR2(100), -- Stores primary key or composite key info
    old_values CLOB, -- Stores old values for UPDATE/DELETE
    new_values CLOB, -- Stores new values for INSERT/UPDATE
    
    -- Restriction info
    restriction_reason VARCHAR2(200),
    is_restricted CHAR(1) DEFAULT 'N' CHECK (is_restricted IN ('Y', 'N')),
    day_of_week VARCHAR2(10),
    is_holiday CHAR(1) DEFAULT 'N' CHECK (is_holiday IN ('Y', 'N')),
    
    -- Status
    status VARCHAR2(20) DEFAULT 'ATTEMPTED' CHECK (status IN ('ATTEMPTED', 'COMPLETED', 'BLOCKED', 'FAILED')),
    error_message VARCHAR2(4000)
);

-- Create indexes for performance
CREATE INDEX idx_audit_timestamp ON energy_audit_log(audit_timestamp);
CREATE INDEX idx_audit_operation ON energy_audit_log(operation_type, table_name);
CREATE INDEX idx_audit_user ON energy_audit_log(user_name, audit_timestamp);
CREATE INDEX idx_audit_restricted ON energy_audit_log(is_restricted, day_of_week);

COMMIT; -- Add COMMIT here to ensure table is committed

-- Now create the view
CREATE OR REPLACE VIEW audit_summary_vw AS
SELECT 
    TRUNC(audit_timestamp) as audit_date,
    table_name,
    operation_type,
    is_restricted,
    day_of_week,
    is_holiday,
    COUNT(*) as attempt_count,
    COUNT(CASE WHEN is_restricted = 'Y' THEN 1 END) as blocked_count,
    COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_count
FROM energy_audit_log
GROUP BY TRUNC(audit_timestamp), table_name, operation_type, is_restricted, day_of_week, is_holiday
ORDER BY audit_date DESC, table_name;

COMMIT;

ALTER TABLE energy_audit_log 
MODIFY operation_type VARCHAR2(20);
