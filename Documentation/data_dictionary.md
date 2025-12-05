# Data Dictionary

## Tables

### BUILDINGS
| Column | Type | PK/FK | Null | Default | Description |
|--------|------|--------|------|---------|-------------|
| BUILDING_ID | NUMBER | PK | N | SEQ_BUILDINGS_ID | Unique ID |
| BUILDING_NAME | VARCHAR2(100) | | N | | Building name |
| LOCATION | VARCHAR2(200) | | N | | Physical address |
| BUILDING_TYPE | VARCHAR2(50) | | N | | Type: Educational/Office/Commercial |
| TOTAL_AREA_SQFT | NUMBER(10,2) | | Y | | Area in square feet |
| CONSTRUCTION_YEAR | NUMBER(4) | | Y | | Year built |
| OWNER_NAME | VARCHAR2(100) | | Y | | Owner name |
| CONTACT_EMAIL | VARCHAR2(100) | | Y | | Contact email |

### ENERGY_METERS
| Column | Type | PK/FK | Null | Default | Description |
|--------|------|--------|------|---------|-------------|
| METER_ID | NUMBER | PK | N | SEQ_METERS_ID | Unique ID |
| BUILDING_ID | NUMBER | FK → BUILDINGS | N | | Building reference |
| METER_SERIAL | VARCHAR2(50) | | N | | Serial number |
| METER_TYPE | VARCHAR2(30) | | N | | Smart/Analog/Digital |
| MANUFACTURER | VARCHAR2(50) | | Y | | Manufacturer |
| INSTALLATION_DATE | DATE | | N | | Install date |
| CAPACITY_KW | NUMBER(10,2) | | Y | | Max capacity |
| IS_ACTIVE | CHAR(1) | | N | 'Y' | Active status (Y/N) |
| CALIBRATION_DATE | DATE | | Y | | Last calibration |

### CONSUMPTION_READINGS
| Column | Type | PK/FK | Null | Default | Description |
|--------|------|--------|------|---------|-------------|
| READING_ID | NUMBER | PK | N | SEQ_READINGS_ID | Unique ID |
| METER_ID | NUMBER | FK → ENERGY_METERS | N | | Meter reference |
| READING_DATE | DATE | | N | | Reading timestamp |
| CONSUMPTION_KWH | NUMBER(10,2) | | N | | kWh consumed |
| VOLTAGE_READING | NUMBER(6,2) | | Y | | Voltage |
| COST_AMOUNT | NUMBER(10,2) | | N | | Calculated cost |
| READING_QUALITY | CHAR(1) | | Y | 'G' | Quality: G/F/P |

### CONSUMPTION_THRESHOLDS
| Column | Type | PK/FK | Null | Default | Description |
|--------|------|--------|------|---------|-------------|
| THRESHOLD_ID | NUMBER | PK | N | SEQ_THRESHOLDS_ID | Unique ID |
| BUILDING_ID | NUMBER | FK → BUILDINGS | N | | Building reference |
| THRESHOLD_TYPE | VARCHAR2(20) | | N | | Daily/Weekly/Monthly |
| WARNING_LEVEL_KWH | NUMBER(10,2) | | N | | Warning level |
| CRITICAL_LEVEL_KWH | NUMBER(10,2) | | N | | Critical level |
| EFFECTIVE_DATE | DATE | | N | SYSDATE | Start date |
| IS_ACTIVE | CHAR(1) | | N | 'Y' | Active status |
| DESCRIPTION | VARCHAR2(200) | | Y | | Description |

### MAINTENANCE_LOGS
| Column | Type | PK/FK | Null | Default | Description |
|--------|------|--------|------|---------|-------------|
| MAINTENANCE_ID | NUMBER | PK | N | SEQ_MAINTENANCE_ID | Unique ID |
| METER_ID | NUMBER | FK → ENERGY_METERS | N | | Meter reference |
| MAINTENANCE_TYPE | VARCHAR2(30) | | N | | Type: Calibration/Repair |
| MAINTENANCE_DATE | DATE | | N | | Date performed |
| TECHNICIAN_NAME | VARCHAR2(100) | | N | | Technician name |
| DESCRIPTION | VARCHAR2(500) | | Y | | Work description |
| COST_AMOUNT | NUMBER(10,2) | | Y | | Cost |
| NEXT_MAINTENANCE_DATE | DATE | | Y | | Next due date |

