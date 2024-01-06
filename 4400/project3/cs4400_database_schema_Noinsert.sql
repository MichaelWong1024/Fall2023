create table airline (
    airlineID varchar(50),
    revenue integer default null,
    primary key (airlineID)
) engine = innodb;

create table location (
    locationID varchar(50),
    primary key (locationID)
) engine = innodb;

create table airplane (
    airlineID varchar(50),
    tail_num varchar(50),
    seat_capacity integer not null check (seat_capacity > 0),
    speed integer not null check (speed > 0),
    locationID varchar(50) default null,
    plane_type varchar(100) default null,
    skids boolean default null,
    propellers integer default null,
    jet_engines integer default null,
    primary key (airlineID, tail_num),
    constraint fk1 foreign key (airlineID) references airline (airlineID),
    constraint fk3 foreign key (locationID) references location (locationID)
) engine = innodb;

create table airport (
    airportID char(3),
    airport_name varchar(200),
    city varchar(100) not null,
    state varchar(100) not null,
    country char(3) not null,
    locationID varchar(50) default null,
    primary key (airportID),
    constraint fk2 foreign key (locationID) references location (locationID)
) engine = innodb;

create table person (
    personID varchar(50),
    first_name varchar(100) not null,
    last_name varchar(100) default null,
    locationID varchar(50) not null,
    primary key (personID),
    constraint fk8 foreign key (locationID) references location (locationID)
) engine = innodb;

create table passenger (
    personID varchar(50),
    miles integer default 0,
    funds integer default 0,
    primary key (personID),
    constraint fk6 foreign key (personID) references person (personID)
) engine = innodb;

create table passenger_vacations (
    personID varchar(50),
    airportID char(3) not null,
    sequence integer check (sequence > 0),
    primary key (personID, sequence),
    constraint fk19 foreign key (personID) references person (personID)
        on update cascade on delete cascade,
    constraint fk20 foreign key (airportID) references airport (airportID)
) engine = innodb;

create table leg (
    legID varchar(50),
    distance integer not null,
    departure char(3) not null,
    arrival char(3) not null,
    primary key (legID),
    constraint fk10 foreign key (departure) references airport (airportID),
    constraint fk11 foreign key (arrival) references airport (airportID)
) engine = innodb;

create table route (
    routeID varchar(50),
    primary key (routeID)
) engine = innodb;

create table route_path (
    routeID varchar(50),
    legID varchar(50) not null,
    sequence integer check (sequence > 0),
    primary key (routeID, sequence),
    constraint fk12 foreign key (routeID) references route (routeID),
    constraint fk13 foreign key (legID) references leg (legID)
) engine = innodb;

create table flight (
    flightID varchar(50),
    routeID varchar(50) not null,
    support_airline varchar(50) default null,
    support_tail varchar(50) default null,
    progress integer default null,
    airplane_status varchar(100) default null,
    next_time time default null,
    cost integer default 0,
    primary key (flightID),
    constraint fk14 foreign key (routeID) references route (routeID) on update cascade,
    constraint fk15 foreign key (support_airline, support_tail) references airplane (airlineID, tail_num)
        on update cascade on delete cascade
) engine = innodb;

create table pilot (
    personID varchar(50),
    taxID varchar(50) not null,
    experience integer default 0,
    commanding_flight varchar(50) default null,
    primary key (personID),
    unique key (taxID),
    constraint fk4 foreign key (personID) references person (personID),
    constraint fk9 foreign key (commanding_flight) references flight (flightID)
) engine = innodb;

create table pilot_licenses (
    personID varchar(50),
    license varchar(100),
    primary key (personID, license),
    constraint fk5 foreign key (personID) references pilot (personID)
        on update cascade on delete cascade
) engine = innodb;
