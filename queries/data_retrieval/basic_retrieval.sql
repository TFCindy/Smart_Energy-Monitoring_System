-- 1. BASIC RETRIEVAL (SELECT *)
SELECT '1. BASIC RETRIEVAL (SELECT *)' as test_type FROM dual;

SELECT 'BUILDINGS (first 5):' as table_name FROM dual;
SELECT * FROM buildings WHERE ROWNUM <= 5;

SELECT 'ENERGY_METERS (first 5):' as table_name FROM dual;
SELECT * FROM energy_meters WHERE ROWNUM <= 5;

SELECT 'CONSUMPTION_READINGS (first 5):' as table_name FROM dual;
SELECT * FROM consumption_readings WHERE ROWNUM <= 5;

SELECT 'CONSUMPTION_THRESHOLDS (first 5):' as table_name FROM dual;
SELECT * FROM consumption_thresholds WHERE ROWNUM <= 5;

SELECT 'ALERTS (first 5):' as table_name FROM dual;
SELECT * FROM alerts WHERE ROWNUM <= 5;

SELECT 'MAINTENANCE_LOGS (first 5):' as table_name FROM dual;
SELECT * FROM maintenance_logs WHERE ROWNUM <= 5;
