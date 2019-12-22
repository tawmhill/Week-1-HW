-- loadflights.sql

DROP TABLE IF EXISTS airlines;
DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS planes;
DROP TABLE IF EXISTS weather;

CREATE TABLE airlines (
  carrier varchar(2) PRIMARY KEY,
  name varchar(30) NOT NULL
  );
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/airlines.csv' 
INTO TABLE airlines 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE airports (
  faa char(3),
  name varchar(100),
  lat double precision,
  lon double precision,
  alt integer,
  tz integer,
  dst char(1)
  );
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/airports.csv' 
INTO TABLE airports
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE flights (
year integer,
month integer,
day integer,
dep_time integer,
dep_delay integer,
arr_time integer,
arr_delay integer,
carrier char(2),
tailnum char(6),
flight integer,
origin char(3),
dest char(3),
air_time integer,
distance integer,
hour integer,
minute integer
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/flights.csv' 
INTO TABLE flights
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(year, month, day, @dep_time, @dep_delay, @arr_time, @arr_delay,
 @carrier, @tailnum, @flight, origin, dest, @air_time, @distance, @hour, @minute)
SET
dep_time = nullif(@dep_time,''),
dep_delay = nullif(@dep_delay,''),
arr_time = nullif(@arr_time,''),
arr_delay = nullif(@arr_delay,''),
carrier = nullif(@carrier,''),
tailnum = nullif(@tailnum,''),
flight = nullif(@flight,''),
air_time = nullif(@air_time,''),
distance = nullif(@distance,''),
hour = dep_time / 100,
minute = dep_time % 100
;

CREATE TABLE planes (
tailnum char(6),
year integer,
type varchar(50),
manufacturer varchar(50),
model varchar(50),
engines integer,
seats integer,
speed integer,
engine varchar(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/planes.csv' 
INTO TABLE planes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tailnum, @year, type, manufacturer, model, engines, seats, @speed, engine)
SET
year = nullif(@year,''),
speed = nullif(@speed,'')
;

CREATE TABLE weather (
origin char(3),
year integer,
month integer,
day integer,
hour integer,
temp double precision,
dewp double precision,
humid double precision,
wind_dir integer,
wind_speed double precision,
wind_gust double precision,
precip double precision,
pressure double precision,
visib double precision
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/weather.csv' 
INTO TABLE weather
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(origin, @year, @month, @day, @hour, @temp, @dewp, @humid, @wind_dir,
@wind_speed, @wind_gust, @precip, @pressure, @visib)
SET
year = nullif(@year,''),
month = nullif(@month,''),
day = nullif(@day,''),
hour = nullif(@hour,''),
temp = nullif(@temp,''),
dewp = nullif(@dewp,''),
humid = nullif(@humid,''),
wind_dir = FORMAT(@wind_dir, 0),
wind_speed = nullif(@wind_speed,''),
wind_gust = nullif(@wind_gust,''),
precip = nullif(@precip,''),
pressure = nullif(@pressure,''),
visib = FORMAT(@visib,0)
;

SET SQL_SAFE_UPDATES = 0;
UPDATE planes SET engine = SUBSTRING(engine, 1, CHAR_LENGTH(engine)-1);


##Homework 1: SQL by Thomas Hill
##1. Which destination in the flights database is the furthest distance away, based on information in the flights table.
##Show the SQL query(s) that support your conclusion.

## Destination 'HNL' or Daniel K. Inouye International Airport in Honolulu, HI appears to be furthest away based on the maximum query of 4983 miles
##Based on query: 

SELECT * FROM flights ORDER BY distance DESC;

##2. What are the different numbers of engines in the planes table? For each number of engines, which aircraft have
##the most number of seats? Show the SQL statement(s) that support your result.

##Planes have between 1-4 engines, which I found running the preliminary query:

SELECT * from planes GROUP BY engines;

##To get more information about the number of seats, I ran four additional queries ordering planes by seats but limited by the number of engines

SELECT * from planes WHERE engines = 1 order by seats DESC;
SELECT * from planes WHERE engines = 2 order by seats DESC;
SELECT * from planes WHERE engines = 3 order by seats DESC;
SELECT * from planes WHERE engines = 3 order by seats DESC;

##One engine - 16 seats
##Two engines - 400 seats
##Three engines - 379 seats
##Four engines - 450 seats

##3. Show the total number of flights.

##This was previously used in the 'loadflights' script, the total number of departing flights is 336,776, or ~922 flights per day or 38 flights per hour in 2013

SELECT 'flights', COUNT(*) FROM flights;

##4. Show the total number of flights by airline (carrier).

##The folloiwng query returned 16 different carriers, with the higher number of flights at the top of the list

SELECT carrier, COUNT(*) FROM flights GROUP BY carrier;

##5. Show all of the airlines, ordered by number of flights in descending order.

SELECT carrier, COUNT(*) FROM flights GROUP BY carrier ORDER BY count(*) DESC;

##6. Show only the top 5 airlines, by number of flights, ordered by number of flights in descending order.

SELECT carrier, COUNT(*) FROM flights GROUP BY carrier ORDER BY count(*) DESC LIMIT 5;

##7. Show only the top 5 airlines, by number of flights of distance 1,000 miles or greater, ordered by number of
##flights in descending order.

SELECT carrier, COUNT(*) FROM flights WHERE distance > 999 GROUP BY carrier ORDER BY count(*) DESC LIMIT 5;

##8. Create a question that (a) uses data from the flights database, and (b) requires aggregation to answer it, and
##write down both the question, and the query that answers the question.

##For my own question, I wanted to know which airport destination is associated with the largest delay>
##Using the following query, I omitted all negative times (arriving early) and then calculated the average delay.
##I also included the distance to the destination airport as it would be interesting to see if there was a weak correlation to distance traveled. 

SELECT dest, avg(arr_delay), distance, (avg(arr_delay)/distance) FROM flights WHERE arr_delay > 0 GROUP BY dest ORDER BY avg(arr_delay) desc;