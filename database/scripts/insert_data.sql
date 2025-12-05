-- =============================================
-- Phase V: Data Insertion Script
-- Smart Energy Monitoring System
-- =============================================

-- 1. Insert Buildings Data (15 realistic buildings)
INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'AUCA Main Campus', 'KG 7 Ave, Kigali', 'Educational', 50000, 2015, 'AUCA', 'admin@auca.ac.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Kigali Heights Mall', 'KN 4 Ave, Kigali', 'Commercial', 25000, 2018, 'Horizon Ltd', 'manager@kigalihights.com');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Green Apartments', 'KG 11 St, Kigali', 'Residential', 15000, 2020, 'Green Properties', 'info@greenapt.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Kigali Business Center', 'KG 1 Ave, Kigali', 'Commercial', 40000, 2016, 'KBC Management', 'contact@kbc.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'University Teaching Hospital', 'KK 73 St, Kigali', 'Commercial', 75000, 2014, 'Ministry of Health', 'admin@uth.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Vision 2020 Apartments', 'KG 258 St, Kigali', 'Residential', 30000, 2019, 'Vision Developers', 'leasing@vision2020.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Kigali Industrial Park', 'KG 400 St, Kigali', 'Industrial', 120000, 2012, 'RDB', 'industry@rdb.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Kigali Convention Center', 'KG 2 Ave, Kigali', 'Commercial', 80000, 2016, 'RDB', 'events@kcc.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Rwanda Polytechnic', 'KK 15 Ave, Kigali', 'Educational', 45000, 2017, 'RP', 'info@rp.ac.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Kigali Marriott Hotel', 'KN 3 Ave, Kigali', 'Commercial', 35000, 2018, 'Marriott International', 'reservations@marriott.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Kigali Innovation City', 'KG 5 Ave, Kigali', 'Commercial', 60000, 2021, 'KIC Ltd', 'info@innovationcity.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Sunrise Villas', 'KG 300 St, Kigali', 'Residential', 20000, 2019, 'Sunrise Developers', 'sales@sunrise.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Kigali Tech Hub', 'KG 9 Ave, Kigali', 'Commercial', 30000, 2020, 'Tech Rwanda', 'hello@techhub.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Peace Academy', 'KK 22 Ave, Kigali', 'Educational', 35000, 2016, 'Peace Education', 'admissions@peaceacademy.rw');

INSERT INTO buildings (building_id, building_name, location, building_type, total_area_sqft, construction_year, owner_name, contact_email) VALUES
(seq_buildings_id.NEXTVAL, 'Mountain View Apartments', 'KG 450 St, Kigali', 'Residential', 25000, 2021, 'Mountain Developers', 'rent@mountainview.rw');

COMMIT;

-- 2. Insert Energy Meters Data (15 meters - one per building for simplicity)
INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1001, 'SMART-AUCA-001', 'Smart', 'Siemens', DATE '2023-01-15', 100.00, 'Y', DATE '2023-07-15');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1002, 'SMART-KH-001', 'Smart', 'Schneider', DATE '2023-01-20', 150.00, 'Y', DATE '2023-07-20');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1003, 'DIGI-GA-001', 'Digital', 'ABB', DATE '2022-11-10', 75.00, 'Y', DATE '2023-05-10');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1004, 'SMART-KBC-001', 'Smart', 'Siemens', DATE '2022-12-05', 120.00, 'Y', DATE '2023-06-05');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1005, 'ANALOG-UTH-001', 'Analog', 'General Electric', DATE '2020-03-20', 60.00, 'Y', DATE '2023-09-20');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1006, 'DIGI-VA-001', 'Digital', 'Landis+Gyr', DATE '2021-08-15', 80.00, 'Y', DATE '2023-02-15');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1007, 'SMART-KBC-002', 'Smart', 'Schneider', DATE '2023-03-10', 200.00, 'Y', DATE '2023-09-10');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1008, 'SMART-KCC-001', 'Smart', 'Siemens', DATE '2023-03-12', 180.00, 'Y', DATE '2023-09-12');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1009, 'DIGI-UTH-002', 'Digital', 'ABB', DATE '2022-06-25', 300.00, 'Y', DATE '2022-12-25');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1010, 'SMART-UTH-003', 'Smart', 'Siemens', DATE '2022-07-01', 250.00, 'Y', DATE '2023-01-01');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1011, 'DIGI-VA-002', 'Digital', 'Landis+Gyr', DATE '2021-05-10', 90.00, 'Y', DATE '2023-11-10');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1012, 'SMART-KIP-001', 'Smart', 'Siemens', DATE '2023-02-20', 500.00, 'Y', DATE '2023-08-20');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1013, 'SMART-KCC-002', 'Smart', 'Schneider', DATE '2023-04-15', 400.00, 'Y', DATE '2023-10-15');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1014, 'DIGI-RP-001', 'Digital', 'ABB', DATE '2022-09-01', 120.00, 'Y', DATE '2023-03-01');

