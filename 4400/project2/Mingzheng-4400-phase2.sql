DROP TABLE IF EXISTS license;
CREATE TABLE license (
    personId DECIMAL(10,0) NOT NULL,
    license_name CHAR(20) NULL,
    PRIMARY KEY (personId),
    FOREIGN KEY (personId) REFERENCES persons(personId)
) ENGINE=InnoDB;


DROP TABLE IF EXISTS vacation;
CREATE TABLE vacation (
    personId DECIMAL(10,0) NOT NULL,
    vacation_details CHAR(13) NULL,
    PRIMARY KEY (personId),
    FOREIGN KEY (personId) REFERENCES persons(personId)
) ENGINE=InnoDB;


DROP TABLE IF EXISTS airplane;
CREATE TABLE airplane (
    airlineId DECIMAL(10,0) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    speed DECIMAL(3,0) NOT NULL,
    seat_cap DECIMAL(3,0) NOT NULL,
    locId DECIMAL(10,0) NULL,
    PRIMARY KEY (tail_num),
    FOREIGN KEY (airlineId) REFERENCES airlines(airlineId),
    FOREIGN KEY (locId) REFERENCES locations(locId)
) ENGINE=InnoDB;
