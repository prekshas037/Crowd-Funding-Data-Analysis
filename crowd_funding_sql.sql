create database crowd_funding;
drop database crowd_funding;
CREATE TABLE crowd_funding (
    id BIGINT,
    state VARCHAR(50),
    name TEXT,
    country CHAR(2),
    creator_id BIGINT,
    location_id BIGINT,
    category_id BIGINT,
    created_date DATE,
    deadline_date DATE,
    updated_date DATE,
    state_changed_date DATE,
    successful_date DATE,
    launched_date DATE,
    goal BIGINT,
    static_usd_rate BIGINT,
    goal_usd BIGINT,
    pledged BIGINT,
    currency VARCHAR(10),
    usd_pledged BIGINT,
    backers_count INT,
    spotlight BOOLEAN,
    staff_pick BOOLEAN,
    Creator_name TEXT,
    Category_name VARCHAR(100),
    Category_parent_id BIGINT,
    Category_position INT,
    Location_displayable_name VARCHAR(200),
    Location_type VARCHAR(50),
    Location_name VARCHAR(100),
    Location_state VARCHAR(100),
    Location_short_name VARCHAR(100),
    Location_is_root VARCHAR(10),
    Location_country CHAR(2),
    Calendar_Date DATE,
    Calendar_Year INT,
    Calendar_Monthno INT,
    Calendar_Monthfullname VARCHAR(20),
    Calendar_Quarter VARCHAR(10),
    Calendar_YearMonth VARCHAR(20),
    Calendar_Weekdayno INT,
    Calendar_Weekdayname VARCHAR(20),
    Calendar_FinancialMonth VARCHAR(10),
    Calendar_FinancialQuarter VARCHAR(10)
);
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cf_sql.csv'
INTO TABLE crowd_funding 
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET sql_mode = '';

--  Total Raised USD
drop table total_raised_usd;
CREATE TABLE total_raised_usd AS
SELECT concat(round(SUM(usd_pledged/1000000000),2),"B") AS total_raised_usd
FROM crowd_funding;
select * from total_raised_usd;

--  Successfully Raised USD
CREATE TABLE successfully_raised_usd AS
SELECT concat(round(SUM(usd_pledged/1000000000),2),"B") AS successfully_raised_usd
FROM crowd_funding
WHERE state = 'successful';
select * from successfully_raised_usd; 

--  Total Backers
drop table total_backers;
CREATE TABLE total_backers AS
SELECT concat(round(sum(backers_count/1000000),2),"M") AS total_backers
FROM crowd_funding;
select * from total_backers;

--  Average Days (for successful projects)
CREATE TABLE avg_days_successful AS
SELECT AVG(DATEDIFF(deadline_date, launched_date)) AS avg_days_successful
FROM crowd_funding
WHERE state = 'successful';
select * from avg_days_successful;

--  Successful Projects
drop table successful_projects;
CREATE TABLE successful_projects AS
SELECT concat(round((COUNT(*)/1000),2),"K") AS successful_projects
FROM crowd_funding
WHERE state = 'successful';
select * from successful_projects;

--  5a. Total Projects by State
CREATE TABLE total_projects_by_state AS
SELECT state, COUNT(*) AS total_projects
FROM crowd_funding
GROUP BY state;
select * from total_projects_by_state;

-- 5b. Total Projects by Country    here
CREATE TABLE total_projects AS
SELECT country, COUNT(*) AS total_projects
FROM crowd_funding
GROUP BY country
ORDER BY total_projects DESC limit 10;

-- 5c. Total Projects by Name (Top 10)
CREATE TABLE total_projects_by_name AS
SELECT Category_name, COUNT(*) AS total_projects_by_name
FROM crowd_funding
GROUP BY Category_name
ORDER BY total_projects_by_name DESC
LIMIT 10;
select * from total_projects_by_name;


--  5d. Total Projects by Year, Quarter, Month
CREATE TABLE TotalProjects_by_yqm AS
SELECT YEAR(calendar_date) AS Year, QUARTER(calendar_date) AS Quarter, MONTH(calendar_Date) AS Month, COUNT(*) AS TotalProjects_by_yqm
FROM crowd_funding
GROUP BY YEAR(calendar_date),month(calendar_date), QUARTER(calendar_date)
ORDER BY TotalProjects_by_yqm desc limit 10;
select * from TotalProjects_by_yqm;

-- 7a Top Successful Projects Based on Number of Backers 
CREATE TABLE successful_backing_projects AS
SELECT name, backers_count AS successful_backing_projects
FROM crowd_funding
WHERE state = 'successful' order by backers_count desc limit 10;
select * from successful_backing_projects;

-- 7b Top Successful Projects  Based on Amount Raised. 
CREATE TABLE successful_projects_based_amount AS
SELECT name, concat(round((usd_pledged/1000000),2),"M") AS successful_projects_based_amount
FROM crowd_funding
WHERE state = 'successful' order by usd_pledged desc limit 10;
select * from successful_projects_based_amount;

-- 8a Percentage of Successful Projects overall 
CREATE TABLE SuccessRate AS
SELECT 
  concat(round((SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2),"%") AS SuccessRate
FROM crowd_funding;

-- 8b  Percentage of Successful Projects  by Category 
CREATE TABLE SuccessRate_Category AS
SELECT Category_name,
     concat(round((SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2),"%") AS SuccessRate_Category
FROM crowd_funding
GROUP BY Category_name
ORDER BY SuccessRate_Category desc limit 10;
select * from successrate_category;

-- 8c Percentage of Successful Projects by Year , Month 
create table SuccessRate_year as
SELECT YEAR(calendar_date) AS Year, MONTH(Calendar_date) AS Month,
       concat(round((SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2),"%") AS SuccessRate_year
FROM crowd_funding
GROUP BY YEAR(Calendar_date), MONTH(Calendar_date)
ORDER BY Year, Month desc limit 10;
select * from SuccessRate_year;


-- 8d Percentage of Successful projects by Goal Range 
 create table SuccessRate_goalrange as  
   SELECT 
    CASE 
        WHEN Goal_USD <= 1000 THEN '<= $1K'
        WHEN Goal_USD <= 10000 THEN '$1K - $10K'
        WHEN Goal_USD <= 100000 THEN '$10K - $100K'
        ELSE '$100K+'
    END AS GoalRange,
   concat(round( (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2),"%") AS SuccessRate_goalrange
FROM crowd_funding
GROUP BY 
    CASE 
        WHEN Goal_USD <= 1000 THEN '<= $1K'
        WHEN Goal_USD <= 10000 THEN '$1K - $10K'
        WHEN Goal_USD <= 100000 THEN '$10K - $100K'
        ELSE '$100K+'
    END
ORDER BY SuccessRate_goalrange DESC;
select * from successrate_goalrange;


   



