SELECT 
    'User: ' || user as current_user,
    'Container: ' || sys_context('USERENV', 'CON_NAME') as current_container,
    'Database: ' || (SELECT name FROM v$database) as database_name
FROM dual;

-- =============================================
-- Phase V: Table Creation Script - FIXED
-- Smart Energy Monitoring System
-- =============================================

-- 1. BUILDINGS Table
CREATE TABLE buildings (
    building_id NUMBER(10) PRIMARY KEY,
    building_name VARCHAR2(100) NOT NULL,
    location VARCHAR2(200) NOT NULL,
    building_type VARCHAR2(50) NOT NULL CHECK (building_type IN ('Residential', 'Commercial', 'Industrial', 'Educational')),
    total_area_sqft NUMBER(10,2) NOT NULL CHECK (total_area_sqft > 0),
    construction_year NUMBER(4),
    owner_name VARCHAR2(100),
    contact_email VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE,
    last_updated DATE DEFAULT SYSDATE
);

-- 2. ENERGY_METERS Table
CREATE TABLE energy_meters (
    meter_id NUMBER(10) PRIMARY KEY,
    building_id NUMBER(10) NOT NULL,
    meter_serial VARCHAR2(50) UNIQUE NOT NULL,
    meter_type VARCHAR2(30) NOT NULL CHECK (meter_type IN ('Smart', 'Digital', 'Analog')),
    manufacturer VARCHAR2(50),
    installation_date DATE NOT NULL,
    capacity_kw NUMBER(8,2) CHECK (capacity_kw > 0),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    calibration_date DATE,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_meter_building FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

-- 3. CONSUMPTION_READINGS Table
CREATE TABLE consumption_readings (
    reading_id NUMBER(15) PRIMARY KEY,
    meter_id NUMBER(10) NOT NULL,
    reading_date DATE NOT NULL,
    reading_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    consumption_kwh NUMBER(10,4) NOT NULL CHECK (consumption_kwh >= 0),
    voltage_reading NUMBER(6,2),
    current_reading NUMBER(6,2),
    power_factor NUMBER(3,2) CHECK (power_factor BETWEEN 0.5 AND 1.0),
    cost_amount NUMBER(10,2) CHECK (cost_amount >= 0),
    temperature_celsius NUMBER(4,1),
    reading_quality CHAR(1) DEFAULT 'G' CHECK (reading_quality IN ('G', 'B', 'S')),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_reading_meter FOREIGN KEY (meter_id) REFERENCES energy_meters(meter_id)
);

-- 4. CONSUMPTION_THRESHOLDS Table - FIXED
CREATE TABLE consumption_thresholds (
    threshold_id NUMBER(10) PRIMARY KEY,
    building_id NUMBER(10) NOT NULL,
    threshold_type VARCHAR2(20) NOT NULL CHECK (threshold_type IN ('Daily', 'Monthly', 'Peak', 'Off-Peak')),
    warning_level_kwh NUMBER(10,2) NOT NULL CHECK (warning_level_kwh > 0),
    critical_level_kwh NUMBER(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    description VARCHAR2(200),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_threshold_building FOREIGN KEY (building_id) REFERENCES buildings(building_id),
    CONSTRAINT chk_critical_gt_warning CHECK (critical_level_kwh > warning_level_kwh)
);

-- 5. ALERTS Table
CREATE TABLE alerts (
    alert_id NUMBER(15) PRIMARY KEY,
    building_id NUMBER(10) NOT NULL,
    meter_id NUMBER(10),
    alert_type VARCHAR2(20) NOT NULL CHECK (alert_type IN ('WARNING', 'CRITICAL', 'MAINTENANCE', 'FAULT')),
    alert_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    consumption_value NUMBER(10,2) NOT NULL,
    threshold_value NUMBER(10,2) NOT NULL,
    severity_level VARCHAR2(10) CHECK (severity_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    alert_message VARCHAR2(500),
    status VARCHAR2(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SENT', 'ACKNOWLEDGED', 'RESOLVED')),
    resolved_date DATE,
    resolved_by VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_alert_building FOREIGN KEY (building_id) REFERENCES buildings(building_id),
    CONSTRAINT fk_alert_meter FOREIGN KEY (meter_id) REFERENCES energy_meters(meter_id)
);

-- 6. MAINTENANCE_LOGS Table
CREATE TABLE maintenance_logs (
    maintenance_id NUMBER(10) PRIMARY KEY,
    meter_id NUMBER(10) NOT NULL,
    maintenance_type VARCHAR2(30) NOT NULL CHECK (maintenance_type IN ('Calibration', 'Repair', 'Replacement', 'Inspection')),
    maintenance_date DATE NOT NULL,
    technician_name VARCHAR2(100),
    description VARCHAR2(500),
    cost_amount NUMBER(8,2),
    next_maintenance_date DATE,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_maintenance_meter FOREIGN KEY (meter_id) REFERENCES energy_meters(meter_id)
);

-- =============================================
-- Create Indexes for Performance - FIXED
-- =============================================

-- Buildings indexes
CREATE INDEX idx_buildings_type ON buildings(building_type);
CREATE INDEX idx_buildings_location ON buildings(location);

-- Energy Meters indexes (REMOVED duplicate meter_serial index - UNIQUE constraint already creates one)
CREATE INDEX idx_meters_building ON energy_meters(building_id);
-- CREATE INDEX idx_meters_serial ON energy_meters(meter_serial); -- REMOVED - UNIQUE constraint already indexes this
CREATE INDEX idx_meters_active ON energy_meters(is_active);

-- Consumption Readings indexes
CREATE INDEX idx_readings_meter_date ON consumption_readings(meter_id, reading_date);
CREATE INDEX idx_readings_date ON consumption_readings(reading_date);
CREATE INDEX idx_readings_quality ON consumption_readings(reading_quality);

-- Thresholds indexes - ADDED AFTER table creation
CREATE INDEX idx_thresholds_building ON consumption_thresholds(building_id);
CREATE INDEX idx_thresholds_active ON consumption_thresholds(is_active);
CREATE INDEX idx_thresholds_dates ON consumption_thresholds(effective_date, expiry_date);

-- Alerts indexes
CREATE INDEX idx_alerts_building ON alerts(building_id);
CREATE INDEX idx_alerts_timestamp ON alerts(alert_timestamp);
CREATE INDEX idx_alerts_status ON alerts(status);

-- Maintenance logs indexes
CREATE INDEX idx_maintenance_meter ON maintenance_logs(meter_id);
CREATE INDEX idx_maintenance_date ON maintenance_logs(maintenance_date);

-- Check existing sequences
SELECT sequence_name, last_number, increment_by 
FROM user_sequences 
ORDER BY sequence_name;

-- =============================================
-- Verify Table Creation
-- =============================================

SELECT table_name, tablespace_name 
FROM user_tables 
WHERE table_name IN ('BUILDINGS', 'ENERGY_METERS', 'CONSUMPTION_READINGS', 
                    'CONSUMPTION_THRESHOLDS', 'ALERTS', 'MAINTENANCE_LOGS');

SELECT sequence_name, last_number 
FROM user_sequences;

SELECT index_name, table_name, uniqueness 
FROM user_indexes 
WHERE table_name IN ('BUILDINGS', 'ENERGY_METERS', 'CONSUMPTION_READINGS', 
                    'CONSUMPTION_THRESHOLDS', 'ALERTS', 'MAINTENANCE_LOGS');
                    
                    
-- Create only the sequences that don't exist
BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_readings_id START WITH 1 INCREMENT BY 1';
        DBMS_OUTPUT.PUT_LINE('Created seq_readings_id');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -955 THEN -- ORA-00955: name already used
                RAISE;
            END IF;
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_alerts_id START WITH 1 INCREMENT BY 1';
        DBMS_OUTPUT.PUT_LINE('Created seq_alerts_id');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -955 THEN
                RAISE;
            END IF;
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_thresholds_id START WITH 1 INCREMENT BY 1';
        DBMS_OUTPUT.PUT_LINE('Created seq_thresholds_id');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -955 THEN
                RAISE;
            END IF;
    END;
END;
/    


-- Create CONSUMPTION_ARCHIVE table with matching structure
CREATE TABLE consumption_archive (
    reading_id NUMBER(15) PRIMARY KEY,
    meter_id NUMBER(10) NOT NULL,
    reading_date DATE NOT NULL,
    reading_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    consumption_kwh NUMBER(10,4) NOT NULL CHECK (consumption_kwh >= 0),
    voltage_reading NUMBER(6,2),
    current_reading NUMBER(6,2),
    power_factor NUMBER(3,2) CHECK (power_factor BETWEEN 0.5 AND 1.0),
    cost_amount NUMBER(10,2) CHECK (cost_amount >= 0),
    temperature_celsius NUMBER(4,1),
    reading_quality CHAR(1) DEFAULT 'G' CHECK (reading_quality IN ('G', 'B', 'S')),
    created_date DATE DEFAULT SYSDATE,
    archive_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_archive_meter FOREIGN KEY (meter_id) REFERENCES energy_meters(meter_id)
);

-- Create index for better performance
CREATE INDEX idx_archive_meter_date ON consumption_archive(meter_id, reading_date);