# Key Performance Indicators (KPIs) Definition

## 📋 Overview
This document defines all Key Performance Indicators (KPIs) used in the Energy Management System dashboards, including their calculations, targets, and business significance.

## 🎯 Strategic KPIs

### 1. Total Energy Consumption
**Metric ID:** KPI-001  
**Description:** Total energy consumed across all buildings  
**Unit:** Kilowatt-hours (kWh)  
**Calculation:** 
```sql
SELECT SUM(consumption_kwh) 
FROM consumption_readings 
WHERE reading_date >= TRUNC(SYSDATE, 'MM');
```
Frequency: Monthly
Target: Reduce by 15% year-over-year
Owner: Energy Manager
Data Source: consumption_readings
Business Impact: Directly affects operational costs

### 2. Total Energy Cost
Metric ID: KPI-002
Description: Total cost of energy consumption
Unit: USD ($)
Calculation:
```sql
SELECT SUM(cost_amount) 
FROM consumption_readings 
WHERE reading_date >= TRUNC(SYSDATE, 'MM');
```
Frequency: Monthly
Target: Reduce by 10% year-over-year
Owner: Finance Director
Data Source: consumption_readings
Business Impact: Bottom-line financial performance

### 3. Cost per Square Foot
Metric ID: KPI-003
Description: Energy cost normalized by building area
Unit: USD per sq.ft.
Calculation:
```sql
SELECT b.building_name,
       SUM(cr.cost_amount) / b.total_area_sqft as cost_per_sqft
FROM consumption_readings cr
JOIN energy_meters em ON cr.meter_id = em.meter_id
JOIN buildings b ON em.building_id = b.building_id
WHERE cr.reading_date >= TRUNC(SYSDATE, 'MM')
GROUP BY b.building_name, b.total_area_sqft;
```
Frequency: Quarterly
Target: < $2.50 per sq.ft. annually
Owner: Facilities Manager
Benchmark: Industry average: $2.75/sq.ft.

## ⚡ Operational KPIs
### 4. Peak Demand
Metric ID: KPI-004
Description: Maximum energy consumption in a single reading period
Unit: Kilowatts (kW)
Calculation:
```sql
SELECT MAX(consumption_kwh) as peak_demand
FROM consumption_readings
WHERE reading_date >= TRUNC(SYSDATE);
```
Frequency: Daily
Target: Stay below 90% of grid capacity
Owner: Operations Manager
Alert Threshold: > 85% of capacity

#### 5. Average Daily Consumption
Metric ID: KPI-005
Description: Mean energy consumption per day
Unit: kWh per day
Calculation:
```sql
SELECT ROUND(AVG(daily_total), 2) as avg_daily_consumption
FROM (
    SELECT TRUNC(reading_date) as day, SUM(consumption_kwh) as daily_total
    FROM consumption_readings
    WHERE reading_date >= ADD_MONTHS(TRUNC(SYSDATE), -1)
    GROUP BY TRUNC(reading_date)
);
```
### 🔒 Compliance KPIs
#### 6. DML Restriction Compliance Rate
Metric ID: KPI-007
Description: Percentage of DML operations complying with business rules
Unit: Percentage (%)
Calculation:
```sql
SELECT 
    COUNT(CASE WHEN is_restricted = 'N' THEN 1 END) * 100.0 / COUNT(*) as compliance_rate
FROM energy_audit_log
WHERE audit_timestamp >= TRUNC(SYSDATE, 'MM');
```
Frequency: Monthly
Target: > 95% compliance
Owner: Compliance Officer
Policy Reference: Business Rule #6 (Weekday/Holiday restrictions)

#### 7. Audit Trail Completeness
Metric ID: KPI-008
Description: Percentage of DML operations captured in audit log
Unit: Percentage (%)
Calculation: (Audited operations / Total operations) × 100
Frequency: Quarterly
Target: 100% completeness
Owner: Security Manager
Regulatory: Required for ISO 27001 compliance
Frequency: Monthly
Target: > 95% compliance
Owner: Compliance Officer
Policy Reference: Business Rule #6 (Weekday/Holiday restrictions)

#### 8. Audit Trail Completeness
Metric ID: KPI-008
Description: Percentage of DML operations captured in audit log
Unit: Percentage (%)
Calculation: (Audited operations / Total operations) × 100
Frequency: Quarterly
Target: 100% completeness
Owner: Security Manager
Regulatory: Required for ISO 27001 compliance

### 🏢 Building Performance KPIs
#### 10. Building Efficiency Index
Metric ID: KPI-010
Description: Energy consumption normalized by occupancy/usage
Unit: kWh per occupant-day
Calculation: Total Consumption / (Occupants × Operating Days)
Frequency: Quarterly
Target: Improve 5% year-over-year
Owner: Building Manager
Benchmark: LEED certification standards

### 🔄 Process KPIs
#### 11. Data Quality Score
Metric ID: KPI-016
Description: Accuracy and completeness of energy data
Unit: Score (0-100)
Calculation: Weighted average of:

Completeness: 30%

Accuracy: 40%

Timeliness: 30%
Frequency: Monthly
Target: > 95 score
Owner: Data Manager
Impact: Poor data quality affects all other KPIs

### KPI Framework Version: 2.0
### Last Reviewed: December 2025
### Next Review: March 2026