INSERT INTO energy_meters (meter_id, building_id, meter_serial, meter_type, manufacturer, installation_date, capacity_kw, is_active, calibration_date) VALUES
(seq_meters_id.NEXTVAL, 1015, 'SMART-KMH-001', 'Smart', 'Siemens', DATE '2023-05-20', 180.00, 'Y', DATE '2023-11-20');

COMMIT;

-- 3. Insert Consumption Thresholds (Realistic energy limits)
INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1001, 'Daily', 1200.00, 1500.00, DATE '2024-01-01', 'Y', 'Main campus daily limit');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1002, 'Daily', 800.00, 1000.00, DATE '2024-01-01', 'Y', 'Commercial building daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1003, 'Daily', 400.00, 600.00, DATE '2024-01-01', 'Y', 'Residential apartments');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1004, 'Daily', 1500.00, 2000.00, DATE '2024-01-01', 'Y', 'Business center daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1005, 'Daily', 2500.00, 3500.00, DATE '2024-01-01', 'Y', 'Hospital daily consumption');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1006, 'Daily', 600.00, 900.00, DATE '2024-01-01', 'Y', 'Residential complex');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1007, 'Daily', 5000.00, 7000.00, DATE '2024-01-01', 'Y', 'Industrial park limit');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1008, 'Daily', 3000.00, 4500.00, DATE '2024-01-01', 'Y', 'Convention center daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1009, 'Daily', 1000.00, 1300.00, DATE '2024-01-01', 'Y', 'Polytechnic daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1010, 'Daily', 1400.00, 1800.00, DATE '2024-01-01', 'Y', 'Hotel daily limit');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1011, 'Daily', 1800.00, 2200.00, DATE '2024-01-01', 'Y', 'Innovation city daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1012, 'Daily', 500.00, 700.00, DATE '2024-01-01', 'Y', 'Villas daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1013, 'Daily', 900.00, 1200.00, DATE '2024-01-01', 'Y', 'Tech hub daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1014, 'Daily', 800.00, 1100.00, DATE '2024-01-01', 'Y', 'Academy daily');

INSERT INTO consumption_thresholds (threshold_id, building_id, threshold_type, warning_level_kwh, critical_level_kwh, effective_date, is_active, description) VALUES
(seq_thresholds_id.NEXTVAL, 1015, 'Daily', 450.00, 650.00, DATE '2024-01-01', 'Y', 'Apartments daily');

COMMIT;

