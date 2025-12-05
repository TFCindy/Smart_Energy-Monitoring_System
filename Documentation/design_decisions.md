# Design Decisions

## Database Design
1. **Normalization:** 3NF for data integrity
2. **Sequences:** Auto-increment IDs for all tables
3. **Indexes:** Strategic indexing on foreign keys and search columns
4. **Constraints:** PK, FK, CHECK constraints for data quality

## Business Rule Implementation
1. **Triggers vs Constraints:** Chose triggers for complex logic
2. **Simple vs Compound Triggers:** Both implemented for learning
3. **Holiday Logic:** Upcoming month only per requirements
4. **Error Messages:** Clear, actionable error messages

## Audit System
1. **Autonomous Transactions:** Ensures audit logs even if main transaction fails
2. **Comprehensive Logging:** User, session, machine, operation details
3. **CLOB Storage:** JSON-like storage for old/new values
4. **Performance:** Indexed for quick reporting

## Dashboard Design
1. **Static HTML:** Chose over complex frameworks for simplicity
2. **Chart.js:** Lightweight, responsive charting
3. **Progressive Enhancement:** Works without PHP backend
4. **Mobile-First:** Responsive CSS grid

## Technology Choices
1. **Oracle PL/SQL:** Project requirement, robust for business logic
2. **PHP Optional:** Extra credit, not required for core functionality
3. **Manual Testing:** Comprehensive test suite over unit test framework
4. **Documentation:** Detailed README and technical docs

## Performance Decisions
1. **Bulk Operations:** Compound triggers for efficiency
2. **View Materialization:** Strategic views for reporting
3. **Caching:** Dashboard caches data for 2 minutes
4. **Index Strategy:** Balanced read/write performance

## Security Decisions
1. **Least Privilege:** Minimum grants for each user
2. **Audit Trail:** Non-repudiation through comprehensive logging
3. **Input Validation:** Server-side validation in PL/SQL
4. **Error Handling:** Generic errors to users, detailed to logs