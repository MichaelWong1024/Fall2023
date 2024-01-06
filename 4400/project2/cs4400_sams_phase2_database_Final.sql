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


-- Table structure for table flight

-- Creating the route table
DROP TABLE IF EXISTS route;
CREATE TABLE route (
    routeId char(20) NOT NULL, 
    PRIMARY KEY (routeId)
);

-- Creating the leg table
DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
    legId decimal(3,0) NOT NULL,
    distance decimal(5,0) NOT NULL, 
    departs char(3) NOT NULL,
    arrives char(3) NOT NULL,
    PRIMARY KEY (legId),
    CONSTRAINT fk8 FOREIGN KEY (departs) REFERENCES airport(airportId),
    CONSTRAINT fk9 FOREIGN KEY (arrives) REFERENCES airport(airportId)
);

-- Creating the airport table
DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
    airportId char(3) NOT NULL,
    name char(100) NOT NULL,
    city char(50) NOT NULL,
    state char(50) NOT NULL,
    country char(3) NOT NULL,
    locId char(20),
    PRIMARY KEY (airportId),
    CONSTRAINT fk17 FOREIGN KEY (locId) REFERENCES location(locId)
);

-- flight
DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
  flightId char(10) NOT NULL,
  cost decimal(5,0) NOT NULL,
  follows char(20) NOT NULL,
  PRIMARY KEY (flightId),
  CONSTRAINT fk10 FOREIGN KEY (follows) REFERENCES route (routeId)
) ENGINE=InnoDB;



-- Table structure for table location
DROP TABLE IF EXISTS location;
CREATE TABLE location (
  locId char(20) NOT NULL,
  PRIMARY KEY (locId)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
  airlineId char(30) NOT NULL,
  revenue decimal(5,0) NOT NULL,
  PRIMARY KEY (airlineId)
) ENGINE=InnoDB;


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
    commands char(10) NOT NULL,
    PRIMARY KEY (personId),
    CONSTRAINT fk1 FOREIGN KEY (personId) REFERENCES person (personId),
    CONSTRAINT fk11 FOREIGN KEY (commands) REFERENCES flight (flightId)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
	personId char(20) NOT NULL,
    miles decimal(5, 0) NOT NULL,
    funds decimal(5, 0) NOT NULL,
    PRIMARY KEY (personId),
    CONSTRAINT fk2 FOREIGN KEY (personId) REFERENCES person (personId)
) ENGINE=InnoDB;

-- Creating the license table
DROP TABLE IF EXISTS license;
CREATE TABLE license (
    personId char(20) NOT NULL,
    license_name char(20) NOT NULL,
    PRIMARY KEY (personId, license_name),
    CONSTRAINT fk3 FOREIGN KEY (personId) REFERENCES person(personId)
);

-- Creating the vacation table
DROP TABLE IF EXISTS vacation;
CREATE TABLE vacation (
    personId char(20) NOT NULL,
    destination char(3) NOT NULL,
    sequence decimal(1,0) NOT NULL,
    PRIMARY KEY (personId, destination, sequence),
    CONSTRAINT fk4 FOREIGN KEY (personId) REFERENCES person(personId)
);

-- Creating the airplane table
DROP TABLE IF EXISTS airplane;
CREATE TABLE airplane (
    airlineId char(30) NOT NULL,
    tail_num char(10) NOT NULL,
    speed decimal(4,0) NOT NULL,
    seat_cap decimal(3,0) NOT NULL,
    locId char(20),
    PRIMARY KEY (airlineId, tail_num),
    CONSTRAINT fk5 FOREIGN KEY (airlineId) REFERENCES airline(airlineId),
    CONSTRAINT fk18 FOREIGN KEY (locId) REFERENCES location(locId)
);

DROP TABLE IF EXISTS prop;
CREATE TABLE prop (
    airlineId char(30) NOT NULL,
    tail_num char(10) NOT NULL,
    props decimal(1,0) NOT NULL,
    skids bit(1) NOT NULL,
    PRIMARY KEY (airlineId, tail_num),
    CONSTRAINT fk6 FOREIGN KEY (airlineId, tail_num) REFERENCES airplane (airlineId, tail_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS jet;
CREATE TABLE jet (
    airlineId char(30) NOT NULL,
    tail_num char(10) NOT NULL,
    engines decimal(1,0) NOT NULL,
    PRIMARY KEY (airlineId, tail_num),
    CONSTRAINT fk7 FOREIGN KEY (airlineId, tail_num) REFERENCES airplane (airlineId, tail_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS support;
CREATE TABLE support (
    flightId decimal(10,0) NOT NULL,
    airlineId decimal(10,0) NOT NULL,
    tail_num char(10) NOT NULL,
    progress decimal(1,0) NOT NULL,
    next_time TIME NOT NULL,
    status char(20) NOT NULL,
    PRIMARY KEY (flightId, airlineId, tail_num),
    CONSTRAINT fk13 FOREIGN KEY (flightId) REFERENCES flight (flightId),
    CONSTRAINT fk14 FOREIGN KEY (airlineId, tail_num) REFERENCES airplane (airlineId, tail_num)
) ENGINE=InnoDB;


-- Creating the contains table
DROP TABLE IF EXISTS contains;
CREATE TABLE contains (
    routeId char(20) NOT NULL,
    legId decimal(3,0) NOT NULL,
    sequence decimal(1,0) NOT NULL,
    PRIMARY KEY (routeId, legId, sequence),
    CONSTRAINT fk15 FOREIGN KEY (routeId) REFERENCES route (routeId),
    CONSTRAINT fk16 FOREIGN KEY (legId) REFERENCES leg (legId)
) ENGINE=InnoDB;


-- Make sure to create the referenced tables like person, airline, and location 
-- before executing this script to avoid foreign key constraint errors.

-- Dumping data for table flight
-- The data order must match the order of the columns in the corresponding create table statement 
INSERT INTO flight VALUES
('dl_10',200, 'americas_one'),
('un_38',200, 'americas_three'),
('ba_61',200, 'americas_two'),
('lf_20',300, 'euro_north'),
('km_16',400, 'euro_south'),
('ba_51',100, 'big_europe_loop'),
('ja_35',300, 'pacific_rim_tour'),
('ry_34',100, 'germany_local');


-- Dumping data for table location
-- The data order must match the order of the columns in the corresponding create table statement 
INSERT INTO location VALUES
('port_1'),
('port_2'),
('port_3'),
('port_10'),
('port_17'),
('plane_1'),
('plane_5'),
('plane_8'),
('plane_13'),
('plane_20'),
('port_12'),
('port_14'),
('port_15'),
('port_20'),
('port_4'),
('port_16'),
('port_11'),
('port_23'),
('port_7'),
('port_6'),
('port_13'),
('port_21'),
('port_18'),
('port_22'),
('plane_6'),
('plane_18'),
('plane_7');