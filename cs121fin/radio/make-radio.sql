-- [Problem 1.3]
DROP TABLE IF EXISTS song_artists;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS contact_emails;
DROP TABLE IF EXISTS ads;
DROP TABLE IF EXISTS company;
DROP TABLE IF EXISTS promos;
DROP TABLE IF EXISTS playlist;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS song;
DROP TABLE IF EXISTS audio_files;

/**
This table specifies the audio_id and general location and info
about the audio_files in our database
**/
CREATE TABLE audio_files (
	audio_id INTEGER NOT NULL,
    path VARCHAR(1024) NOT NULL UNIQUE,
    filename VARCHAR(100) NOT NULL,
    -- the length is a numeric because it is 7 digits long and can store 1/10 of a second acccuracy
    -- (1 decimal point)
    length NUMERIC(7, 1) NOT NULL,
    PRIMARY KEY (audio_id)

);

/**
This table specifies the audio files that have the category as "song",
and gives them their necesary info
**/
CREATE TABLE song (
	audio_id INTEGER NOT NULL REFERENCES audio_files,
    -- integer number of seconds intro
    intro_length INTEGER NOT NULL,
    is_explicit BOOLEAN NOT NULL,
    PRIMARY KEY (audio_id)
);

/**
This table specifies the multiple tags, which can be associated with each song
**/
CREATE TABLE tag (
	audio_id INTEGER NOT NULL REFERENCES song,
    tag_val VARCHAR(30),
    PRIMARY KEY (audio_id, tag_val)
);

/**
 This table represents the master playlist. It has all the start times and ids of each file 
 that is currently queded up to play
**/
CREATE TABLE playlist (
	start_time TIMESTAMP NOT NULL ,
    end_time TIMESTAMP NOT NULL,
    is_request BOOLEAN NOT NULL,
    audio_id INTEGER NOT NULL REFERENCES audio_files,
    PRIMARY KEY (start_time)
);

/**
This table specifies the audio files that have the category as "promo",
and gives them their necesary info
**/
CREATE TABLE promos (
	audio_id INTEGER NOT NULL REFERENCES audio_files,
    promo_type VARCHAR(30) NOT NULL,
    promo_url VARCHAR(1000),
    PRIMARY KEY (audio_id)
    
);

/*
This table represents the comapnies that are in our database that may or may not
have their own ads. It connects the company names to their unique id
*/
CREATE TABLE company (
	company_id INTEGER NOT NULL,
    company_name VARCHAR(100),
    PRIMARY KEY (company_id)
);

/**
This table specifies the audio files that have the category as "ad",
and gives them their necesary info. This table also references
company to see which company owns each ad
**/
CREATE TABLE ads(
	audio_id INTEGER NOT NULL REFERENCES audio_files,
    ad_start TIMESTAMP NOT NULL,
    ad_end TIMESTAMP NOT NULL,
    price NUMERIC(6, 2) NOT NULL,
    company_id INTEGER NOT NULL REFERENCES company,
    PRIMARY KEY (audio_id)
    
);

/**
This table specifies the multiple contact_emails, which can be associated with each company
**/
CREATE TABLE contact_emails(
	company_id INTEGER NOT NULL REFERENCES company,
    contact_email VARCHAR(100) NOT NULL,
    PRIMARY KEY (company_id, contact_email)

);

/*
This table associates each artist name with a unique artist id
*/
CREATE TABLE artist (
	artist_id INTEGER NOT NULL,
    artist_name VARCHAR(100),
    PRIMARY KEY (artist_id)
);

/*
Table to represent which artists write which songs
*/
CREATE TABLE song_artists (
	artist_id INTEGER NOT NULL REFERENCES artist,
    audio_id INTEGER REFERENCES song,
    PRIMARY KEY (artist_id, audio_id)
    

);