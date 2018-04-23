-- [Problem 5]

-- DROP TABLE commands:
DROP TABLE IF EXISTS tickets_flights;
DROP TABLE IF EXISTS flight_airplane;
DROP TABLE IF EXISTS seat;
DROP TABLE IF EXISTS ticket_traveler;
DROP TABLE IF EXISTS ticket_purchase;
DROP TABLE IF EXISTS purchaser_purchase;
DROP TABLE IF EXISTS phone_numbers;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS airplane;
DROP TABLE IF EXISTS a_customer;


-- CREATE TABLE commands:

/*
	this table 
*/
CREATE TABLE a_customer(
	cust_id INTEGER NOT NULL,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    email VARCHAR(30) NOT NULL UNIQUE,
    PRIMARY KEY (cust_id)
    
);

CREATE TABLE airplane(
	model VARCHAR(30) NOT NULL,
    manufacturer VARCHAR(30) NOT NULL,
    IATA CHAR(3) NOT NULL,
    PRIMARY KEY (IATA)
);

CREATE TABLE flight(
	flight_num INTEGER NOT NULL,
    f_date DATE NOT NULL,
    f_time TIME NOT NULL,
    f_source CHAR(3) NOT NULL,
    destination CHAR(3) NOT NULL, 
    domestic BOOLEAN NOT NULL,
    PRIMARY KEY (flight_num, f_date)

);

CREATE TABLE ticket(
	ticket_id INTEGER NOT NULL,
    sale_price NUMERIC(7, 2) NOT NULL,
    PRIMARY KEY (ticket_id)
);

CREATE TABLE purchase(
	purchase_id INTEGER NOT NULL,
    time_occur TIMESTAMP NOT NULL,
    comf_num INTEGER NOT NULL UNIQUE,
    PRIMARY KEY (purchase_id)
);

CREATE TABLE purchaser(
	cust_id INTEGER NOT NULL,
    credit_card NUMERIC(16,0),
    exp_date CHAR(7),
    VR_code NUMERIC (3,0),
    PRIMARY KEY (cust_id),
    FOREIGN KEY (cust_id) REFERENCES a_customer(cust_id)
);

CREATE TABLE traveler(
	cust_id INTEGER NOT NULL,
    passport_num VARCHAR(40),
    citizenship VARCHAR (30),
    emer_contact VARCHAR(50),
    emer_phone VARCHAR(15),
    flyer_num CHAR(7),
    PRIMARY KEY (cust_id),
    UNIQUE (passport_num, citizenship),
    FOREIGN KEY (cust_id) REFERENCES a_customer(cust_id)
);

CREATE TABLE phone_numbers(
	cust_id INTEGER NOT NULL,
    phone_num VARCHAR(15) NOT NULL,
    PRIMARY KEY (cust_id, phone_num),
	FOREIGN KEY (cust_id) REFERENCES a_customer(cust_id)
);

CREATE TABLE purchaser_purchase(
	purchase_id INTEGER NOT NULL,
    cust_id INTEGER NOT NULL,
    PRIMARY KEY (purchase_id),
	FOREIGN KEY (cust_id) REFERENCES purchaser(cust_id),
	FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id)
);

CREATE TABLE ticket_purchase(
	ticket_id INTEGER NOT NULL,
    purchase_id INTEGER NOT NULL,
    PRIMARY KEY (ticket_id),
	FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id),
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id)
);

CREATE TABLE ticket_traveler(
	ticket_id INTEGER NOT NULL,
    cust_id INTEGER NOT NULL,
    PRIMARY KEY (ticket_id),	
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id),
    FOREIGN KEY (cust_id) REFERENCES traveler(cust_id)
);

CREATE TABLE seat(
	IATA CHAR(3) NOT NULL,
    seat_no VARCHAR(3) NOT NULL,
    class VARCHAR(10) NOT NULL,
    seat_type VARCHAR(10) NOT NULL,
    exit_flag BOOLEAN NOT NULL,
    PRIMARY KEY (IATA, seat_no),
    FOREIGN KEY (IATA) REFERENCES airplane(IATA)
);


CREATE TABLE flight_airplane(
	flight_num INTEGER NOT NULL REFERENCES flight(flight_num),
    f_date DATE NOT NULL REFERENCES flight(f_date),
    IATA CHAR(3) NOT NULL REFERENCES airplane(IATA),
    PRIMARY KEY (flight_num, f_date)
);

CREATE TABLE tickets_flights(
	flight_num INTEGER NOT NULL REFERENCES flight(flight_num),
    f_date DATE NOT NULL REFERENCES flight(f_date),
    seat_no VARCHAR(3) NOT NULL REFERENCES seat(seat_no),
    IATA CHAR(3) NOT NULL REFERENCES seat(IATA),
    ticket_id INTEGER NOT NULL REFERENCES ticket(ticket_id),
    PRIMARY KEY (ticket_id),
    UNIQUE (f_date, seat_no, flight_num, IATA)
)


