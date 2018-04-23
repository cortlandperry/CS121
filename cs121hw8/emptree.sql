-- [Problem 1]
DROP FUNCTION IF EXISTS total_salaries_adjlist;

DELIMITER !
CREATE FUNCTION total_salaries_adjlist(emp_num INTEGER) RETURNS INTEGER
BEGIN
	DECLARE s INTEGER;
	DECLARE rowcount INTEGER;
	-- First, we create a temperary table
    DROP TEMPORARY TABLE IF EXISTS emps;
	CREATE TEMPORARY TABLE emps
		(emp_id INTEGER NOT NULL, salary INTEGER NOT NULL);
        
	-- This will insert our "boss" into the temperary table as our first entry to our table
    INSERT INTO emps VALUES (emp_num, (SELECT salary FROM employee_adjlist WHERE emp_id = emp_num));
    
    -- This repeats through the entire table to detmine the employees below,
    -- and adds them if they have a manager that is inside the set
    -- this stops running when no more tables are added into the set
    REPEAT
		INSERT INTO emps SELECT emp_id, salary FROM employee_adjlist 
			WHERE manager_id IN (SELECT emp_id FROM emps) AND emp_id NOT IN (SELECT emp_id FROM emps);
		SELECT ROW_COUNT() INTO rowcount;
	UNTIL rowcount = 0 END REPEAT;
    
    -- now we compute the total sum, and put it into our variable and return it
    SELECT SUM(salary) FROM emps INTO s;
    RETURN s;
END !

DELIMITER ;


-- [Problem 2]
DROP FUNCTION IF EXISTS total_salaries_nestset;

DELIMITER ! 

CREATE FUNCTION total_salaries_nestset(emp_num INTEGER) RETURNS INTEGER
BEGIN
	-- Declaring the variables
	DECLARE s INTEGER;
    DECLARE low_boss INTEGER;
    DECLARE high_boss INTEGER;
    
    -- Find the bosses "low" and "high" value
    SELECT low FROM employee_nestset WHERE emp_id = emp_num INTO low_boss;
	SELECT high FROM employee_nestset WHERE emp_id = emp_num INTO high_boss;
    
    -- All employees underneath and including the boss have a low/high value in between
    -- the bounds that the boss has, thus we can seach like:
    SELECT SUM(salary) FROM employee_nestset WHERE low >= low_boss AND high <= high_boss INTO s;
    RETURN s;

END !

DELIMITER ;

-- [Problem 3]
-- Left Join the table on itself, which allows us to check whether each employee_id has another
-- employee that has it as its manager. If it doesn't, then it is a leaf, so we just check if e2.man_id IS NULL.
-- this would mean that there is no member of the set that has it as its manager, which means 
-- we do not have any children, making it a leaf
SELECT e1.emp_id, e1.name, e1.salary
	FROM employee_adjlist as e1 LEFT JOIN employee_adjlist as e2 
    ON e1.emp_id = e2.manager_id
	WHERE e2.manager_id IS NULL;
	


-- [Problem 4]
-- select the necesary values, make sure that there are 0 rows that have a low/high value pair in between the low high value pair of the initial
-- statement.
SELECT emp_id, name, salary FROM employee_nestset as e 
WHERE 0 IN (SELECT COUNT(emp_id) FROM employee_nestset WHERE low > e.low AND high < e.high);

-- [Problem 5]
DROP FUNCTION IF EXISTS tree_depth;

DELIMITER !

/**
I choose to use employee_adjlist because each child has a parent, so it is easier
to specify parent child nodes, and their individual depths because there are
clear relations between the employee and the manager. This implementation is
slightly slower, but significantly clearer;
**/
CREATE FUNCTION tree_depth() RETURNS INTEGER
BEGIN
	-- declare variables
	DECLARE boss_id INTEGER;
    DECLARE max_depth INTEGER;
    DECLARE rowcount INTEGER;
    DECLARE i INTEGER DEFAULT 1;
    
    -- create a temperary table to store our values with depths
	DROP TEMPORARY TABLE IF EXISTS em;
    CREATE TEMPORARY TABLE em 
		(emp_id INTEGER NOT NULL, depth INTEGER NOT NULL);
	
    -- take the top of the entire heirachy, find the bosses id
    SELECT emp_id FROM employee_adjlist WHERE manager_id IS NULL INTO boss_id;
    INSERT INTO em VALUES (boss_id, 1); -- boss has depth 1
    
    -- This populates the temperary table with all our values, assigning a correct depth into each node
    -- this is very similar to the example in lecture
    REPEAT
		INSERT INTO em SELECT emp_id, i +1 FROM employee_adjlist
			WHERE manager_id IN (SELECT emp_id FROM em WHERE depth = i);
		SELECT ROW_COUNT() INTO rowcount;
        SET i = i + 1;
	UNTIL rowcount = 0 END REPEAT;
    
    -- we select the maximum depth of all our nodes, which gives us the tree depth
    SELECT MAX(depth) FROM em INTO max_depth;
    RETURN max_depth;
    
    
END !

DELIMITER ;

-- [Problem 6]
DROP FUNCTION IF EXISTS emp_reports;

DELIMITER !

CREATE FUNCTION emp_reports(emp_num INTEGER) RETURNS INTEGER
BEGIN
	DECLARE children_count INTEGER;
    DECLARE employee_depth INTEGER;
    DECLARE employ_low INTEGER;
    DECLARE employ_high INTEGER;
    
    -- create temp table that will alllow us to store the depth values of each employee
    DROP TEMPORARY TABLE IF EXISTS em;
    CREATE TEMPORARY TABLE em (
		emp_id INTEGER NOT NULL,
        depth INTEGER NOT NULL
	);
    
	-- insert into table that has all the employee ids and all the depths of each employee
	INSERT INTO em SELECT child.emp_id, COUNT(parent.emp_id)
		FROM employee_nestset as child, employee_nestset as parent
		WHERE child.low BETWEEN parent.low AND parent.high
		GROUP BY child.emp_id;
	
    -- Insert important values about the boss employee into variables we can use
    -- we find the high, low, and depths of the boss employee
    SELECT depth FROM em WHERE emp_id = emp_num INTO employee_depth;
    SELECT high FROM employee_nestset WHERE emp_id = emp_num INTO employ_high;
    SELECT low FROM employee_nestset WHERE emp_id = emp_num INTO employ_low;
    
    -- select the count of all employees 1 level below our boss that has a low high values 
    -- inside the range of the low high values of our boss. We natural join our initial set on
    -- emp_id to em, esentially giving each thing a depth value so we can compare in this way
    SELECT COUNT(emp_id) FROM em as a NATURAL JOIN employee_nestset as b 
		WHERE depth = employee_depth + 1 AND b.low > employ_low AND b.high < employ_high INTO children_count;
    
    
    -- return the children_count
    RETURN children_count;

END !

DELIMITER ;