-- 4. Insert Consumption Readings (Complete set - FIXED for NOT NULL constraints)
-- Day 1 - All 15 meters
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5001, DATE '2024-01-01', 1250.50, 240.00, 187.58, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5002, DATE '2024-01-01', 850.75, 239.50, 127.61, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5003, DATE '2024-01-01', 420.25, 238.00, 63.04, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5004, DATE '2024-01-01', 1480.00, 241.50, 222.00, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5005, DATE '2024-01-01', 2350.80, 242.00, 352.62, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5006, DATE '2024-01-01', 5200.25, 245.00, 780.04, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5007, DATE '2024-01-01', 3800.50, 244.00, 570.08, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5008, DATE '2024-01-01', 3200.75, 243.50, 480.11, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5009, DATE '2024-01-01', 1100.25, 240.00, 165.04, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5010, DATE '2024-01-01', 1650.80, 241.00, 247.62, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5011, DATE '2024-01-01', 1950.40, 242.00, 292.56, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5012, DATE '2024-01-01', 580.60, 239.00, 87.09, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5013, DATE '2024-01-01', 1050.90, 240.50, 157.64, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5014, DATE '2024-01-01', 920.30, 239.50, 138.05, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5015, DATE '2024-01-01', 480.75, 238.50, 72.11, 'G');

-- Day 2 - All 15 meters
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5001, DATE '2024-01-02', 1180.25, 239.50, 177.04, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5002, DATE '2024-01-02', 920.50, 240.00, 138.08, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5003, DATE '2024-01-02', 380.75, 237.50, 57.11, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5004, DATE '2024-01-02', 1620.30, 242.50, 243.05, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5005, DATE '2024-01-02', 2480.90, 243.00, 372.14, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5006, DATE '2024-01-02', 5350.40, 245.50, 802.56, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5007, DATE '2024-01-02', 3950.25, 244.20, 592.54, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5008, DATE '2024-01-02', 3280.60, 243.80, 492.09, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5009, DATE '2024-01-02', 1150.80, 240.80, 172.62, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5010, DATE '2024-01-02', 1720.45, 241.50, 258.07, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5011, DATE '2024-01-02', 2020.75, 242.20, 303.11, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5012, DATE '2024-01-02', 620.25, 239.20, 93.04, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5013, DATE '2024-01-02', 980.50, 240.20, 147.08, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5014, DATE '2024-01-02', 890.75, 239.80, 133.61, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5015, DATE '2024-01-02', 520.40, 238.80, 78.06, 'G');

-- Day 3 - All 15 meters (Weekend patterns - lower consumption)
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5001, DATE '2024-01-03', 980.50, 238.50, 147.08, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5002, DATE '2024-01-03', 720.25, 239.00, 108.04, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5003, DATE '2024-01-03', 350.00, 238.00, 52.50, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5004, DATE '2024-01-03', 1320.75, 241.00, 198.11, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5005, DATE '2024-01-03', 2150.60, 242.50, 322.59, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5006, DATE '2024-01-03', 4850.80, 244.50, 727.62, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5007, DATE '2024-01-03', 3450.25, 243.50, 517.54, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5008, DATE '2024-01-03', 2850.90, 242.80, 427.64, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5009, DATE '2024-01-03', 950.40, 239.80, 142.56, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5010, DATE '2024-01-03', 1420.25, 240.50, 213.04, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5011, DATE '2024-01-03', 1680.75, 241.20, 252.11, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5012, DATE '2024-01-03', 480.60, 238.50, 72.09, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5013, DATE '2024-01-03', 820.90, 239.50, 123.14, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5014, DATE '2024-01-03', 760.30, 239.00, 114.05, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5015, DATE '2024-01-03', 420.75, 238.00, 63.11, 'G');

