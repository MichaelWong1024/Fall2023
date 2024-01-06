CREATE TABLE prop (
    airlineId decimal(10,0) NOT NULL,
    tail_num char(10) NOT NULL,
    props decimal(1,0) NOT NULL,
    skids bit(1) NOT NULL,
    PRIMARY KEY (airlineId, tail_num),
    CONSTRAINT prop_fk FOREIGN KEY (airlineId, tail_num) REFERENCES airplane (airlineId, tail_num)
) ENGINE=InnoDB;

CREATE TABLE jet (
    airlineId decimal(10,0) NOT NULL,
    tail_num char(10) NOT NULL,
    engines decimal(1,0) NOT NULL,
    PRIMARY KEY (airlineId, tail_num),
    CONSTRAINT jet_fk FOREIGN KEY (airlineId, tail_num) REFERENCES airplane (airlineId, tail_num)
) ENGINE=InnoDB;


CREATE TABLE support (
    flightId decimal(10,0) NOT NULL,
    airlineId decimal(10,0) NOT NULL,
    tail_num char(10) NOT NULL,
    progress decimal(1,0) NOT NULL,
    next_time TIME NOT NULL,
    status char(20) NOT NULL,
    PRIMARY KEY (flightId, airlineId, tail_num),
    CONSTRAINT flight_fk FOREIGN KEY (flightId) REFERENCES flight (flightId),
    CONSTRAINT airline_fk FOREIGN KEY (airlineId, tail_num) REFERENCES airplane (airlineId, tail_num)
) ENGINE=InnoDB;



CREATE TABLE contains (
    routeId decimal(10,0) NOT NULL,
    legId decimal(10,0) NOT NULL,
    sequence decimal(1,0) NOT NULL,
    PRIMARY KEY (routeId, legId, sequence),
    CONSTRAINT route_fk FOREIGN KEY (routeId) REFERENCES route (routeId),
    CONSTRAINT leg_fk FOREIGN KEY (legId) REFERENCES leg (legId)
) ENGINE=InnoDB;



