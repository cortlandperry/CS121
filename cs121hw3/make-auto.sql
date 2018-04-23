-- [Problem 1]

DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS accident;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS participated;

CREATE TABLE person (
	driver_id CHAR(10) NOT NULL,
    name VARCHAR(15) NOT NULL,
    address VARCHAR (100) NOT NULL,
    PRIMARY KEY (driver_id)
);

CREATE TABLE car (
	lisence CHAR(7) NOT NULL,
    model VARCHAR(48),
    year YEAR,
    PRIMARY KEY(lisence)

);

CREATE TABLE accident (
	report_number INTEGER AUTO_INCREMENT NOT NULL,
    date_occured DATETIME NOT NULL,
    location VARCHAR (500) NOT NULL,
    description VARCHAR (5000),
    PRIMARY KEY(report_number)
);

CREATE TABLE owns (
	driver_id CHAR(10) NOT NULL,
    lisence CHAR(7) NOT NULL,
    PRIMARY KEY(driver_id, lisence),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) 
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (lisence) REFERENCES car(lisence) 
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE participated (
	driver_id CHAR(10) NOT NULL,
    lisence CHAR(7) NOT NULL,
	report_number INTEGER AUTO_INCREMENT NOT NULL,
    damage_amount NUMERIC(12, 2),
    PRIMARY KEY(driver_id, lisence, report_number),
	FOREIGN KEY (driver_id) REFERENCES person(driver_id)
    ON UPDATE CASCADE,
    FOREIGN KEY (lisence) REFERENCES car(lisence)
    ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
    ON UPDATE CASCADE
);