-- Day 4 - Add edge cases (FIXED - no NULLs in required columns)
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5001, DATE '2024-01-04', 0.00, 235.00, 0.00, 'B'); -- Zero consumption (fault) - FIXED: added voltage
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5002, DATE '2024-01-04', 1.50, 240.50, 0.23, 'B'); -- Very low consumption (error) - FIXED: removed NULL
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5003, DATE '2024-01-04', 50.25, 235.00, 7.54, 'G'); -- Very low (weekend)
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5004, DATE '2024-01-04', 1850.00, 242.50, 277.50, 'S'); -- Suspicious high
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5005, DATE '2024-01-04', 2650.80, 243.00, 397.62, 'G'); -- Above threshold
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5006, DATE '2024-01-04', 5600.25, 245.80, 840.04, 'G'); -- Industrial high
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5007, DATE '2024-01-04', 4200.50, 244.50, 630.08, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5008, DATE '2024-01-04', 3500.75, 244.00, 525.11, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5009, DATE '2024-01-04', 1250.25, 241.00, 187.54, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5010, DATE '2024-01-04', 1780.80, 242.00, 267.12, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5011, DATE '2024-01-04', 2150.40, 242.80, 322.56, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5012, DATE '2024-01-04', 680.60, 239.50, 102.09, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5013, DATE '2024-01-04', 1150.90, 241.00, 172.64, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5014, DATE '2024-01-04', 980.30, 240.00, 147.05, 'G');
INSERT INTO consumption_readings (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (seq_readings_id.NEXTVAL, 5015, DATE '2024-01-04', 550.75, 239.00, 82.61, 'G');

COMMIT;

-- Verify we have 100+ readings
SELECT 'Consumption Readings Count: ' || COUNT(*) as row_count FROM consumption_readings;


-- 5. Insert Alerts (Based on threshold breaches and maintenance)
INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1001, 5001, 'WARNING', 1250.50, 1200.00, 'MEDIUM', 'ACKNOWLEDGED', 'Daily consumption exceeded warning level at AUCA');

INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1001, 5001, 'CRITICAL', 1550.25, 1500.00, 'HIGH', 'RESOLVED', 'Critical consumption level reached - investigation completed');

INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1002, 5002, 'WARNING', 850.75, 800.00, 'MEDIUM', 'PENDING', 'Kigali Heights Mall approaching daily limit');

INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1005, 5005, 'MAINTENANCE', 0.00, 0.00, 'LOW', 'SENT', 'Meter calibration due next month at Hospital'); -- FIXED: removed NULLs

INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1003, 5003, 'FAULT', 0.00, 0.00, 'HIGH', 'ACKNOWLEDGED', 'Meter reading zero - possible fault at Green Apartments'); -- FIXED: removed NULLs

INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1007, 5006, 'WARNING', 5200.00, 5000.00, 'MEDIUM', 'PENDING', 'Industrial consumption approaching critical level');

INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1008, 5007, 'CRITICAL', 4800.25, 4500.00, 'HIGH', 'ACKNOWLEDGED', 'Convention center exceeded critical limit');

INSERT INTO alerts (alert_id, building_id, meter_id, alert_type, consumption_value, threshold_value, severity_level, status, alert_message) VALUES
(seq_alerts_id.NEXTVAL, 1010, 5010, 'WARNING', 1450.00, 1400.00, 'MEDIUM', 'SENT', 'Hotel consumption above warning level');

COMMIT;

-- 6. Insert Maintenance Logs
INSERT INTO maintenance_logs (maintenance_id, meter_id, maintenance_type, maintenance_date, technician_name, description, cost_amount, next_maintenance_date) VALUES
(seq_maintenance_id.NEXTVAL, 5001, 'Calibration', DATE '2023-07-15', 'John Gasana', 'Routine calibration performed - all parameters within range', 150.00, DATE '2024-01-15');

INSERT INTO maintenance_logs (maintenance_id, meter_id, maintenance_type, maintenance_date, technician_name, description, cost_amount, next_maintenance_date) VALUES
(seq_maintenance_id.NEXTVAL, 5002, 'Repair', DATE '2023-05-10', 'Marie Uwase', 'Replaced display unit and communication module', 300.00, DATE '2023-11-10');

