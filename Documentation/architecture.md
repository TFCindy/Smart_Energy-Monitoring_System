# System Architecture

## Overview
Three-tier architecture: Database → Application Logic → Presentation Layer

## Database Tier
- **Oracle Database 19c**
- **Schema:** ENERGY_ADMIN
- **Tables:** 7 core tables + 2 audit tables
- **PL/SQL:** Packages, functions, triggers
- **Indexes:** Performance optimization
- **Security:** Role-based access, audit trails

## Application Tier
- **PL/SQL Business Logic:** Stored procedures, functions, triggers
- **Audit Framework:** Comprehensive logging system
- **Restriction Engine:** Weekday/holiday DML blocking
- **Validation:** Data integrity and business rules

## Presentation Tier
- **HTML Dashboard:** Static dashboard with Chart.js
- **PHP API (Optional):** REST endpoints for live data
- **Responsive Design:** Mobile-first CSS grid
- **Interactive:** JavaScript data fetching

## Data Flow
1. **Data Capture:** Meters → Readings → Database
2. **Business Rules:** Triggers enforce DML restrictions
3. **Audit Logging:** All operations recorded
4. **Dashboard:** Real-time visualization
5. **Alerts:** Threshold violations trigger notifications

## Security Architecture
- **Database:** Users, roles, grants
- **Application:** Input validation, SQL injection prevention
- **Audit:** Complete trail with user context
- **Network:** Firewall rules, encrypted connections

## Deployment
- **Database Server:** Oracle on-premise/cloud
- **Web Server:** Apache/PHP (optional)
- **Client:** Any modern browser
- **Backup:** Daily exports, point-in-time recovery