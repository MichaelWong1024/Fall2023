-- CS4400: Introduction to Database Systems: Tuesday, September 12, 2023
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  
1. A new airplane must be sponsored
by an existing airline, 
2. and must have a unique tail number for that airline.
username.  
3. An airplane must also have a non-zero seat capacity and speed. 
4. An airplane might also have other factors depending on it's type, like skids or some number
of engines.  
5.Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin

	
	--  A new airplane must be sponsored
	-- by an existing airline
    -- Check if the airlineID exists in the airline table
    if
    (SELECT COUNT(*)
    FROM airline
    WHERE airlineID = ip_airlineID) = 0 then leave sp_main; 
    end if;
    
    if
    (select count(*) FROM airplane where ip_tail_num = tail_num)
    >= 1 then leave sp_main;
    end if;
    
    if ip_seat_capacity <= 0 then leave sp_main; end if;
    if ip_speed <= 0 then leave sp_main; end if;
    if (select count(*) FROM location where locationID = ip_locationID) > 0 then leave sp_main; end if;
    
	


    -- Insert the new airplane into the airplane table
	INSERT INTO location (locationID) VALUES (ip_locationID);
    INSERT INTO airplane (airlineID, tail_num, seat_capacity, speed, locationID, plane_type, skids, propellers, jet_engines)
    VALUES (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
end //
delimiter ;





-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin

	-- ip_airportID unique
        if
    (SELECT COUNT(*)
    FROM airport
    WHERE airportID = ip_airportID) = 1 then leave sp_main; 
    end if;
    
    -- city,state,country not null
    if ip_city is null then leave sp_main;end if;
    if ip_state is null then leave sp_main;end if;
    if ip_country is null then leave sp_main;end if;

	-- ip_airport_name,
	if (select count(*) FROM location where locationID = ip_locationID) > 0 then leave sp_main; end if;
    

	INSERT INTO location (locationID) VALUES (ip_locationID);
	INSERT INTO airport(airportID,airport_name,city,state,country,locationID) VALUES (ip_airportID, ip_airport_name,ip_city,ip_state, ip_country,ip_locationID);
    
    
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
	-- call add_person('p61', 'Sabrina', 'Duncan', 'port_1', '366-50-3732', 27, null, null);
	-- personID unique
	if
    (SELECT COUNT(*)
    FROM person
    WHERE personID = ip_personID) > 0 then leave sp_main; 
    end if;
    
    -- first_name
    if ip_first_name is null then leave sp_main;end if;
    
    
    -- locID 

	if (select count(*) FROM location where locationID = ip_locationID) = 0 then leave sp_main; end if;

	-- INSERT INTO location (locationID) VALUES (ip_locationID);
	INSERT INTO person(personID,first_name,last_name,locationID) VALUES (ip_personID,ip_first_name,ip_last_name,ip_locationID);
    
    -- taxID -->> pilot
    if ip_taxID is not null and ip_experience is not null then
	INSERT INTO pilot(personID,taxID,experience,commanding_flight) VALUES(ip_personID,ip_taxID,ip_experience, null);
	end if;
    
    -- miles, funds -->> passenger
    if ip_miles is not null and ip_funds is not null then
    INSERT INTO passenger(personID, miles, funds) VALUES (ip_personID,ip_miles,ip_funds);
    end if;
    


end //
delimiter ;
-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it laready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	-- if license doesn't exist
	if
    
    (SELECT COUNT(*)
    FROM pilot_licenses
    WHERE ip_license = license and ip_personID = personID) > 0 then 
    DELETE FROM pilot_licenses where license = ip_license and personID = ip_personID;
    
    else 
		insert INTO pilot_licenses(personID,license) VALUES (ip_personID,ip_license);
    end if;
    


end //
delimiter ;


-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin

	-- valid route
	if
    (select count(*) from route where routeID = ip_routeID) = 0 
    then leave sp_main ;
    end if;
    
    
    -- the airplane must not be in use by another flight
    if
    (select count(*) from flight where support_airline = ip_support_airline and support_tail = ip_support_tail) > 0 
    then leave sp_main;
    end if;
    
    
    -- valid location along the route except for the final stop
    if
    ((select max(sequence) from route_path where routeID = ip_routeID) <= ip_progress)
    then leave sp_main;
    end if;
    
INSERT INTO flight(flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time, cost)
VALUES(ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 'on_ground', ip_next_time, ip_cost);

end //
delimiter ;

-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  
The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. 
for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin


	if
    (select count(*) from flight where flightID = ip_flightID ) = 0
    then leave sp_main;
    end if;
    
	
	if 
    (select airplane_status from flight where flightID = ip_flightID != 'in_flight' )
    then leave sp_main;
    end if;
   
    
-- 	update flight set progress = progress + 1,next_time = DATE_ADD(next_time,INTERVAL 1 HOUR),airplane_status = "on_ground" where airplane_status = "in_flight" and flightID = ip_flightID;
	update flight set next_time = DATE_ADD(next_time,INTERVAL 1 HOUR),airplane_status = 'on_ground' where airplane_status = 'in_flight' and flightID = ip_flightID;
	-- pilot increase experience
    update pilot set experience = experience + 1 where commanding_flight = ip_flightID;
    
--     -- passengers update miles.
--     -- routeID
-- 	Set @rID = (select routeID from flight where flightID = ip_flightID and airplane_status = 'in_flight');
--     Set @pro =  (select progress from flight where flightID = ip_flightID and airplane_status = 'in_flight');
--     -- legID
--     
--     select @rID;
--     Set @lID = (select legID from route_path where (routeID,sequence) = ((select routeID,progress from flight where flightID = ip_flightID and airplane_status = 'in_flight')) );
--     select @lID;
--     -- distance-miles
--     Set @dis = (select distance from leg where legID = (select legID from route_path where (routeID,sequence) = ((select routeID,progress from flight where flightID = ip_flightID and airplane_status = 'in_flight')) ));
--     Select @dis;
	SET @dis = (
		SELECT l.distance
		FROM flight f
		INNER JOIN route_path rp ON f.routeID = rp.routeID AND f.progress = rp.sequence
		INNER JOIN leg l ON rp.legID = l.legID
		WHERE f.flightID = ip_flightID AND f.airplane_status = 'in_flight'
	);

	-- airline-tail
    Set @line =( select support_airline from flight where flightID = ip_flightID);
    Set @tail = ( select support_tail from flight where flightID = ip_flightID);
    -- locID
    Set @locID =( select locationID from airplane where (airlineID, tail_num) = (@line,@tail));
    -- person ID
	-- Set @pID = (select personID from person where locationID = @locID);
    
    update passenger set miles = miles + (select distance from leg where legID = 'leg_2')where personID in (select personID from person where locationID = @locID);

    
end //
delimiter ;

-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

declare sp int;
    declare pl_type varchar(100);
    declare dist int;
    declare num_pilot int;
    
    if ip_flightID not in (select flightID from flight) then
		leave sp_main;
	end if;
    
    if (select airplane_status from flight where flightID = ip_flightID) like 'in_flight' then
		leave sp_main;
	end if;
    
    if (select progress from flight where ip_flightID = flightID) = 
    (select max(sequence) from flight as f join route_path as rp on f.routeID = rp.routeID 
    join leg as l on l.legID = rp.legID where f.flightID = ip_flightID) then
		leave sp_main;
	end if;
    
    if (select progress from flight where ip_flightID = flightID) is null then
		leave sp_main;
	end if;


-- correct version
	select distance into dist from flight as f join route_path as rp on f.routeID = rp.routeID 
	join leg as l on l.legID = rp.legID where f.flightID = ip_flightID and progress + 1 = sequence;

--     select airplane.speed, plane_type into sp, pl_type from airplane,flight
--     where airplane.tail_num = flight.support_tail and flight.flightid = ip_flightid;

	select a.speed, a.plane_type into sp, pl_type from flight as f 
    join airplane as a on f.support_tail = a.tail_num where f.flightID = ip_flightID;


	select count(*) into num_pilot from pilot as p join airplane as a on p.commanding_flight = a.tail_num 
	join flight as f on a.tail_num = f.support_tail where f.flightID = ip_flightID;
    
	if pl_type ='jet' and num_pilot < 2 then
		update flight set next_time = next_time + interval 30 minute
			where flight.flightid = ip_flightid;
		leave sp_main;
    end if;
    
	if pl_type ='prop' and num_pilot < 1 then
		update flight set next_time = next_time + interval 30 minute
			where flight.flightID = ip_flightID;
		leave sp_main;
    end if;

    update flight
    set airplane_status = 'in_flight', next_time = next_time + interval (dist/sp) hour,progress=progress+1
    where flight.flightID = ip_flightID;







--  	 declare v_airlineID varchar(50);
--      declare v_tailnum varchar(30);
--      declare v_routeID varchar(30);
--      declare v_seq integer;
--      declare v_legID varchar(30);
--      declare flag integer;
--      declare v_airplane_status varchar(50);

--     

--      declare v_distance integer;
--      declare v_speed integer;
--      declare v_plane_type varchar(100);
--      declare v_pilot_count integer;
--      declare v_flight_time float;
--      
--      -- Get flight leg information
--  	select support_airline,support_tail,routeID,progress,airplane_status into v_airlineID,v_tailnum, v_routeID,v_seq,v_airplane_status from flight where flightID = 'am_96';
--      select legID into v_legID from route_path where routeID = v_routeID and sequence = v_seq;
--      select distance into v_distance from leg where legID = v_legID;
--      if v_airplane_status = 'in_flight' then leave sp_main;end if;
--      

--      -- Get airplane information
--      select speed, plane_type into v_speed, v_plane_type
--      from airplane
--      where tail_num = v_tailnum;
--      
--      select 0 into flag;
--      
--      -- Calculate flight time (distance / speed)
--  	set v_flight_time = CAST(v_distance AS DECIMAL(10,2)) * 60 / CAST(v_speed AS DECIMAL(10,2));
--      
--      -- Count the number of pilots for the flight
--       select count(*) into v_pilot_count
--       from pilot
--       where commanding_flight = ip_flightID;

--       
--       -- Check if pilot requirements are met
--       if (v_plane_type = 'prop' and v_pilot_count >= 1) or 
--          (v_plane_type = 'jet' and v_pilot_count >= 2) then
--           -- Update flight state to 'In-Flight' and calculate expected arrival time
--           update flight
--           set airplane_status = 'in_flight', 
--               next_time = DATE_ADD(next_time, INTERVAL v_flight_time MINUTE)
--           where flightID = ip_flightID;
--           select 3 into flag;
--       else
--           -- Delay flight by 30 minutes
--           update flight
--           set next_time = DATE_ADD(next_time, INTERVAL 30 MINUTE)
--           where flightID = ip_flightID;
--           select 2 into flag;
--       end if;
--       

-- -- -- Check if pilot requirements are met

--       select v_airlineID,v_tailnum,v_routeID,v_seq,v_legID,flag,v_airplane_status,v_distance,v_speed,v_plane_type,v_pilot_count,v_flight_time;
end //
delimiter ;

-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin

-- check the status and progress of flight (so that it is eligible to take off)
    if ((select airplane_status from flight where flightID = ip_flightID)  = 'in_flight') 
    then leave sp_main;
    end if;
    
	-- The passengers must be at the same airport as the flight
    Set @support_airline = (select support_airline from flight where flightID = ip_flightID);
    Set @support_tail = (select support_airline from flight where flightID = ip_flightID);
    Set @locationID = (select locationID from airplane where (@support_airline = airlineID) and (@support_tail = tail_num));
    -- Set @personID = (select personID from person where @locationID = locationID);
    
    -- The flight must be heading towards that passenger's desired destination
    -- 1. get the destination of the flight
    Set @routeID = (select routeID from flight where flightID = ip_flightID);
    Set @progress = (select progress from flight where flightID = ip_flightID);
    Set @legID = (select legID from route_path where (routeID = @routeID) and (sequence = @progress));
    Set @arrival = (select arrival from leg where legID = @legID);
    -- 2. get all passengers who will go to the destination
    -- Set @personID_des = (select personID from passenger_vacations where airportID = @arrival);

    -- Inner join all Passengers
    drop temporary table if exists temp1;
    create temporary table temp1
    as select a1.personID from 
    (select personID from person where @locationID = locationID) as a1
    natural join
    (select personID from passenger_vacations where airportID = @arrival) as a2;
    
    -- each passenger must have enough funds to cover the flight
    Set @cost = (select cost from flight where flightID = ip_flightID);
    
    drop temporary table if exists temp2;
    create temporary table temp2
    as select b1.personID from
    (select personID from temp1) as b1
    natural join
    (select personID from passenger where funds >= @cost) as b2;
    
    -- there must be enough seats to accommodate all boarding passengers
    Set @capacity = (select seat_capacity from airplane where (@support_airline = airlineID) and (@support_tail = tail_num));
	Set @numPassenger = (select count(*) from temp2);
    if (@capacity < @numPassenger) 
    then leave sp_main;
    end if;
    
    -- updates the state for passengers getting on a flight at its current airport
    update passenger_vacations set sequence = @progress where
    (personID = (select personID from temp2));

end //
delimiter ;


-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin

-- the flight must be located at the destination airport as referenced by the ticket.
    -- test airplane_status
    SET @airplane_status = (SELECT airplane_status FROM flight WHERE flightID = ip_flightID);
    if (@airplane_status != 'on_ground')
    then leave sp_main;
    end if;
	-- airplane has not taken off 
    SET @progress = (SELECT progress FROM flight WHERE flightID = ip_flightID);
    if (@progress = 0)
    then leave sp_main;
    end if;
    
    -- The passengers must be on that flight
    -- get the personID of passaengers on the given flight
    -- flightID -> airline+tail_number -> airplane locationID -> personID
    SET @airline_tail = (SELECT concat(support_airline,'_',support_tail) FROM flight WHERE flightID = ip_flightID);
    SET @airplane_locationID = (SELECT locationID FROM airplane WHERE concat(airlineID, '_',tail_num) = @airline_tail); -- plane_20
    
    -- get the current located airportID
    -- flightID -> routeID + progress -> legID -> arrival airportID -> current locationID
    SET @routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID); -- pacific_rim_tour
    SET @progress = (SELECT progress FROM flight WHERE flightID = ip_flightID); -- 1

    SET @legID = (SELECT legID FROM route_path WHERE routeID = @routeID and sequence = @progress);  -- leg_7
    SET @curr_airportID = (SELECT arrival FROM leg WHERE legID = @legID);  -- CAN
    SET @curr_locationID = (SELECT locationID FROM airport WHERE airportID = @curr_airportID); -- port_7
    
    -- get all the passengers whose distination is curr_airportID
    -- personID -> destination airportID (vacation table)
    
    -- get the passengers on the given flight who need to go off
    SET @person_count = (SELECT count(table2.personID) FROM
                  ((SELECT personID FROM passenger_vacations WHERE airportID = @curr_airportID) as table1,
				  (SELECT personID FROM person WHERE locationID = @airplane_locationID) as table2) WHERE table1.personID = table2.personID);

	-- if no passenger goes off
	IF (@person_count = 0)
    then leave sp_main;
    ELSE 
		UPDATE person SET locationID = @curr_locationID 
				  WHERE person.personID in (SELECT table2.personID FROM
                  ((SELECT personID FROM passenger_vacations WHERE airportID = @curr_airportID) as table1,
				  (SELECT personID FROM person WHERE locationID = @airplane_locationID) as table2) WHERE table1.personID = table2.personID);
	END IF;

