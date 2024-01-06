reating the license table
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
