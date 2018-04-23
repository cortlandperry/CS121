-- PLEASE DO NOT INCLUDE date-udfs HERE!!!

-- [Problem 4a]
INSERT INTO resource_dim (resource, method, protocol, response) 
	(SELECT DISTINCT resource, method, protocol, response FROM raw_web_log);
    
    
-- [Problem 4b]
INSERT INTO visitor_dim (ip_addr, visit_val) (SELECT DISTINCT ip_addr, visit_val FROM raw_web_log);

-- [Problem 4c]
DROP PROCEDURE IF EXISTS populate_dates;

DELIMITER !

-- This procedure will generate all date values in our range and insert them into our table
CREATE PROCEDURE populate_dates(d_start DATE, d_end DATE)
BEGIN
	-- Declare variables
	DECLARE d DATE;
    DECLARE h INTEGER;
    
    -- Delete any values that are already in datetime dim at these times.
    DELETE FROM datetime_dim WHERE date_val BETWEEN d_start AND d_end;
    
    SET d = d_start;
    -- loop through the days from d_start to d_end
    WHILE d <= d_end DO
		SET h = 0;
        -- loop through every hour in the day
        WHILE h <= 23 DO
			-- Insert our values of the date, hour, and holiday and weekend values into datetime_dim
			INSERT INTO datetime_dim (date_val, hour_val, weekend, holiday) VALUES (d, h, is_weekend(d), is_holiday(d));
            -- increase the hour by 1
            SET h = h + 1;
		END WHILE;
        -- set the day to the next day
        SET d = d + INTERVAL 1 DAY;
	END WHILE;
    

END !

DELIMITER ;

-- CALL populate_dates('1995-01-01', '1995-12-31');

-- [Problem 5a]
INSERT INTO resource_fact (date_id, resource_id, num_requests, total_bytes) 
	SELECT date_id, resource_id, COUNT(*), SUM(a.bytes_sent) 
	FROM ((raw_web_log as a JOIN resource_dim as b ON  b.resource <=> a.resource AND b.method <=> a.method AND b.protocol <=> a.protocol AND b.response <=> a.response) 
    JOIN datetime_dim as c ON DATE(a.logtime) <=> c.date_val AND HOUR(a.logtime) <=> c.hour_val) 
    GROUP BY date_id, resource_id;
        

-- [Problem 5b]
INSERT INTO visitor_fact(date_id, visitor_id, num_requests, total_bytes)
	SELECT date_id, visitor_id, COUNT(*), SUM(a.bytes_sent)
    FROM ((raw_web_log as a JOIN visitor_dim as b ON a.ip_addr <=> b.ip_addr AND a.visit_val <=> b.visit_val)
    JOIN datetime_dim as c ON DATE(a.logtime) <=> c.date_val AND HOUR(a.logtime) <=> c.hour_val)
    GROUP BY date_id, visitor_id;

