-- [Problem 10]
SELECT type_id, card_name, card_desc, card_value, total_circulation FROM card_types
	WHERE card_value > 10 AND total_circulation IS NULL;


-- [Problem 11]
UPDATE card_types
	SET card_value = card_value + 10
	WHERE type_id IN (SELECT type_id FROM players NATURAL JOIN player_cards
		WHERE username = 'ted_codd');


-- [Problem 12]
DELETE FROM cards_for_sale WHERE player_id IN (SELECT player_id FROM players WHERE username = 'smith');
DELETE FROM player_cards WHERE player_id IN (SELECT player_id FROM players WHERE username = 'smith');
DELETE FROM players WHERE username = 'smith';



-- [Problem 13]
WITH total_values as (SELECT player_id, sum(card_value) as total_val 
	FROM (card_types NATURAL JOIN player_cards) GROUP BY player_id ORDER BY total_val DESC LIMIT 5)
SELECT player_id, username, email, total_val FROM (players NATURAL JOIN total_values);

-- [Problem 14a]
SELECT * FROM (SELECT type_id, card_name, card_desc, card_value, total_circulation, 
	(SELECT count(card_id) as tot FROM player_cards AS a WHERE a.type_id = b.type_id) as total_copies
	FROM card_types AS b) AS c WHERE total_copies > total_circulation;



-- [Problem 14b]
DROP VIEW IF EXISTS overissued_cards;
CREATE VIEW overissued_cards AS
SELECT type_id, card_name, card_desc, card_value, total_circulation, total_copies FROM
	card_types NATURAL JOIN (SELECT type_id, count(card_id) as total_copies FROM player_cards GROUP BY type_id) as tot_vals
    WHERE total_copies > total_circulation;

-- [Problem 15]
WITH grouped AS (SELECT player_id, count(card_id) as rares FROM player_cards NATURAL JOIN (SELECT type_id FROM card_types WHERE total_circulation <= 10) AS a GROUP BY player_id)
		SELECT DISTINCT player_id FROM grouped NATURAL JOIN card_types WHERE rares IN (SELECT count(*) 
		FROM card_types AS c WHERE c.total_circulation <= 10);

-- [Problem 16]
SELECT DISTINCT type_id, card_name, card_desc 
	FROM (player_cards NATURAL JOIN card_types) WHERE player_id IN (SELECT player_id FROM players 
	WHERE register_date BETWEEN CURRENT_TIMESTAMP() - INTERVAL 10080 MINUTE AND CURRENT_TIMESTAMP());

-- [Problem 17]


	

-- creating a table with all the values we need, specifically the percentage of cards each person sells 
-- then will update the percentage values and change them to something more meaningful
DROP TABLE IF EXISTS percent_vales;
CREATE TABLE percent_values AS (SELECT username, email, percentage FROM 
	(SELECT a.player_id, sells/owns as percentage 
		FROM (SELECT player_id, count(card_id) as owns FROM player_cards GROUP BY player_id) AS a 
        LEFT OUTER JOIN 
		(SELECT player_id, count(card_id) as sells FROM cards_for_sale GROUP BY player_id)
        AS b ON a.player_id = b.player_id) AS play_percent NATURAL JOIN players);
        
-- add our colomn for user_types
ALTER TABLE percent_values
	ADD COLUMN user_types CHAR(6) NOT NULL DEFAULT 'player';
-- if our person is a seller, we need to update their type value    
UPDATE percent_values SET user_types = 'seller' WHERE percentage > .3;

DROP VIEW IF EXISTS user_types;
CREATE VIEW user_types AS
	SELECT username, email, user_types  FROM percent_values;

        