end //
delimiter ;

-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

	-- test case :  assign_pilot('lf_20', 'p18');

	-- check if this person is inside the pilot table (if not, leave)
	if ((select count(*) from pilot where personID = ip_personID) = 0) 
		then leave sp_main;
		end if;

	-- get the type of given flight
	set @flight_type =  (select plane_type 
							from airplane 
							join flight on airlineID = support_airline and tail_num = support_tail 
							where flightID = ip_flightID
						);
	-- get location of given flight
	set @flight_loc =  (select locationID 
							from airplane 
							join flight on airlineID = support_airline and tail_num = support_tail 
							where flightID = ip_flightID
						);

	-- check if given pilot has the license for that particular type (if not, leave)
	if ((select count(*) from pilot_licenses where personID = ip_personID and license = @flight_type) = 0)
		then leave sp_main;
		end if;

	-- check if given pilot already supported another flight (if yes, leave)
	set @curr_commanding = (select commanding_flight from pilot where personID = ip_personID);
	if (@curr_commanding is not null) then leave sp_main; end if;

	-- assign pilot to that flight
	update pilot set commanding_flight = ip_flightID where personID = ip_personID;

	-- update pilot's location 
	update person set locationID = @flight_loc where personID = ip_personID;

end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

DECLARE route_name VARCHAR(50);
DECLARE end_leg INT DEFAULT 0;
DECLARE loc VARCHAR(50);
DECLARE arrive VARCHAR(50);

