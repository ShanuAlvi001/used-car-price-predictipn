create database capstone1;
use capstone1;
# imported table data

select * from train_data;
alter table train_data drop column Myunknowncolumn, drop column new_price;

select * from train_data;
desc train_data;


# Cleaning string based columns
UPDATE train_data SET Engine = REPLACE(Engine, ' CC', '');
UPDATE train_data SET Mileage = REPLACE(Mileage, ' kmpl', ''); 
UPDATE train_data SET Mileage = REPLACE(Mileage, ' km/kg', ''); 
UPDATE train_data SET Power = REPLACE(Power, ' bhp', ''); 
UPDATE train_data SET Power = REPLACE(Power, 'null', '0.0000');
desc train_data;

# Changing columns data types
alter table train_data modify Power float;
alter table train_data modify Engine int; 
alter table train_data modify Price float;

select * from train_data;

# cleaning few car names and ownertype
Update train_data Set Name = replace(Name, 'Mini', 'MiniCooper');
update train_data set Name = replace(Name, 'Land Rover', 'LandRover');
update train_data set Name = replace(Name, 'ISUZU', 'Isuzu');
update train_data set Name = replace(Name, 'Mercedes-Benz', 'MercedesBenz');
update train_data set Owner_Type = replace(Owner_Type, 'Fourth & Above', 'Fourth_and_Above');

# Generating Brand column
select distinct substring_index(Name,' ', 1) as Brand from train_data;
select distinct substring_index(Name,' ',2) as Model from train_data;

alter table train_data add column Brand varchar(40);
UPDATE train_data set Brand = SUBSTRING_INDEX(Name, ' ', 1);

select * from train_data;


# continuing model further on python...

# INSIGHTS
-- Display the number of cars from each location.
SELECT location, count(*) AS AvgPrice
FROM train_data
GROUP BY location;

-- Select Avg Car price based on Brands in descedning order of avg Brands.
select Brand ,round(avg(Price),2) as AvgPrice_in_lacs from Train_data group by Brand
order by AvgPrice_in_lacs desc;

-- select top selling model from each car brand. 
SELECT Brand, Name AS TopSellingModel FROM (
select Brand, Name, ROW_NUMBER() over (PARTITION BY Brand ORDER BY COUNT(*) DESC) as RowNum
from train_data group by Brand, Name) as Ranked
WHERE RowNum = 1;

-- generate a stored procedure to show top n brands with most cars.
call top_n_brands(5);


-- generate a stored procedure to show top n most expensive cars with their brands.
call top_n_exp_cars(7);

-- query data for those cars whose mileage is higher than the avg mileage of all the cars.
SELECT * FROM train_data WHERE Mileage > 
(SELECT AVG(Mileage) FROM train_data);

-- query data for those cars whose mileage is higher than the avg mileage of that Brand cars.
WITH AvgMileageByBrand AS (
SELECT Brand, AVG(Mileage) AS AvgBrandMileage FROM train_data
GROUP BY Brand)
SELECT t.* FROM train_data t JOIN AvgMileageByBrand a ON t.Brand = a.Brand
WHERE t.Mileage > a.AvgBrandMileage;


-- show each fuel type wise count of automatic and manual cars.
SELECT fuel_type,
SUM(CASE WHEN transmission = 'Automatic' THEN 1 ELSE 0 END) AS automatic_count,
SUM(CASE WHEN transmission = 'Manual' THEN 1 ELSE 0 END) AS manual_count
FROM train_data
GROUP BY fuel_type;

-- Display the variation in price of the cars over the years.
SELECT Year, AVG(Price) AS AvgPrice_in_lacs
FROM train_data
GROUP BY Year order by year;

-- show location wise the no. of cars based on owner_type.
select location,
COUNT(CASE WHEN owner_type = 'First' THEN 1 END) AS First_Owner,
COUNT(CASE WHEN owner_type = 'Second' THEN 1 END) AS Second_Owner,
COUNT(CASE WHEN owner_type = 'Third' THEN 1 END) AS Third_Owner,
COUNT(CASE WHEN owner_type = 'Fourth_and_Above' THEN 1 END) AS Fourth_and_Above
FROM train_data GROUP BY location;

-- select Brand-wise Average Engine Power for Cars Manufactured After 2015.
SELECT brand, AVG(engine) AS avg_power
FROM train_data
WHERE year > 2015
GROUP BY brand;

-- generate a stored procedure that will take three arguments. minimum price, maximum price and location. 
-- on calling that stored procedure user must obtain records from that location and price range.
call get_records1(10,25,'delhi');


-- query location, brand, name, year, fueltype, mileage and price of top 5 expensive cars from each location.
SELECT location, brand, name, year, fuel_type, mileage, price FROM (
SELECT location, brand, name, year, fuel_type, mileage, price, ROW_NUMBER() OVER 
(PARTITION BY location ORDER BY price DESC) AS row_num
FROM train_data) AS ranked_cars
WHERE row_num <= 5;

-- create two views named AMT_Cars and Manual_Cars consisting the records of amt and manual cars respectively;
create or replace view AMT_Cars as select * from train_data where transmission='automatic';
create or replace view Manual_Cars as select * from train_data where transmission='manual';

select count(*) from AMT_Cars;
select count(*) from Manual_Carget_records1s;

-- query car brand, car name, fuel_type, owner_Type, location, car_age and price from train_data 
-- where car_age is greater than 15. order the output in ascending order of car age.
SELECT brand, name, fuel_type, owner_type, YEAR(CURDATE()) - year AS car_age, price
FROM train_data having car_age>15 order by car_age;