INSERT INTO maintenance_logs (maintenance_id, meter_id, maintenance_type, maintenance_date, technician_name, description, cost_amount, next_maintenance_date) VALUES
(seq_maintenance_id.NEXTVAL, 5003, 'Inspection', DATE '2023-09-20', 'Eric Mani', 'Annual safety inspection completed - no issues found', 200.00, DATE '2024-03-20');

INSERT INTO maintenance_logs (maintenance_id, meter_id, maintenance_type, maintenance_date, technician_name, description, cost_amount, next_maintenance_date) VALUES
(seq_maintenance_id.NEXTVAL, 5004, 'Replacement', DATE '2023-09-10', 'Alice Mukamana', 'Upgraded analog meter to smart meter with remote monitoring', 500.00, DATE '2024-03-10');

INSERT INTO maintenance_logs (maintenance_id, meter_id, maintenance_type, maintenance_date, technician_name, description, cost_amount, next_maintenance_date) VALUES
(seq_maintenance_id.NEXTVAL, 5005, 'Calibration', DATE '2022-12-25', 'Peter Habimana', 'Preventive maintenance and calibration for hospital equipment', 180.00, DATE '2023-06-25');

INSERT INTO maintenance_logs (maintenance_id, meter_id, maintenance_type, maintenance_date, technician_name, description, cost_amount, next_maintenance_date) VALUES
(seq_maintenance_id.NEXTVAL, 5006, 'Repair', DATE '2023-08-15', 'Jean Bosco', 'Fixed communication module and sensor alignment', 250.00, DATE '2024-02-15');

INSERT INTO maintenance_logs (maintenance_id, meter_id, maintenance_type, maintenance_date, technician_name, description, cost_amount, next_maintenance_date) VALUES
(seq_maintenance_id.NEXTVAL, 5007, 'Inspection', DATE '2023-10-05', 'Annette Mujawimana', 'Quarterly performance check - optimal operation', 175.00, DATE '2024-04-05');

COMMIT;

-- Insert archive data from 2023 (older than your current 2024 data)
-- Using meter IDs 5001-5015 from your existing data

-- November 2023 Archive Data
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9001, 5001, DATE '2023-11-15', 1180.25, 239.50, 177.04, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9002, 5002, DATE '2023-11-15', 780.50, 238.00, 117.08, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9003, 5003, DATE '2023-11-15', 350.75, 237.00, 52.61, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9004, 5004, DATE '2023-11-15', 1420.30, 241.00, 213.05, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9005, 5005, DATE '2023-11-15', 2280.90, 242.00, 342.14, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9006, 5006, DATE '2023-11-15', 4950.40, 244.00, 742.56, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9007, 5007, DATE '2023-11-15', 3650.25, 243.00, 547.54, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9008, 5008, DATE '2023-11-15', 2980.60, 242.50, 447.09, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9009, 5009, DATE '2023-11-15', 980.80, 239.50, 147.12, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9010, 5010, DATE '2023-11-15', 1520.45, 240.50, 228.07, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9011, 5011, DATE '2023-11-15', 1820.75, 241.00, 273.11, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9012, 5012, DATE '2023-11-15', 520.25, 238.00, 78.04, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9013, 5013, DATE '2023-11-15', 880.50, 239.00, 132.08, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9014, 5014, DATE '2023-11-15', 790.75, 238.50, 118.61, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9015, 5015, DATE '2023-11-15', 450.40, 237.50, 67.56, 'G');

