-- [Problem 1]
DROP FUNCTION IF EXISTS min_submit_interval;
DELIMITER !
CREATE FUNCTION min_submit_interval(s INTEGER) RETURNS INTEGER
BEGIN
	-- Declaring Initial Variables, set min_interval to largest possible timestamp
	DECLARE min_interval INTEGER DEFAULT UNIX_TIMESTAMP(CURRENT_TIMESTAMP);
    DECLARE start_point TIMESTAMP;
    DECLARE end_point TIMESTAMP;
    DECLARE first_int BOOLEAN DEFAULT TRUE;
    DECLARE done BOOLEAN DEFAULT FALSE;
    -- Declaring Cursor and Continue Handler for when it finishes
	DECLARE cur CURSOR FOR (SELECT sub_date FROM (fileset) WHERE sub_id = s ORDER BY sub_date ASC);
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' 
		SET done = TRUE;
    OPEN cur;
    
    
    -- get first value in list
    FETCH cur INTO start_point;
    WHILE NOT done DO
		-- get the next value in list
		FETCH cur INTO end_point;
        IF NOT done THEN
            -- otherwise, check if this new interval is smaller than the previous smallest one
			IF (UNIX_TIMESTAMP(end_point) - UNIX_TIMESTAMP(start_point)) < min_interval THEN
				SET min_interval = UNIX_TIMESTAMP(end_point) - UNIX_TIMESTAMP(start_point);
			END IF;
            SET start_point = end_point;
		END IF;
        
	END WHILE;
    RETURN min_interval;
        
			
END !

DELIMITER ;

-- [Problem 2]
DROP FUNCTION IF EXISTS max_submit_interval;
DELIMITER !
CREATE FUNCTION max_submit_interval(s INTEGER) RETURNS INTEGER
BEGIN
	-- Declaring Initial Variables, set min_interval to smallest possible
	DECLARE max_interval INTEGER DEFAULT 0;
    DECLARE start_point TIMESTAMP;
    DECLARE end_point TIMESTAMP;
    DECLARE first_int BOOLEAN DEFAULT TRUE;
    DECLARE done BOOLEAN DEFAULT FALSE;
    -- Declaring Cursor and Continue Handler for when it finishes
	DECLARE cur CURSOR FOR (SELECT sub_date FROM (fileset) WHERE sub_id = s ORDER BY sub_date ASC);
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' 
		SET done = TRUE;
    OPEN cur;
    
    
    -- get first value in list
    FETCH cur INTO start_point;
    WHILE NOT done DO
		-- get the next value in list
		FETCH cur INTO end_point;
        IF NOT done THEN
            -- otherwise, check if this new interval is larger than the previous smallest one
			IF (UNIX_TIMESTAMP(end_point) - UNIX_TIMESTAMP(start_point)) > max_interval THEN
				SET max_interval = UNIX_TIMESTAMP(end_point) - UNIX_TIMESTAMP(start_point);
			END IF;
            SET start_point = end_point;
		END IF;
        
	END WHILE;
    RETURN max_interval;
        
			
END !

DELIMITER ;

-- [Problem 3]
DROP FUNCTION IF EXISTS avg_submit_interval;
DELIMITER !
CREATE FUNCTION avg_submit_interval(s INTEGER) RETURNS DOUBLE
BEGIN
	DECLARE avg_val DOUBLE DEFAULT 0;
    DECLARE total_dates INTEGER;
    DECLARE sum_time INTEGER;
    SELECT (UNIX_TIMESTAMP(MAX(sub_date)) - UNIX_TIMESTAMP(MIN(sub_date))), (COUNT(sub_date) - 1) 
		INTO sum_time, total_dates
        FROM fileset WHERE sub_id = s;
	SET avg_val = sum_time / total_dates;
    RETURN avg_val;
    
END !
	
    
DELIMITER ;


-- [Problem 4]
-- DROP INDEX idx_sub_id ON fileset;
CREATE INDEX idx_sub_id ON fileset(sub_id);

/*

SELECT sub_id,
             min_submit_interval(sub_id) AS min_interval,
             max_submit_interval(sub_id) AS max_interval,
             avg_submit_interval(sub_id) AS avg_interval
      FROM (SELECT sub_id FROM fileset
            GROUP BY sub_id HAVING COUNT(*) > 1) AS multi_subs
      ORDER BY min_interval, max_interval;
      
EXPLAIN (SELECT MIN(UNIX_TIMESTAMP(sub_date)) FROM fileset WHERE sub_id = 5344);
EXPLAIN (SELECT UNIX_TIMESTAMP(MIN(sub_date)) FROM fileset WHERE sub_id = 5344);
*/