-- check if flight in the air
IF ip_flightID IN (SELECT flightID FROM flight WHERE airplane_status = 'in_flight') THEN
    LEAVE sp_main;
END IF;

-- check if flight is the last leg
SET route_name = (SELECT routeID FROM flight WHERE flightID = ip_flightID);
SET end_leg = (SELECT MAX(sequence) FROM route_path WHERE route_name = routeID GROUP BY routeID);
IF end_leg != (SELECT progress FROM flight WHERE flightID = ip_flightID) THEN
    LEAVE sp_main;
END IF;

-- check if there are passengers on the plane
SET loc = (SELECT locationID FROM airplane WHERE tail_num IN (SELECT support_tail FROM flight WHERE flightID = ip_flightID));
IF 0 != (SELECT COUNT(personID) FROM person WHERE locationID = loc AND personID IN (SELECT personID FROM passenger)) THEN
    LEAVE sp_main;
END IF;

-- update person location
SET arrive = (SELECT locationID FROM airport WHERE airportID IN (SELECT arrival FROM leg WHERE legID IN (SELECT legID FROM route_path WHERE sequence = end_leg AND route_name = routeID)));
UPDATE person
SET locationID = arrive
WHERE locationID = loc AND personID IN (SELECT personID FROM pilot);

-- update pilot
UPDATE pilot
SET commanding_flight = NULL
WHERE commanding_flight = ip_flightID;


