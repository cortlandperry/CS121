-- [Problem 9]
DROP TABLE IF EXISTS cards_for_sale;
DROP TABLE IF EXISTS player_cards;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS card_types;

/*
players is a table that holds all of the information about specific players that exist in the game. 
each username and player_id can only be made once, and this is how we track each players movements
*/
CREATE TABLE players(
	player_id INTEGER NOT NULL,
    username VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP() NOT NULL,
    player_stats CHAR(1) DEFAULT 'A' NOT NULL,
    PRIMARY KEY(player_id)
);

/*
This table describes each kind of card that may appear in the game. Each kind of card has a
unique ID, a unique name, a description of the card’s meaning and effects in the game, and an
optional limit on how many of this kind of card are actually available in the game.
*/
CREATE TABLE card_types(
	type_id INTEGER NOT NULL,
    card_name VARCHAR(100) NOT NULL UNIQUE,
    card_desc VARCHAR(1000) NOT NULL,
    card_value NUMERIC(5, 1) NOT NULL,
    total_circulation INTEGER,
    PRIMARY KEY (type_id)
    
);

/*
This table records the details of all cards that are actually “in circulation” among all players of
the game. For every card that each player owns, there will be a tuple in this relation, specifying
the card's type, and the player who owns it. Each individual card also has its own unique ID.
*/
CREATE TABLE player_cards(
	card_id INTEGER NOT NULL,
    type_id INTEGER NOT NULL REFERENCES card_types ,
    player_id INTEGER NOT NULL REFERENCES players,
    PRIMARY KEY (card_id)

);

/*
This table records playing cards that are currently for sale. None of the attributes are allowed
to be null.
*/
CREATE TABLE cards_for_sale (
	player_id INTEGER NOT NULL REFERENCES player_cards,
    card_id INTEGER NOT NULL REFERENCES player_cards,
    offer_date TIMESTAMP DEFAULT  CURRENT_TIMESTAMP() NOT NULL,
    card_price NUMERIC (7, 2),
    PRIMARY KEY (player_id, card_id)
);