### PUBLIC_HOLIDAYS (Business Rule)
| Column | Type | PK/FK | Null | Default | Description |
|--------|------|--------|------|---------|-------------|
| HOLIDAY_ID | NUMBER | PK | N | GENERATED ALWAYS AS IDENTITY | Unique ID |
| HOLIDAY_NAME | VARCHAR2(100) | | N | | Holiday name |
| HOLIDAY_DATE | DATE | | N | | Date |
| HOLIDAY_TYPE | VARCHAR2(30) | | N | 'Public' | Type: Public/National/Religious |
| COUNTRY | VARCHAR2(50) | | N | 'USA' | Country |
| IS_RECURRING | CHAR(1) | | N | 'N' | Recurring: Y/N |
| CREATED_DATE | DATE | | N | SYSDATE | Created date |
| CREATED_BY | VARCHAR2(100) | | N | USER | Creator |

### ENERGY_AUDIT_LOG (Audit)
| Column | Type | PK/FK | Null | Default | Description |
|--------|------|--------|------|---------|-------------|
| AUDIT_ID | NUMBER | PK | N | GENERATED ALWAYS AS IDENTITY | Unique ID |
| AUDIT_TIMESTAMP | TIMESTAMP | | N | SYSTIMESTAMP | Audit time |
| TABLE_NAME | VARCHAR2(50) | | N | | Table name |
| OPERATION_TYPE | VARCHAR2(10) | | N | | INSERT/UPDATE/DELETE/BLOCKED |
| USER_NAME | VARCHAR2(100) | | N | USER | Database user |
| SESSION_ID | NUMBER | | N | SYS_CONTEXT('USERENV','SESSIONID') | Session ID |
| OS_USER | VARCHAR2(100) | | N | SYS_CONTEXT('USERENV','OS_USER') | OS user |
| MACHINE_NAME | VARCHAR2(100) | | N | SYS_CONTEXT('USERENV','HOST') | Machine name |
| RECORD_ID | VARCHAR2(100) | | Y | | Record identifier |
| OLD_VALUES | CLOB | | Y | | Old values (JSON) |
| NEW_VALUES | CLOB | | Y | | New values (JSON) |
| RESTRICTION_REASON | VARCHAR2(200) | | Y | | Restriction reason |
| IS_RESTRICTED | CHAR(1) | | N | 'N' | Restricted: Y/N |
| DAY_OF_WEEK | VARCHAR2(10) | | Y | | Day of week |
| IS_HOLIDAY | CHAR(1) | | N | 'N' | Holiday: Y/N |
| STATUS | VARCHAR2(20) | | N | 'ATTEMPTED' | Status: ATTEMPTED/COMPLETED/BLOCKED/FAILED |
| ERROR_MESSAGE | VARCHAR2(4000) | | Y | | Error message |

## Sequences
- SEQ_BUILDINGS_ID
- SEQ_METERS_ID  
- SEQ_READINGS_ID
- SEQ_THRESHOLDS_ID
- SEQ_MAINTENANCE_ID

## Indexes
- All primary keys
- Foreign key columns
- Frequent search columns (dates, names, serials)
- Audit timestamp for reporting

## Views
- AUDIT_SUMMARY_VW
- DML_RESTRICTION_STATUS_VW
- EXEC_DASHBOARD_VW (optional)

## Triggers
- 5 Simple triggers (one per operational table)
- 2 Compound triggers (BUILDINGS, ENERGY_METERS)
- All BEFORE INSERT/UPDATE/DELETE
- Enforce weekday/holiday restrictions

## Packages
- AUDIT_UTILS_PKG: Logging and restriction checking