end //
delimiter ;

-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin



if ip_flightID not in (select flightID from flight where airplane_status = 'on_ground') or ip_flightID is null then
leave sp_main; end if;

if ip_flightID in (select flightID from flight where progress = 0 or progress = 
(select max(rp.sequence) from flight as f join route_path as rp on rp.routeID = f.routeID where f.flightID = ip_flightID)) 
then delete from flight where flightID = ip_flightID; end if;


end //
delimiter ;

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin


	DECLARE testCase VARCHAR(50);

	-- select next min(next_time) flight
	SET testCase = (
		SELECT flightID
		FROM flight 
		WHERE next_time = (SELECT MIN(next_time) FROM flight)
		GROUP BY flightID
		ORDER BY airplane_status = 'in_flight', flightID
		LIMIT 1
	);

	-- if in flight, perform landing and disembark 
	IF EXISTS (
		SELECT flightID 
		FROM flight 
		WHERE airplane_status = 'in_flight' AND flightID = testCase
	) THEN
		CALL flight_landing(testCase);
		CALL passengers_disembark(testCase); 
	END IF;

	-- if on ground ,board and takeoff
	IF EXISTS (
		SELECT flightID 
		FROM flight 
		WHERE airplane_status = 'on_ground' AND flightID = testCase
	) THEN
		CALL passengers_board(testCase);
		CALL flight_takeoff(testCase);
	END IF;

	-- if is over, recyle_crew and retire flight
	IF EXISTS (
		SELECT fli.flightID 
		FROM flight fli, route_path rou 
		WHERE fli.airplane_status = 'on_ground' 
		AND fli.routeID = rou.routeID 
		AND fli.flightID = testCase 
		AND fli.progress = rou.sequence
	) THEN 
		CALL recycle_crew(testCase);
		CALL retire_flight(testCase);
	END IF;


