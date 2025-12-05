-- =============================================
-- File: 05_energy_analytics_pkg_spec.sql
-- Energy Analytics Package Specification
-- Advanced analytics, window functions, and reporting
-- =============================================

CREATE OR REPLACE PACKAGE energy_analytics_pkg IS
    
    -- Custom Exceptions
    analytics_calculation_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(analytics_calculation_error, -20201);
    insufficient_data_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(insufficient_data_error, -20202);

    -- PROCEDURE 1: Generate consumption trend report with window functions
    PROCEDURE generate_consumption_trend_report(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_days_back IN NUMBER DEFAULT 30,
        p_report_data OUT SYS_REFCURSOR
    );
    
    -- PROCEDURE 2: Calculate meter efficiency ratings in bulk
    PROCEDURE calculate_efficiency_ratings_bulk(
        p_meter_ids IN SYS.ODCINUMBERLIST DEFAULT NULL,
        p_updated_count OUT NUMBER
    );
    
    -- PROCEDURE 3: Generate comparative analysis report
    PROCEDURE generate_comparative_analysis(
        p_period_type IN VARCHAR2 DEFAULT 'MONTHLY',
        p_analysis_results OUT SYS_REFCURSOR
    );

    -- FUNCTION 1: Get meter efficiency with window functions
    FUNCTION get_meter_efficiency(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN NUMBER;
    
    -- FUNCTION 2: Get consumption trend with LAG/LEAD
    FUNCTION get_consumption_trend(
        p_building_id IN buildings.building_id%TYPE,
        p_days IN NUMBER DEFAULT 7
    ) RETURN VARCHAR2;
    
    -- FUNCTION 3: Rank buildings by consumption using DENSE_RANK
    FUNCTION get_building_consumption_rank(
        p_building_id IN buildings.building_id%TYPE
    ) RETURN NUMBER;
    
    -- FUNCTION 4: Calculate consumption growth rate
    FUNCTION calculate_growth_rate(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_period_days IN NUMBER DEFAULT 30
    ) RETURN NUMBER;

END energy_analytics_pkg;
/