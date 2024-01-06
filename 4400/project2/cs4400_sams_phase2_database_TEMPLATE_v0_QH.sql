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
DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
  flightID char(10) NOT NULL,
  cost decimal(3,0) NOT NULL,
  follows char(20) NOT NULL,
  PRIMARY KEY (flightID)
  CONSTRAINT fk10 FOREIGN KEY (follows) REFERENCES route (routedID)
) ENGINE=InnoDB;

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

-- Table structure for table location
DROP TABLE IF EXISTS location;
CREATE TABLE location (
  locationID char(10) NOT NULL,
  PRIMARY KEY (locationID)
) ENGINE=InnoDB;

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