end //
delimiter ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
	 SELECT 
		l.departure AS departing_from, 
		l.arrival AS arriving_at,      
		COUNT(f.flightID) AS num_flights,              
		GROUP_CONCAT(f.flightID) AS flight_list,       
		MIN(f.next_time) AS earliest_arrival,          
		MAX(f.next_time) AS latest_arrival,            
		GROUP_CONCAT(a.locationID) AS airplane_list    
	FROM 
		flight AS f

		JOIN route_path AS rp ON f.routeID = rp.routeiD
		JOIN leg AS l ON rp.legID = l.legID
		JOIN airplane AS a ON f.support_airline = a.airlineID AND f.support_tail = a.tail_num
	WHERE 
		f.progress = rp.sequence AND     
		airplane_status = 'in_flight'
	GROUP BY 
		departing_from, 
		arriving_at;

-- [15] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
    
    SELECT 
		l.arrival AS departing_from,    
		COUNT(f.flightID) AS num_flights,              
		GROUP_CONCAT(f.flightID) AS flight_list,       
		MIN(f.next_time) AS earliest_arrival,          
		MAX(f.next_time) AS latest_arrival,            
		GROUP_CONCAT(a.locationID) AS airplane_list    
	FROM 
		flight AS f

		JOIN route_path AS rp ON f.routeID = rp.routeiD
		JOIN leg AS l ON rp.legID = l.legID
		JOIN airplane AS a ON f.support_airline = a.airlineID AND f.support_tail = a.tail_num
	WHERE 
		f.progress = rp.sequence AND     
		airplane_status = 'on_ground'
	GROUP BY 
		departing_from
	UNION
    SELECT 
		l.departure AS departing_from,    
		COUNT(f.flightID) AS num_flights,              
		GROUP_CONCAT(f.flightID) AS flight_list,       
		MIN(f.next_time) AS earliest_arrival,          
		MAX(f.next_time) AS latest_arrival,            
		GROUP_CONCAT(a.locationID) AS airplane_list    
	FROM 
		flight AS f

		JOIN route_path AS rp ON f.routeID = rp.routeiD
		JOIN leg AS l ON rp.legID = l.legID
		JOIN airplane AS a ON f.support_airline = a.airlineID AND f.support_tail = a.tail_num
	WHERE 
		f.progress + 1= rp.sequence AND     
		airplane_status = 'on_ground'
	GROUP BY 
		departing_from;

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
    -- reuse some code from flights_in_the_air to select the columns needed and name accordingly
    select l.departure as departing_from, l.arrival as arriving_at, 
		count(distinct concat(a.airlineID, '-', a.tail_num)) as num_airplane, 
        group_concat(distinct a.locationID) as airplane_list, 
		group_concat(distinct f.flightID) as flight_list, 
        min(f.next_time) as earliest_arrival, 
		max(f.next_time) as latest_arrival, 
        count(pilot.personID) as num_pilots, 
        count(passenger.personID) as num_passengers, 
		count(p.personID) as joint_pilots_passengers, 
        group_concat(p.personID) as person_list

	from person as p 
    join airplane as a on p.locationID = a.locationID
    join flight as f on a.airlineID = f.support_airline and a.tail_num = f.support_tail
    join route_path as rp on f.routeID = rp.routeID
    join leg as l on rp.legID=l.legID
    left join passenger on p.personID = passenger.personID
    left join pilot on p.personID = pilot.personID
    -- in flight at where progress and sequence is the same, 
	-- so currently in flight
	where airplane_status='in_flight' and f.progress=rp.sequence
	group by l.departure, l.arrival, f.flightID;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
     select apt.airportID as departing_from, p.locationID as airport, apt.airport_name, 
    apt.city, apt.state,apt.country,count(pilot.personID) as num_pilots, count(passenger.personID) as num_passengers, 
    count(p.personID) as joint_pilots_passengers, group_concat(p.personID) as person_list
	from person as p
    join airport as apt on p.locationID=apt.locationID
	left join pilot on p.personID=pilot.personID
	left join passenger on p.personID=passenger.personID
    -- we need all these columns in select statement so we should gropu by all of them
	group by apt.airportID, p.locationID, apt.airport_name, apt.city, apt.state,apt.country
    -- the use-case result table looks ordered by airportID
	order by apt.airportID;

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
SELECT 
    r.routeID AS route,
    COUNT(DISTINCT rp.legID) AS num_legs,
    GROUP_CONCAT(DISTINCT rp.legID ORDER BY rp.sequence) AS leg_sequence,
    route_total_distance.total_distance AS route_length,
    COUNT(DISTINCT f.flightID) AS num_flights,
    GROUP_CONCAT(DISTINCT f.flightID) AS flight_list,
    GROUP_CONCAT(DISTINCT CONCAT(l.departure, '->', l.arrival) ORDER BY rp.sequence) AS airport_sequence
FROM 
    route r
    
    JOIN route_path rp ON r.routeID = rp.routeID
    JOIN leg l ON rp.legID = l.legID
    LEFT JOIN flight f ON r.routeID = f.routeID
    
    JOIN (
        SELECT 
            routeID, 
            SUM(distance) AS total_distance 
        FROM 
            route_path rp 
            JOIN leg l ON rp.legID = l.legID 
        GROUP BY 
            routeID
    ) AS route_total_distance ON r.routeID = route_total_distance.routeID
GROUP BY 
    r.routeID;
-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
	SELECT 
		city, 
		state,
		country,
		COUNT(*) AS num_airports, 
		GROUP_CONCAT(airportID ORDER BY airportID ASC SEPARATOR ', ') AS airport_code_list, 
		GROUP_CONCAT(airport_name ORDER BY airportID ASC SEPARATOR ', ') AS airport_name_list 
	FROM 
		airport
	GROUP BY 
		city, state, country -- Added country here
	HAVING 
		COUNT(airportID) > 1
	ORDER BY 
		city;
