-- [Problem 1]
DROP PROCEDURE IF EXISTS sp_deposit;

DELIMITER !

CREATE PROCEDURE sp_deposit (IN account_num VARCHAR(15), IN amount NUMERIC(12,2), OUT status INTEGER)
this_proc:BEGIN
	DECLARE rowcount INTEGER;
	-- if we deposit a negative amount, then we leave the procedure and set our status to negative 1
	IF amount <= 0 THEN
		SET status = -1;
        LEAVE this_proc;
	END IF;
    
	START TRANSACTION;
		-- updates our table to deposit money into our account
		UPDATE account SET balance = balance + amount WHERE account_number = account_num;
        -- this counts the rows that are changed
		SELECT ROW_COUNT() INTO rowcount;
	COMMIT;
    
    IF rowcount = 1 THEN
		-- if there was a row that was changed
		SET status = 1;
	ELSE
		-- this is for invalid account number
		SET status = -2;
	END IF;
    
	
END !

DELIMITER ;


-- [Problem 2]
DROP PROCEDURE IF EXISTS sp_withdraw;

DELIMITER !

CREATE PROCEDURE sp_withdraw (IN account_num VARCHAR(15), IN amount NUMERIC(12,2), OUT status INTEGER)
this_proc: BEGIN
	DECLARE rowcount INTEGER;
    DECLARE bal NUMERIC(12,2);
    SET status = 1;
    -- if we imput a negative amount, we leave the procedure and set our status to -1
    IF amount <= 0 THEN
		SET status = -1;
        LEAVE this_proc;
	END IF;
    
    -- start our transaction
    START TRANSACTION;
		-- update our account by changing balance
		UPDATE account SET balance = balance - amount WHERE account_number = account_num;
        SELECT ROW_COUNT() INTO rowcount;
        -- if no rows were changed, do nothing
        IF rowcount <>  1 THEN
			SET status = -2;
		END IF;
        
        -- check our balance, and if its less than 0 (when it was changed), we rollback our change
        SELECT balance FROM account WHERE account_number = account_num INTO bal;
        IF bal < 0 THEN
			SET status = -3;
            ROLLBACK;
		END IF;
	COMMIT;
    
    
END !

DELIMITER ;


-- [Problem 3]
DROP PROCEDURE IF EXISTS sp_transfer;

DELIMITER ! 

CREATE PROCEDURE sp_transfer(IN account_num_1 VARCHAR(15), IN amount NUMERIC(12,2), IN account_num_2 VARCHAR(15), OUT status INTEGER)
this_proc: BEGIN
	
    -- First, we have to check if account_num_2 is in our account. If it is not, it is possible withdraw will run but deposit will fail
    DECLARE valid INTEGER;
	SELECT balance FROM account WHERE account_number = account_num_2 INTO valid FOR UPDATE;
    IF valid IS NULL THEN
		SET status = -2;
        LEAVE this_proc;
	END IF;
    
    -- call withdraw to withdraw the amount from account_num_1 if it is valid
    CALL sp_withdraw(account_num_1, amount, @output);
    IF @output = 1 THEN
		-- deposit into the new account, we know this account will be valid from above check
		CALL sp_deposit(account_num_2,  amount, @result);
        -- set our status as error or valid result from deposit
        SET status = @result;
    ELSE
		-- set our status as the error from withdraw
		SET status = @output;
	END IF;
    

END !

DELIMITER ;


