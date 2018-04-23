-- [Problem 3]
DROP TABLE IF EXISTS resource_fact;
DROP TABLE IF EXISTS visitor_fact;
DROP TABLE IF EXISTS datetime_dim;
DROP TABLE IF EXISTS resource_dim;
DROP TABLE IF EXISTS visitor_dim;

-- This is the dimension table for the visitor 
CREATE TABLE visitor_dim (
	visitor_id INTEGER NOT NULL AUTO_INCREMENT,
    ip_addr VARCHAR(100) NOT NULL,
    visit_val INTEGER NOT NULL UNIQUE,
    PRIMARY KEY (visitor_id),
    UNIQUE (visit_val)
);

-- dimension table for our resource values
CREATE TABLE resource_dim (
	resource_id INTEGER NOT NULL AUTO_INCREMENT,
    resource VARCHAR(200) NOT NULL,
    method VARCHAR(15),
    protocol VARCHAR(200),
    response INTEGER NOT NULL,
    PRIMARY KEY(resource_id),
    UNIQUE(resource, method, protocol, response)

);

-- Dimension table for our datetime values
CREATE TABLE datetime_dim (
	date_id INTEGER NOT NULL AUTO_INCREMENT,
    date_val DATE NOT NULL,
    hour_val INTEGER NOT NULL,
    weekend BOOLEAN NOT NULL,
    holiday VARCHAR(20),
    PRIMARY KEY (date_id),
    UNIQUE (date_val, hour_val)

);

-- this is the fact table for our resources, its ID's reference the dim tables
CREATE TABLE resource_fact (
	date_id INTEGER NOT NULL REFERENCES datetime_dim(date_id),
	resource_id INTEGER NOT NULL REFERENCES resource_dim(resource_id),
    num_requests INTEGER NOT NULL,
    total_bytes BIGINT,
    PRIMARY KEY(date_id, resource_id)
    

);

-- This is the visitor fact table, its ID values reference the dim tables
CREATE TABLE visitor_fact (
	date_id INTEGER NOT NULL REFERENCES datetime_dim(date_id),
    visitor_id INTEGER NOT NULL REFERENCES visitor_dim(visitor_id),
    num_requests INTEGER NOT NULL,
    total_bytes BIGINT,
    PRIMARY KEY (date_id, visitor_id)
    

);