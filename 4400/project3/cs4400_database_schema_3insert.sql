create table airline (
	airlineID varchar(50),
    revenue integer default null,
    primary key (airlineID)
) engine = innodb;

insert into airline values ('Delta', 53000);
insert into airline values ('United', 48000);
insert into airline values ('British Airways', 24000);

create table location (
	locationID varchar(50),
    primary key (locationID)
) engine = innodb;

insert into location values ('port_1');
insert into location values ('port_2');
insert into location values ('port_3');

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

insert into airplane values ('Delta', 'n106js', 4, 800, 'plane_1', 'jet', null, null, 2);
insert into airplane values ('Delta', 'n110jn', 5, 800, null, 'jet', null, null, 2);
insert into airplane values ('Delta', 'n127js', 4, 600, null, 'jet', null, null, 4);

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

insert into airport values ('ATL', 'Atlanta Hartsfield_Jackson International', 'Atlanta', 'Georgia', 'USA', 'port_1');
insert into airport values ('DXB', 'Dubai International', 'Dubai', 'Al Garhoud', 'UAE', 'port_2');
insert into airport values ('HND', 'Tokyo International Haneda', 'Ota City', 'Tokyo', 'JPN', 'port_3');

create table person (
	personID varchar(50),
    first_name varchar(100) not null,
    last_name varchar(100) default null,
    locationID varchar(50) not null,
    primary key (personID),
    constraint fk8 foreign key (locationID) references location (locationID)
) engine = innodb;

insert into person values ('p1', 'Jeanne', 'Nelson', 'plane_1');
insert into person values ('p2', 'Roxanne', 'Byrd', 'plane_1');
insert into person values ('p3', 'Tanya', 'Nguyen', 'plane_5');

create table passenger (
	personID varchar(50),
    miles integer default 0,
    funds integer default 0,
    primary key (personID),
    constraint fk6 foreign key (personID) references person (personID)
) engine = innodb;

insert into passenger values ('p21', 771, 700);
insert into passenger values ('p22', 374, 200);
insert into passenger values ('p23', 414, 400);

create table passenger_vacations (
	personID varchar(50),
    airportID char(3) not null,
    sequence integer check (sequence > 0),
    primary key (personID, sequence),
    constraint fk19 foreign key (personID) references person (personID)
		on update cascade on delete cascade,
    constraint fk20 foreign key (airportID) references airport (airportID)
) engine = innodb;

insert into passenger_vacations values ('p21', 'AMS', 1);
insert into passenger_vacations values ('p22', 'AMS', 1);
insert into passenger_vacations values ('p23', 'BER', 1);

create table leg (
	legID varchar(50),
    distance integer not null,
    departure char(3) not null,
    arrival char(3) not null,
    primary key (legID),
    constraint fk10 foreign key (departure) references airport (airportID),
    constraint fk11 foreign key (arrival) references airport (airportID)
) engine = innodb;

insert into leg values ('leg_1', 400, 'AMS', 'BER');
insert into leg values ('leg_2', 3900, 'ATL', 'AMS');
insert into leg values ('leg_3', 3700, 'ATL', 'LHR');

create table route (
	routeID varchar(50),
    primary key (routeID)
) engine = innodb;

insert into route values ('euro_north');
insert into route values ('euro_south');
insert into route values ('south_euro_loop');

create table route_path (
	routeID varchar(50),
    legID varchar(50) not null,
    sequence integer check (sequence > 0),
    primary key (routeID, sequence),
    constraint fk12 foreign key (routeID) references route (routeID),
    constraint fk13 foreign key (legID) references leg (legID)
) engine = innodb;

insert into route_path values ('euro_north', 'leg_16', 1);
insert into route_path values ('euro_north', 'leg_24', 2);
insert into route_path values ('euro_north', 'leg_5', 3);

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

insert into flight values ('dl_10', 'americas_one', 'Delta', 'n106js', 1, 'in_flight', '08:00:00', 200);
insert into flight values ('un_38', 'americas_three', 'United', 'n380sd', 2, 'in_flight', '14:30:00', 200);
insert into flight values ('ba_61', 'americas_two', 'British Airways', 'n616lt', 0, 'on_ground', '09:30:00', 200);

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

insert into pilot values ('p1', '330-12-6907', 31, 'dl_10');
insert into pilot values ('p2', '842-88-1257', 9, 'dl_10');
insert into pilot values ('p3', '750-24-7616', 11, 'un_38');

create table pilot_licenses (
	personID varchar(50),
    license varchar(100),
    primary key (personID, license),
    constraint fk5 foreign key (personID) references pilot (personID)
		on update cascade on delete cascade
) engine = innodb;

insert into pilot_licenses values ('p1', 'jet');
insert into pilot_licenses values ('p2', 'jet');
insert into pilot_licenses values ('p2', 'prop');
