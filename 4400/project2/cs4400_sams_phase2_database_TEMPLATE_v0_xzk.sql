-- CS4400: Introduction to Database Systems: Monday, September 11, 2023
-- Simple Airline Management System Course Project Database TEMPLATE (v0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;

-- Please enter your team number and names here

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */
DROP TABLE IF EXISTS person;
CREATE TABLE person (
	personId char(20) NOT NULL,
    fname char(20) NOT NULL,
    lname char(20) NOT NULL,
    occupies char(20) NOT NULL,
    PRIMARY KEY (personId),
    CONSTRAINT fk12 FOREIGN KEY (occupies) REFERENCES location (locId)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS pilot;
CREATE TABLE pilot (
	personId char(20) NOT NULL,
    taxId char(11) NOT NULL,
    commands char(5) NOT NULL,
    PRIMARY KEY (personId),
    CONSTRAINT fk1 FOREIGN KEY (personId) REFERENCES person (personId),
    CONSTRAINT fk11 FOREIGN KEY (commands) REFERENCES flight (flightId)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
	personId char(20) NOT NULL,
    miles decimal(9, 0) NOT NULL,
    funds decimal(9, 0) NOT NULL,
    PRIMARY KEY (personId),
    CONSTRAINT fk2 FOREIGN KEY (personId) REFERENCES person (personId)
) ENGINE=InnoDB;