-- October 2023 Archive Data
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9016, 5001, DATE '2023-10-10', 1120.50, 239.00, 168.08, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9017, 5002, DATE '2023-10-10', 820.25, 238.50, 123.04, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9018, 5003, DATE '2023-10-10', 380.00, 237.20, 57.00, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9019, 5004, DATE '2023-10-10', 1380.75, 240.50, 207.11, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9020, 5005, DATE '2023-10-10', 2220.60, 241.50, 333.09, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9021, 5006, DATE '2023-10-10', 4850.80, 243.50, 727.62, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9022, 5007, DATE '2023-10-10', 3550.25, 242.50, 532.54, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9023, 5008, DATE '2023-10-10', 2880.90, 242.00, 432.14, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9024, 5009, DATE '2023-10-10', 920.40, 239.00, 138.06, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9025, 5010, DATE '2023-10-10', 1480.25, 240.00, 222.04, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9026, 5011, DATE '2023-10-10', 1780.75, 240.80, 267.11, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9027, 5012, DATE '2023-10-10', 480.60, 237.80, 72.09, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9028, 5013, DATE '2023-10-10', 850.90, 238.50, 127.64, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9029, 5014, DATE '2023-10-10', 740.30, 238.00, 111.05, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9030, 5015, DATE '2023-10-10', 420.75, 237.00, 63.11, 'G');

-- September 2023 Archive Data (with some suspicious readings)
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9031, 5001, DATE '2023-09-05', 1050.25, 238.50, 157.54, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9032, 5002, DATE '2023-09-05', 750.50, 238.00, 112.58, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9033, 5003, DATE '2023-09-05', 320.75, 236.50, 48.11, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9034, 5004, DATE '2023-09-05', 1320.30, 240.00, 198.05, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9035, 5005, DATE '2023-09-05', 2150.90, 241.00, 322.64, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9036, 5006, DATE '2023-09-05', 4750.40, 243.00, 712.56, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9037, 5007, DATE '2023-09-05', 3450.25, 242.00, 517.54, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9038, 5008, DATE '2023-09-05', 2780.60, 241.50, 417.09, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9039, 5009, DATE '2023-09-05', 880.80, 238.50, 132.12, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9040, 5010, DATE '2023-09-05', 1420.45, 239.50, 213.07, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9041, 5011, DATE '2023-09-05', 1720.75, 240.00, 258.11, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9042, 5012, DATE '2023-09-05', 450.25, 237.00, 67.54, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9043, 5013, DATE '2023-09-05', 800.50, 238.00, 120.08, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9044, 5014, DATE '2023-09-05', 720.75, 237.50, 108.11, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9045, 5015, DATE '2023-09-05', 400.40, 236.50, 60.06, 'G');

-- August 2023 - Some bad quality readings for testing
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9046, 5001, DATE '2023-08-20', 0.00, 235.00, 0.00, 'B');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9047, 5002, DATE '2023-08-20', 1850.00, 242.00, 277.50, 'S');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9048, 5003, DATE '2023-08-20', 280.75, 236.00, 42.11, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9049, 5004, DATE '2023-08-20', 1280.30, 239.50, 192.05, 'G');
INSERT INTO consumption_archive (reading_id, meter_id, reading_date, consumption_kwh, voltage_reading, cost_amount, reading_quality) VALUES (9050, 5005, DATE '2023-08-20', 2080.90, 240.50, 312.14, 'G');

COMMIT;

-- Final confirmation
SELECT 'Data insertion completed successfully!' as status FROM dual;
-- =============================================
-- Data Insertion Complete!
-- =============================================

-- Final Row Count Verification
SELECT 'PHASE V DATA SUMMARY:' as summary FROM dual;
SELECT 'BUILDINGS: ' || COUNT(*) as count FROM buildings
UNION ALL SELECT 'ENERGY_METERS: ' || COUNT(*) FROM energy_meters
UNION ALL SELECT 'CONSUMPTION_READINGS: ' || COUNT(*) FROM consumption_readings
UNION ALL SELECT 'CONSUMPTION_THRESHOLDS: ' || COUNT(*) FROM consumption_thresholds
UNION ALL SELECT 'ALERTS: ' || COUNT(*) FROM alerts
UNION ALL SELECT 'MAINTENANCE_LOGS: ' || COUNT(*) FROM maintenance_logs;

SELECT '🎉 PHASE V COMPLETED SUCCESSFULLY!' as status FROM dual;

