-- [Problem 1a]
SELECT SUM(perfectscore)
	FROM assignment;

-- [Problem 1b]
SELECT sec_name, COUNT(username) as num_students
	FROM section NATURAL JOIN student
    GROUP BY sec_name;


-- [Problem 1c]
DROP VIEW IF EXISTS totalscores;
CREATE VIEW totalscores AS
	SELECT username, SUM(score) as total_score
    FROM student NATURAL JOIN submission
    WHERE graded
    GROUP BY username;
    
-- [Problem 1d]
DROP VIEW IF EXISTS passing;

CREATE VIEW passing AS
	SELECT username
    FROM student NATURAL JOIN submission
    WHERE graded
    GROUP BY username
    HAVING SUM(score) >= 40;

SELECT * FROM passing;

-- [Problem 1e]
DROP VIEW IF EXISTS failing;

CREATE VIEW failing AS
	SELECT username
    FROM student NATURAL JOIN submission
    WHERE graded
    GROUP BY username
    HAVING SUM(score) < 40;

SELECT * FROM failing;


-- [Problem 1f]
SELECT username
	FROM submission NATURAL LEFT OUTER JOIN fileset
    WHERE fset_id IS NULL AND 
    asn_id IN (SELECT asn_id FROM assignment WHERE shortname LIKE 'lab%') 
    AND username IN (SELECT * FROM passing);


-- [Problem 1g]
SELECT username
	FROM submission NATURAL LEFT OUTER JOIN fileset
    WHERE fset_id IS NULL AND
    asn_id IN (SELECT asn_id FROM assignment WHERE shortname LIKE 'midterm' OR shortname LIKE 'final')
    AND username IN (SELECT * FROM passing);

-- [Problem 2a]
SELECT username
	FROM fileset NATURAL LEFT JOIN assignment NATURAL JOIN submission
    WHERE due > sub_date AND asn_id IN (SELECT asn_id FROM assignment WHERE shortname LIKE 'midterm');
    

-- [Problem 2b]
SELECT EXTRACT(HOUR FROM sub_date) as hour, COUNT(sub_id) as num_submits
	FROM fileset
    GROUP BY hour;

-- [Problem 2c]

SELECT COUNT(fset_id) AS num_submit
	FROM fileset NATURAL JOIN assignment NATURAL JOIN submission
    WHERE sub_date BETWEEN due - INTERVAL 30 MINUTE AND due AND shortname LIKE 'final'; 


-- [Problem 3a]
ALTER TABLE student
	ADD COLUMN email VARCHAR(200);
UPDATE student SET email = username || '@school.edu';
ALTER TABLE student
	MODIFY email VARCHAR(200) NOT NULL; 

-- [Problem 3b]
ALTER TABLE assignment
	ADD COLUMN submit_files BOOLEAN DEFAULT TRUE;
    
UPDATE assignment 
	SET submit_files = FALSE WHERE shortname LIKE 'dq%';

-- [Problem 3c]
DROP TABLE IF EXISTS gradescheme;


CREATE TABLE gradescheme (
	scheme_id INTEGER,
    scheme_desc VARCHAR(100) NOT NULL,
    PRIMARY KEY(scheme_id)
);

INSERT INTO gradescheme VALUES
(0, 'Lab assignment with min-grading'),
(1, 'Daily quiz'),
(2, 'Midterm or final exam');

ALTER TABLE assignment
	CHANGE gradescheme scheme_id INTEGER NOT NULL;
    
ALTER TABLE assignment
	ADD CONSTRAINT for_key 
    FOREIGN KEY (scheme_id) REFERENCES gradescheme(scheme_id);


-- [Problem 4a]
-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.
DELIMITER !
-- Given a date value, returns TRUE if it is a weekend,
-- or FALSE if it is a weekday.
CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN
BEGIN
          DECLARE weekend BOOLEAN DEFAULT FALSE;
          
          -- this is the if statement determining whether the given day is a weekend or not
          IF DAYOFWEEK(d) = 1 OR DAYOFWEEK(d) = 7 THEN SET weekend = TRUE;
          END IF;
          
          RETURN weekend;
		
END !

-- Back to the standard SQL delimiter
DELIMITER ;

-- [Problem 4b]

DELIMITER !
-- Given a date value, returns the name of the holiday if it happens to be a
-- holliday, and returns NULL if it is not a holiday
CREATE FUNCTION is_holiday(d DATE) RETURNS VARCHAR(20)
BEGIN
	DECLARE holiday VARCHAR(20) DEFAULT NULL;
    
    -- determine if the day is New Year's Day
    IF DATE(d) LIKE '%-01-01' THEN SET holiday = 'New Year\'s Day';
		-- determine if the day is Independence Day
	ELSEIF DATE(d) LIKE '%-07-04' THEN SET holiday = 'Independence Day';
		-- determine if day is Labor Day using a similar method to the hint
	ELSEIF DAYOFMONTH(d) BETWEEN 1 AND 7 
		AND MONTHNAME(d) = 'September' 
        AND DAYOFWEEK(d) = 2 THEN SET holiday = 'Labor Day';
		-- determine if day is Memorial Day like above
	ELSEIF DAYOFMONTH(d) BETWEEN 25 AND 31 
		AND MONTHNAME(d) = 'May' 
        AND DAYOFWEEK(d) = 2 THEN SET holiday = 'Memorial Day';
		-- determiine if day is Thanksgiving like above
	ELSEIF DAYOFMONTH(d) BETWEEN 22 AND 28 
		AND MONTHNAME(d) = 'November' 
        AND DAYOFWEEK(d) = 5 THEN SET holiday = 'Thanksgiving';
    END IF;


	RETURN holiday;
END !

DELIMITER ;

-- [Problem 5a]
SELECT is_holiday(DATE(sub_date)) AS holiday, COUNT(fset_id) AS file_quanitity
	FROM fileset 
    GROUP BY is_holiday(DATE(sub_date));

-- [Problem 5b]

SELECT 
CASE is_weekend(DATE(sub_date))
	WHEN TRUE THEN 'weekend'
    WHEN FALSE THEN 'weekday' END AS is_weekend, COUNT(*) AS file_quantity FROM fileset GROUP BY is_weekend;

