,-- [Problem 1]
CREATE INDEX idx_balance ON account(branch_name);


-- [Problem 2]
DROP TABLE IF EXISTS mv_branch_account_stats;
CREATE TABLE mv_branch_account_stats (
	branch_name VARCHAR(15) NOT NULL,
    num_accounts INTEGER,
    total_deposits NUMERIC(12, 2),
    min_balance NUMERIC(12, 2),
    max_balance NUMERIC(12, 2),
    PRIMARY KEY (branch_name)

);

-- [Problem 3]
INSERT INTO mv_branch_account_stats 
	(SELECT branch_name,
               COUNT(*) AS num_accounts,
               SUM(balance) AS total_deposits,
               MIN(balance) AS min_balance,
               MAX(balance) AS max_balance
        FROM account GROUP BY branch_name);

-- [Problem 4]
DROP VIEW IF EXISTS branch_account_stats;
CREATE VIEW branch_account_stats AS
	(SELECT branch_name, num_accounts, total_deposits,
		(total_deposits / num_accounts) AS avg_balance,
		min_balance, max_balance
		FROM mv_branch_account_stats);
    
-- [Problem 5]
DROP PROCEDURE IF EXISTS on_insert;
DELIMITER !
CREATE PROCEDURE on_insert(IN b VARCHAR(15), IN bal NUMERIC(12, 2))
BEGIN
	-- Creating a procdure to update our matrerilized table
    -- This here will insert the correct values into mv_branch when we update account
	INSERT INTO mv_branch_account_stats VALUES (b, 1, bal, bal, bal)
		ON DUPLICATE KEY UPDATE num_accounts = num_accounts + 1,
			total_deposits = total_deposits + bal, min_balance = LEAST(min_balance, bal),
            max_balance = GREATEST(max_balance, bal);

END ! 

DELIMITER ;


DROP TRIGGER IF EXISTS trg_insert;
DELIMITER ! 
CREATE TRIGGER trg_insert AFTER INSERT ON account FOR EACH ROW
BEGIN
	-- whenever the trigger is activated when we insert on account, we call our function to update 
    -- our table
	CALL on_insert(NEW.branch_name, NEW.balance);

END !

DELIMITER ;


-- [Problem 6]
DROP PROCEDURE IF EXISTS on_delete;
DELIMITER !
CREATE PROCEDURE on_delete(IN b VARCHAR(15), IN bal NUMERIC (12, 2))
BEGIN
	DECLARE acc_hold INTEGER;
    DECLARE max_bal NUMERIC(12, 2);
    DECLARE min_bal NUMERIC (12, 2);
    
    -- Store out vaues after the delete into our variables
    SELECT COUNT(branch_name) INTO acc_hold FROM account WHERE branch_name = b;
    SELECT MAX(balance) INTO max_bal FROM account WHERE branch_name = b;
	SELECT MIN(balance) INTO min_bal FROM account WHERE branch_name = b;
    -- min and max are just what the min and max values are in account after we deleted something

    -- updating the values in mv_branch_account_stats
    IF acc_hold = 0 THEN
		DELETE FROM mv_branch_account_stats WHERE branch_name = b;    
    ELSE
		UPDATE mv_branch_account_stats SET num_accounts = num_accounts - 1, 
			total_deposits = total_deposits - bal, min_balance = min_bal, max_balance = max_bal WHERE branch_name = b;
    END IF;
    
    
END !
DELIMITER ;

-- This is just calling our procedure whenever we are triggered
DROP TRIGGER IF EXISTS trg_delete;
DELIMITER !
CREATE TRIGGER trg_delete AFTER DELETE ON account FOR EACH ROW
BEGIN
	CALL on_delete(OLD.branch_name, OLD.balance);
END !
DELIMITER ;


-- [Problem 7]
DROP TRIGGER IF EXISTS trg_update;
DELIMITER !
CREATE TRIGGER trg_update AFTER UPDATE ON account FOR EACH ROW
BEGIN
	DECLARE max_bal NUMERIC(12, 2);
    DECLARE min_bal NUMERIC (12, 2);
    SELECT MAX(balance), MIN(balance) INTO max_bal, min_bal
		FROM account WHERE branch_name = NEW.branch_name;
    
	IF OLD.branch_name = NEW.branch_name THEN
		UPDATE mv_branch_account_stats SET 
			total_deposits = total_deposts - OLD.balance + NEW.balance, 
            max_balance = max_bal, min_balance = min_bal;
	ELSE
		CALL on_delete(OLD.branch_name, OLD.balance);
		CALL on_insert(NEW.branch_name, NEW.balance);
    END IF;
END !
DELIMITER ;



