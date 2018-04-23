-- [Problem 1a]
DROP TABLE IF EXISTS user_info;

CREATE TABLE user_info (
	username VARCHAR(20) NOT NULL,
    salt CHAR(10) NOT NULL,
    password_hash CHAR(64) NOT NULL,
    PRIMARY KEY (username)
);


-- [Problem 1b]
DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER !
-- This function adds a user into our database storing the passwords
CREATE PROCEDURE sp_add_user(IN new_username VARCHAR(20), IN password VARCHAR(20))
BEGIN
	DECLARE salt CHAR(10);
    DECLARE user_salt VARCHAR(30);
    
	SELECT make_salt(10) INTO salt;	-- create the salt
    SELECT CONCAT(salt, password) INTO user_salt; -- append the salt
    -- adds the necesary values to user_info
    INSERT INTO user_info VALUES(new_username, salt, SHA2(user_salt, 256)); 
    

END!

DELIMITER ;

-- [Problem 1c]
DROP PROCEDURE IF EXISTS sp_change_password;
DELIMITER !

CREATE PROCEDURE sp_change_password(IN username VARCHAR(20), IN new_password VARCHAR(20))
BEGIN
	DECLARE salty CHAR(10);
    DECLARE user_salt VARCHAR(30);
    DECLARE user VARCHAR(20) DEFAULT username;
    
    SELECT make_salt(10) INTO salty;
    SELECT CONCAT(salty, new_password) INTO user_salt;
    
    -- insert values into our database for the appropriate username
    UPDATE user_info SET salt = salty, password_hash = SHA2(user_salt, 256) 
		WHERE user_info.username = user;
    
    

END!

DELIMITER ;

-- [Problem 1d]
DROP FUNCTION IF EXISTS authenticate;

DELIMITER !
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20)) RETURNS BOOL
BEGIN
	DECLARE user VARCHAR(20) DEFAULT username;
    DECLARE user_salt CHAR(10);
    DECLARE hashed_input CHAR(64);
    DECLARE valid_check VARCHAR(20);
    DECLARE actual_hash CHAR(64);
    
    
    
    SELECT salt INTO user_salt FROM user_info WHERE user_info.username = user;
    -- hash value of the password inputted with the given salt
    SELECT SHA2(CONCAT(user_salt, password), 256) INTO hashed_input;
    SELECT user_info.username INTO valid_check FROM user_info WHERE user_info.username = user; 
    SELECT password_hash INTO actual_hash FROM user_info WHERE user_info.username = user;
    
    
    IF valid_check IS NOT NULL AND hashed_input =  actual_hash THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
    
    

END!

DELIMITER ;

