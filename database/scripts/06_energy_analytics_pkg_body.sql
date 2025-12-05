-- =============================================
-- File: 06_energy_analytics_pkg_body.sql (FINAL CORRECTION)
-- Energy Analytics Package Body
-- Implementation of advanced analytics and window functions
-- =============================================

CREATE OR REPLACE PACKAGE BODY energy_analytics_pkg IS

    -- PROCEDURE 1: Generate consumption trend report
    PROCEDURE generate_consumption_trend_report(
        p_building_id IN buildings.building_id%TYPE DEFAULT NULL,
        p_days_back IN NUMBER DEFAULT 30,
        p_report_data OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_report_data FOR
        WITH consumption_data AS (
            SELECT 
                b.building_id,
                b.building_name,
                TRUNC(r.reading_date) as reading_day,
                SUM(r.consumption_kwh) as daily_consumption,
                -- Window functions for trend analysis
                AVG(SUM(r.consumption_kwh)) OVER (
                    PARTITION BY b.building_id 
                    ORDER BY TRUNC(r.reading_date)
                    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
                ) as weekly_moving_avg,
                LAG(SUM(r.consumption_kwh), 1) OVER (
                    PARTITION BY b.building_id 
                    ORDER BY TRUNC(r.reading_date)
                ) as prev_day_consumption,
                RANK() OVER (
                    PARTITION BY TRUNC(r.reading_date)
                    ORDER BY SUM(r.consumption_kwh) DESC
                ) as daily_rank,
                DENSE_RANK() OVER (
                    PARTITION BY b.building_id
                    ORDER BY TRUNC(r.reading_date)
                ) as day_sequence
            FROM buildings b
            JOIN energy_meters m ON b.building_id = m.building_id
            JOIN consumption_readings r ON m.meter_id = r.meter_id
            WHERE r.reading_date >= SYSDATE - p_days_back
            AND (p_building_id IS NULL OR b.building_id = p_building_id)
            GROUP BY b.building_id, b.building_name, TRUNC(r.reading_date)
        )
        SELECT 
            building_id,
            building_name,
            reading_day,
            daily_consumption,
            weekly_moving_avg,
            prev_day_consumption,
            daily_rank,
            day_sequence,
            CASE 
                WHEN prev_day_consumption IS NOT NULL THEN
                    ROUND(((daily_consumption - prev_day_consumption) / prev_day_consumption) * 100, 2)
                ELSE NULL
            END as daily_change_percent,
            CASE 
                WHEN daily_consumption > weekly_moving_avg * 1.2 THEN 'ABOVE_AVERAGE'
                WHEN daily_consumption < weekly_moving_avg * 0.8 THEN 'BELOW_AVERAGE'
                ELSE 'NORMAL'
            END as consumption_pattern
        FROM consumption_data
        ORDER BY building_name, reading_day DESC;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE analytics_calculation_error;
    END generate_consumption_trend_report;

    -- PROCEDURE 2: Calculate efficiency ratings in bulk (FIXED)
    PROCEDURE calculate_efficiency_ratings_bulk(
        p_meter_ids IN SYS.ODCINUMBERLIST DEFAULT NULL,
        p_updated_count OUT NUMBER
    ) IS
        CURSOR meter_cur IS
            SELECT meter_id
            FROM energy_meters
            WHERE is_active = 'Y'
            AND (p_meter_ids IS NULL OR meter_id IN (
                SELECT column_value FROM TABLE(p_meter_ids)
            ));
    BEGIN
        p_updated_count := 0;
        
        FOR meter_rec IN meter_cur LOOP
            BEGIN
                DECLARE
                    v_efficiency NUMBER;
                BEGIN
                    v_efficiency := get_meter_efficiency(meter_rec.meter_id);
                    p_updated_count := p_updated_count + 1;
                    
                    -- Output progress for every 5 meters
                    IF MOD(p_updated_count, 5) = 0 THEN
                        DBMS_OUTPUT.PUT_LINE('Processed ' || p_updated_count || ' meters...');
                    END IF;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL; -- Continue with next meter
                END;
            END;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Completed efficiency ratings for ' || p_updated_count || ' meters');
        
    EXCEPTION
        WHEN OTHERS THEN
            p_updated_count := 0;
            RAISE;
    END calculate_efficiency_ratings_bulk;

    -- PROCEDURE 3: Generate comparative analysis
    PROCEDURE generate_comparative_analysis(
        p_period_type IN VARCHAR2 DEFAULT 'MONTHLY',
        p_analysis_results OUT SYS_REFCURSOR
    ) IS
        v_date_format VARCHAR2(20);
    BEGIN
        CASE p_period_type
            WHEN 'DAILY' THEN v_date_format := 'YYYY-MM-DD';
            WHEN 'WEEKLY' THEN v_date_format := 'IYYY-IW';
            WHEN 'MONTHLY' THEN v_date_format := 'YYYY-MM';
            ELSE v_date_format := 'YYYY-MM';
        END CASE;
        
        OPEN p_analysis_results FOR
        WITH period_data AS (
            SELECT 
                b.building_id,
                b.building_name,
                b.building_type,
                TO_CHAR(r.reading_date, v_date_format) as period,
                SUM(r.consumption_kwh) as period_consumption,
                COUNT(*) as reading_count,
                -- Window functions for comparison
                AVG(SUM(r.consumption_kwh)) OVER (
                    PARTITION BY b.building_type
                ) as avg_by_type,
                RANK() OVER (
                    PARTITION BY TO_CHAR(r.reading_date, v_date_format)
                    ORDER BY SUM(r.consumption_kwh) DESC
                ) as consumption_rank,
                LAG(SUM(r.consumption_kwh), 1) OVER (
                    PARTITION BY b.building_id
                    ORDER BY TO_CHAR(r.reading_date, v_date_format)
                ) as prev_period_consumption,
                LEAD(SUM(r.consumption_kwh), 1) OVER (
                    PARTITION BY b.building_id
                    ORDER BY TO_CHAR(r.reading_date, v_date_format)
                ) as next_period_consumption
            FROM buildings b
            JOIN energy_meters m ON b.building_id = m.building_id
            JOIN consumption_readings r ON m.meter_id = r.meter_id
            WHERE r.reading_date >= ADD_MONTHS(SYSDATE, -12)
            GROUP BY b.building_id, b.building_name, b.building_type, 
                     TO_CHAR(r.reading_date, v_date_format)
        )
        SELECT 
            building_id,
            building_name,
            building_type,
            period,
            period_consumption,
            reading_count,
            avg_by_type,
            consumption_rank,
            prev_period_consumption,
            next_period_consumption,
            ROUND((period_consumption - avg_by_type) / avg_by_type * 100, 2) as variance_from_avg_pct,
            CASE 
                WHEN prev_period_consumption IS NOT NULL THEN
                    ROUND((period_consumption - prev_period_consumption) / prev_period_consumption * 100, 2)
                ELSE NULL
            END as growth_rate_pct
        FROM period_data
        ORDER BY period DESC, consumption_rank;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE analytics_calculation_error;
    END generate_comparative_analysis;

    -- FUNCTION 1: Get meter efficiency with window functions (FIXED)
    FUNCTION get_meter_efficiency(
        p_meter_id IN energy_meters.meter_id%TYPE
    ) RETURN NUMBER IS
        v_efficiency_rating NUMBER;
        v_stability_score NUMBER;
        v_consistency_score NUMBER;
        v_quality_score NUMBER;
    BEGIN
        -- Calculate stability score
        BEGIN
            SELECT 
                100 - (STDDEV(consumption_kwh) / NULLIF(AVG(consumption_kwh), 0) * 50)
            INTO v_stability_score
            FROM consumption_readings
            WHERE meter_id = p_meter_id
            AND reading_date >= SYSDATE - 30;
        EXCEPTION
            WHEN OTHERS THEN
                v_stability_score := 25;
        END;
        
        -- Calculate consistency score (FIXED - removed weekly_avg reference)
        BEGIN
            SELECT 
                COUNT(CASE 
                    WHEN ABS(consumption_kwh - avg_consumption) / NULLIF(avg_consumption, 0) < 0.15 
                    THEN 1 
                END) / NULLIF(COUNT(*), 0) * 100
            INTO v_consistency_score
            FROM (
                SELECT 
                    consumption_kwh,
                    AVG(consumption_kwh) OVER () as avg_consumption
                FROM consumption_readings
                WHERE meter_id = p_meter_id
                AND reading_date >= SYSDATE - 30
            );
        EXCEPTION
            WHEN OTHERS THEN
                v_consistency_score := 25;
        END;
        
        -- Calculate quality score
        BEGIN
            SELECT 
                COUNT(CASE WHEN reading_quality = 'G' THEN 1 END) / NULLIF(COUNT(*), 0) * 100
            INTO v_quality_score
            FROM consumption_readings
            WHERE meter_id = p_meter_id
            AND reading_date >= SYSDATE - 30;
        EXCEPTION
            WHEN OTHERS THEN
                v_quality_score := 25;
        END;
        
        -- Calculate final efficiency rating
        v_efficiency_rating := (NVL(v_stability_score, 25) * 0.4 + 
                               NVL(v_consistency_score, 25) * 0.4 + 
                               NVL(v_quality_score, 25) * 0.2);
        
        -- Ensure rating is between 0 and 100
        IF v_efficiency_rating < 0 THEN
            v_efficiency_rating := 0;
        ELSIF v_efficiency_rating > 100 THEN
            v_efficiency_rating := 100;
        END IF;
        
        RETURN v_efficiency_rating;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 50; -- Default average rating
    END get_meter_efficiency;

    -- FUNCTION 2: Get consumption trend with LAG/LEAD
    FUNCTION get_consumption_trend(
        p_building_id IN buildings.building_id%TYPE,
        p_days IN NUMBER DEFAULT 7
    ) RETURN VARCHAR2 IS
        v_current_avg NUMBER;
        v_previous_avg NUMBER;
        v_trend_percent NUMBER;
    BEGIN
        -- Current period average (last p_days/2 days)
        SELECT AVG(r.consumption_kwh)
        INTO v_current_avg
        FROM consumption_readings r
        JOIN energy_meters m ON r.meter_id = m.meter_id
        WHERE m.building_id = p_building_id
        AND r.reading_date BETWEEN SYSDATE - (p_days/2) AND SYSDATE;
        
        -- Previous period average (p_days/2 days before that)
        SELECT AVG(r.consumption_kwh)
        INTO v_previous_avg
        FROM consumption_readings r
        JOIN energy_meters m ON r.meter_id = m.meter_id
        WHERE m.building_id = p_building_id
        AND r.reading_date BETWEEN SYSDATE - p_days AND SYSDATE - (p_days/2);
        
        IF v_previous_avg IS NULL OR v_previous_avg = 0 THEN
            RETURN 'INSUFFICIENT_DATA';
        END IF;
        
        v_trend_percent := ((v_current_avg - v_previous_avg) / v_previous_avg) * 100;
        
        IF v_trend_percent > 15 THEN
            RETURN 'STRONG_INCREASE';
        ELSIF v_trend_percent > 5 THEN
            RETURN 'MODERATE_INCREASE';
        ELSIF v_trend_percent < -15 THEN
            RETURN 'STRONG_DECREASE';
        ELSIF v_trend_percent < -5 THEN
            RETURN 'MODERATE_DECREASE';
        ELSE
            RETURN 'STABLE';
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NO_DATA';
        WHEN OTHERS THEN
            RETURN 'ERROR';
    END get_consumption_trend;

    -- FUNCTION 3: Rank buildings by consumption
    FUNCTION get_building_consumption_rank(
        p_building_id IN buildings.building_id%TYPE
    ) RETURN NUMBER IS
        v_rank NUMBER;
    BEGIN
        WITH building_ranks AS (
            SELECT 
                b.building_id,
                SUM(r.consumption_kwh) as total_consumption,
                -- Using DENSE_RANK to handle ties properly
                DENSE_RANK() OVER (ORDER BY SUM(r.consumption_kwh) DESC) as consumption_rank
            FROM buildings b
            JOIN energy_meters m ON b.building_id = m.building_id
            JOIN consumption_readings r ON m.meter_id = r.meter_id
            WHERE r.reading_date >= SYSDATE - 30
            GROUP BY b.building_id
        )
        SELECT consumption_rank
        INTO v_rank
        FROM building_ranks
        WHERE building_id = p_building_id;
        
        RETURN v_rank;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN -1;
    END get_building_consumption_rank;

    -- FUNCTION 4: Calculate consumption growth rate
    FUNCTION calculate_growth_rate(
        p_meter_id IN energy_meters.meter_id%TYPE,
        p_period_days IN NUMBER DEFAULT 30
    ) RETURN NUMBER IS
        v_current_period_avg NUMBER;
        v_previous_period_avg NUMBER;
    BEGIN
        -- Current period average
        BEGIN
            SELECT AVG(consumption_kwh)
            INTO v_current_period_avg
            FROM consumption_readings
            WHERE meter_id = p_meter_id
            AND reading_date BETWEEN SYSDATE - (p_period_days/2) AND SYSDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_current_period_avg := 0;
        END;
        
        -- Previous period average
        BEGIN
            SELECT AVG(consumption_kwh)
            INTO v_previous_period_avg
            FROM consumption_readings
            WHERE meter_id = p_meter_id
            AND reading_date BETWEEN SYSDATE - p_period_days AND SYSDATE - (p_period_days/2);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_previous_period_avg := 0;
        END;
        
        IF v_previous_period_avg IS NULL OR v_previous_period_avg = 0 THEN
            RETURN 0;
        END IF;
        
        RETURN ((v_current_period_avg - v_previous_period_avg) / v_previous_period_avg) * 100;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END calculate_growth_rate;

END energy_analytics_pkg;
/