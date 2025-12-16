-----------------------------------------------------------------------------------------------------------------
-- SQL Code for Business Analytics Project:
-----------------------------------------------------------------------------------------------------------------

-- Create the complete country_data table and import from countries_data_clean_iso CSV
-- All Countries CSV was normalised and cleaned in python and ISO Codes were joined on country
-- pycountry was used to map ISO2 Codes to countries
CREATE TABLE country_data (
    country TEXT,
    country_long TEXT,
    currency TEXT,
    capital TEXT,
    region TEXT,
    continent TEXT,
    demonym TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    agricultural_land NUMERIC,
    forest_area NUMERIC,
    land_area NUMERIC,
    rural_land NUMERIC,
    urban_land NUMERIC,
    central_government_debt_pct_gdp NUMERIC,
    expense_pct_gdp NUMERIC,
    gdp NUMERIC,
    inflation NUMERIC,
    self_employed_pct NUMERIC,
    tax_revenue_pct_gdp NUMERIC,
    unemployment_pct NUMERIC,
    vulnerable_employment_pct NUMERIC,
    electricity_access_pct NUMERIC,
    alternative_nuclear_energy_pct NUMERIC,
    electricty_production_coal_pct NUMERIC,
    electricty_production_hydroelectric_pct NUMERIC,
    electricty_production_gas_pct NUMERIC,
    electricty_production_nuclear_pct NUMERIC,
    electricty_production_oil_pct NUMERIC,
    electricty_production_renewable_pct NUMERIC,
    energy_imports_pct NUMERIC,
    fossil_energy_consumption_pct NUMERIC,
    renewable_energy_consumption_pct NUMERIC,
    co2_emissions NUMERIC,
    methane_emissions NUMERIC,
    nitrous_oxide_emissions NUMERIC,
    greenhouse_other_emissions NUMERIC,
    urban_population_under_5m NUMERIC,
    health_expenditure_pct_gdp NUMERIC,
    health_expenditure_capita NUMERIC,
    hospital_beds NUMERIC,
    hiv_incidence NUMERIC,
    suicide_rate NUMERIC,
    armed_forces NUMERIC,
    internally_displaced_persons NUMERIC,
    military_expenditure_pct_gdp NUMERIC,
    birth_rate NUMERIC,
    death_rate NUMERIC,
    fertility_rate NUMERIC,
    internet_pct NUMERIC,
    life_expectancy NUMERIC,
    net_migration NUMERIC,
    population_female NUMERIC,
    population_male NUMERIC,
    population NUMERIC,
    women_parliament_seats_pct NUMERIC,
    rural_population NUMERIC,
    urban_population NUMERIC,
    press NUMERIC,
    democracy_score NUMERIC,
    democracy_type TEXT,
    median_age NUMERIC,
    political_leader TEXT,
    title TEXT,
    iso_code TEXT
);

-- Quick review that the data imported correctly
SELECT COUNT(*) FROM country_data;

-- Review that there are no duplicates in the iso_code column, to be used as the Primary Key
SELECT iso_code, COUNT(*) 
FROM country_data 
GROUP BY iso_code
HAVING COUNT(*) > 1 OR iso_code IS NULL;
-- No duplicates

-- Make iso_code the Primary Key (ISO2)
ALTER TABLE country_data
  ALTER COLUMN iso_code TYPE CHAR(2) USING TRIM(iso_code)::CHAR(2),
  ALTER COLUMN iso_code SET NOT NULL;

ALTER TABLE country_data
ADD CONSTRAINT country_data_pkey PRIMARY KEY (iso_code);
-- ISO2 Codes to be used as the primary key to link the tables

-----------------------------------------------------------------------------------------------------------------
-- Make the complete table the staging table
-----------------------------------------------------------------------------------------------------------------

-- Rename to staging
ALTER TABLE country_data RENAME TO country_data_staging;

-- Correct the spelling error in the column names for electricity production
ALTER TABLE country_data_staging RENAME COLUMN electricty_production_coal_pct          TO electricity_production_coal_pct;
ALTER TABLE country_data_staging RENAME COLUMN electricty_production_hydroelectric_pct TO electricity_production_hydroelectric_pct;
ALTER TABLE country_data_staging RENAME COLUMN electricty_production_gas_pct           TO electricity_production_gas_pct;
ALTER TABLE country_data_staging RENAME COLUMN electricty_production_nuclear_pct       TO electricity_production_nuclear_pct;
ALTER TABLE country_data_staging RENAME COLUMN electricty_production_oil_pct           TO electricity_production_oil_pct;
ALTER TABLE country_data_staging RENAME COLUMN electricty_production_renewable_pct     TO electricity_production_renewable_pct;

-----------------------------------------------------------------------------------------------------------------
-- Create the individual tables that will be populated from staging
-----------------------------------------------------------------------------------------------------------------

-- Countries Table
CREATE TABLE countries (
  iso_code CHAR(2) PRIMARY KEY,
  country TEXT NOT NULL,
  country_long TEXT,
  capital TEXT,
  region TEXT,
  continent TEXT,
  demonym TEXT,
  latitude NUMERIC,
  longitude NUMERIC
);

-- Land Use Table
CREATE TABLE land_use (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  agricultural_land NUMERIC,
  forest_area NUMERIC,
  land_area NUMERIC,
  rural_land NUMERIC,
  urban_land NUMERIC
);

-- Economy Table
CREATE TABLE economy (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  gdp NUMERIC,
  inflation NUMERIC,
  tax_revenue_pct_gdp NUMERIC,
  expense_pct_gdp NUMERIC,
  central_government_debt_pct_gdp NUMERIC,
  unemployment_pct NUMERIC,
  self_employed_pct NUMERIC,
  vulnerable_employment_pct NUMERIC
);

-- Energy & Emissions Table
CREATE TABLE energy (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  electricity_access_pct NUMERIC,
  alternative_nuclear_energy_pct NUMERIC,
  electricity_production_coal_pct NUMERIC,
  electricity_production_hydroelectric_pct NUMERIC,
  electricity_production_gas_pct NUMERIC,
  electricity_production_nuclear_pct NUMERIC,
  electricity_production_oil_pct NUMERIC,
  electricity_production_renewable_pct NUMERIC,
  energy_imports_pct NUMERIC,
  fossil_energy_consumption_pct NUMERIC,
  renewable_energy_consumption_pct NUMERIC,
  co2_emissions NUMERIC,
  methane_emissions NUMERIC,
  nitrous_oxide_emissions NUMERIC,
  greenhouse_other_emissions NUMERIC
);

-- Population & Demographics Table
CREATE TABLE population (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  population NUMERIC,
  population_female NUMERIC,
  population_male NUMERIC,
  urban_population NUMERIC,
  rural_population NUMERIC,
  urban_population_under_5m NUMERIC,
  birth_rate NUMERIC,
  death_rate NUMERIC,
  fertility_rate NUMERIC,
  median_age NUMERIC,
  life_expectancy NUMERIC,
  net_migration NUMERIC,
  women_parliament_seats_pct NUMERIC
);

-- Health Table
CREATE TABLE health (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  health_expenditure_pct_gdp NUMERIC,
  health_expenditure_capita NUMERIC,
  hospital_beds NUMERIC,
  hiv_incidence NUMERIC,
  suicide_rate NUMERIC
);

-- Governance Table
CREATE TABLE governance (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  press NUMERIC,
  democracy_score NUMERIC,
  democracy_type TEXT,
  political_leader TEXT,
  title TEXT
);

-- Security Table
CREATE TABLE security (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  armed_forces NUMERIC,
  internally_displaced_persons NUMERIC,
  military_expenditure_pct_gdp NUMERIC
);

-- ICT Table
CREATE TABLE ict (
  iso_code CHAR(2) PRIMARY KEY REFERENCES countries(iso_code) ON DELETE CASCADE,
  internet_pct NUMERIC
);

-----------------------------------------------------------------------------------------------------------------
-- Populate the individual tabled by inserting data from staging table
-----------------------------------------------------------------------------------------------------------------

-- Countries Table
INSERT INTO countries (iso_code, country, country_long, capital, region, continent, demonym, latitude, longitude)
SELECT DISTINCT iso_code, country, country_long, capital, region, continent, demonym, latitude, longitude
FROM country_data_staging;

-- Land Use Table
INSERT INTO land_use
SELECT iso_code, agricultural_land, forest_area, land_area, rural_land, urban_land
FROM country_data_staging;

-- Economy Table
INSERT INTO economy
SELECT iso_code, gdp, inflation, tax_revenue_pct_gdp, expense_pct_gdp,
       central_government_debt_pct_gdp, unemployment_pct, self_employed_pct, vulnerable_employment_pct
FROM country_data_staging;

-- Energy & Emissions Table
INSERT INTO energy
SELECT iso_code, electricity_access_pct, alternative_nuclear_energy_pct,
       electricity_production_coal_pct, electricity_production_hydroelectric_pct,
       electricity_production_gas_pct, electricity_production_nuclear_pct,
       electricity_production_oil_pct, electricity_production_renewable_pct,
       energy_imports_pct, fossil_energy_consumption_pct, renewable_energy_consumption_pct,
       co2_emissions, methane_emissions, nitrous_oxide_emissions, greenhouse_other_emissions
FROM country_data_staging;

-- Population & Demographics Table
INSERT INTO population
SELECT iso_code, population, population_female, population_male, urban_population, rural_population,
       urban_population_under_5m, birth_rate, death_rate, fertility_rate, median_age,
       life_expectancy, net_migration, women_parliament_seats_pct
FROM country_data_staging;

-- Health Table
INSERT INTO health
SELECT iso_code, health_expenditure_pct_gdp, health_expenditure_capita, hospital_beds, hiv_incidence, suicide_rate
FROM country_data_staging;

-- Governance Table
INSERT INTO governance
SELECT iso_code, press, democracy_score, democracy_type, political_leader, title
FROM country_data_staging;

-- Security Table
INSERT INTO security
SELECT iso_code, armed_forces, internally_displaced_persons, military_expenditure_pct_gdp
FROM country_data_staging;

-- ICT Table
INSERT INTO ict
SELECT iso_code, internet_pct
FROM country_data_staging;

-- Review that the data was inserted correctly by verifying the counts
SELECT 'countries', COUNT(*) FROM countries
UNION ALL SELECT 'economy', COUNT(*) FROM economy
UNION ALL SELECT 'energy', COUNT(*) FROM energy
UNION ALL SELECT 'land_use', COUNT(*) FROM land_use
UNION ALL SELECT 'population', COUNT(*) FROM population
UNION ALL SELECT 'health', COUNT(*) FROM health
UNION ALL SELECT 'governance', COUNT(*) FROM governance
UNION ALL SELECT 'security', COUNT(*) FROM security
UNION ALL SELECT 'ict', COUNT(*) FROM ict;
-- Data from the staging table was inserted correctly

-----------------------------------------------------------------------------------------------------------------
-- After review it was determined that gdp in the economy table had to be replaced with a more reliable dataset
-----------------------------------------------------------------------------------------------------------------

-- Drop the current gdp column
ALTER TABLE economy DROP COLUMN gdp;

-- Create the staging table for the new gdp data and import from gdp_clean_iso
-- 2020-2025 CSV was normalised and cleaned in python and ISO Codes were joined on country
-- pycountry was used to map ISO2 Codes to countries
CREATE TABLE gdp_forecast_staging (
  iso_code CHAR(2) PRIMARY KEY,
  gdp_2024 NUMERIC,
  gdp_2025 NUMERIC
);

-- Add the new gdp columns in the economy table
ALTER TABLE economy
  ADD COLUMN gdp_2024 NUMERIC,
  ADD COLUMN gdp_2025 NUMERIC,
  ADD COLUMN gdp_growth NUMERIC;

-- Update the newly created gdp tables and populate from the staging table
UPDATE economy e
SET gdp_2024 = f.gdp_2024,
    gdp_2025 = f.gdp_2025,
-- Calculate growth between 2024 and 2025, update gdp_growth column, key metric to be used for analysis
    gdp_growth = CASE 
                   WHEN f.gdp_2024 IS NOT NULL AND f.gdp_2024 <> 0
                   THEN ((f.gdp_2025 - f.gdp_2024) / f.gdp_2024) * 100
                   ELSE NULL
                 END
FROM gdp_forecast_staging f
WHERE e.iso_code = f.iso_code;

-----------------------------------------------------------------------------------------------------------------
-- Dealing with Nulls:
-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Countries Table
SELECT
  SUM((country_long IS NULL)::int) 	AS country_long_nulls,
  SUM((capital IS NULL)::int) 		AS capital_nulls,
  SUM((region IS NULL)::int) 		AS region_nulls,
  SUM((continent IS NULL)::int) 	AS continent_nulls,
  SUM((demonym IS NULL)::int) 		AS demonym_nulls,
  SUM((latitude IS NULL)::int) 		AS latitude_nulls,
  SUM((longitude IS NULL)::int) 	AS longitude_nulls
FROM countries;
-- No Nulls

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Economy Table
SELECT
  SUM((gdp_2024 IS NULL)::int)                        	AS gdp_2024_nulls,
  SUM((gdp_2025 IS NULL)::int)                        	AS gdp_2025_nulls,
  SUM((inflation IS NULL)::int)                  		AS inflation_nulls,
  SUM((tax_revenue_pct_gdp IS NULL)::int)        		AS tax_rev_nulls,
  SUM((expense_pct_gdp IS NULL)::int)            		AS expense_nulls,
  SUM((central_government_debt_pct_gdp IS NULL)::int) 	AS debt_nulls,
  SUM((unemployment_pct IS NULL)::int)           		AS unemployment_nulls,
  SUM((self_employed_pct IS NULL)::int)          		AS self_emp_nulls,
  SUM((vulnerable_employment_pct IS NULL)::int) 		AS vuln_emp_nulls
FROM economy;
-- Nulls in each column

-- Step 1: Check for missing GDP data
SELECT c.iso_code, c.country_long, e.gdp_2024, e.gdp_2025
FROM countries c
LEFT JOIN economy e USING (iso_code)
WHERE e.gdp_2024 IS NULL OR e.gdp_2025 IS NULL
ORDER BY c.country_long;
-- Null ISO Codes: KP, LK, PK, AF, LB, LI, MC, CU, ER, SY, PS

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Energy Table
SELECT
  SUM((electricity_access_pct IS NULL)::int)                	AS electricity_access_nulls,
  SUM((alternative_nuclear_energy_pct IS NULL)::int)        	AS alt_nuclear_energy_nulls,
  SUM((electricity_production_coal_pct IS NULL)::int)       	AS prod_coal_nulls,
  SUM((electricity_production_hydroelectric_pct IS NULL)::int) 	AS prod_hydroelectric_nulls,
  SUM((electricity_production_gas_pct IS NULL)::int)        	AS prod_gas_nulls,
  SUM((electricity_production_nuclear_pct IS NULL)::int)    	AS prod_nuclear_nulls,
  SUM((electricity_production_oil_pct IS NULL)::int)        	AS prod_oil_nulls,
  SUM((electricity_production_renewable_pct IS NULL)::int)  	AS prod_renewable_nulls,
  SUM((energy_imports_pct IS NULL)::int)                    	AS energy_imports_nulls,
  SUM((fossil_energy_consumption_pct IS NULL)::int)         	AS fossil_consumption_nulls,
  SUM((renewable_energy_consumption_pct IS NULL)::int)      	AS renewable_consumption_nulls,
  SUM((co2_emissions IS NULL)::int)                         	AS co2_nulls,
  SUM((methane_emissions IS NULL)::int)                    		AS methane_nulls,
  SUM((nitrous_oxide_emissions IS NULL)::int)               	AS nitrous_oxide_nulls,
  SUM((greenhouse_other_emissions IS NULL)::int)            	AS ghg_other_nulls
FROM energy;
-- Nulls in 14 columns
-- No nulls in electricity_access_pct, a key metric that will be used for analysis, other columns won't be used

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Governance Table
SELECT
  SUM((press IS NULL)::int)            AS press_nulls,
  SUM((democracy_score IS NULL)::int)  AS democracy_score_nulls,
  SUM((democracy_type IS NULL)::int)   AS democracy_type_nulls,
  SUM((political_leader IS NULL)::int) AS political_leader_nulls,
  SUM((title IS NULL)::int)            AS title_nulls
FROM governance;
-- Nulls in 2 columns, political_leader and title, neither will be used for analysis

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Health Table
SELECT
  SUM((health_expenditure_pct_gdp IS NULL)::int) AS health_exp_pct_gdp_nulls,
  SUM((health_expenditure_capita  IS NULL)::int) AS health_exp_capita_nulls,
  SUM((hospital_beds IS NULL)::int)				 AS hospital_beds_nulls,
  SUM((hiv_incidence IS NULL)::int) 			 AS hiv_incidence_nulls,
  SUM((suicide_rate IS NULL)::int) 				 AS suicide_rate_nulls
FROM health;
-- Nulls in each column, won't be used for analysis of the selected business scenario

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for ICT Table
SELECT
  SUM((internet_pct IS NULL)::int) AS internet_pct_nulls
FROM ict;
-- No nulls in internet_pct, a key metric that will be used for analysis

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Land Use Table
SELECT
  SUM((agricultural_land IS NULL)::int) AS agricultural_land_nulls,
  SUM((forest_area IS NULL)::int) 		AS forest_area_nulls,
  SUM((land_area IS NULL)::int) 		AS land_area_nulls,
  SUM((rural_land IS NULL)::int) 		AS rural_land_nulls,
  SUM((urban_land IS NULL)::int) 		AS urban_land_nulls
FROM land_use;
-- Null in 1 column
-- Large overlap between the areas, agricultural_land + forest_area + rural_land + urban_land != land_area
-- No nulls in urban_land, a key metric that will be used for analysis

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Population Table
SELECT
  SUM((population IS NULL)::int)                   AS population_nulls,
  SUM((population_female IS NULL)::int)            AS population_female_nulls,
  SUM((population_male IS NULL)::int)              AS population_male_nulls,
  SUM((urban_population IS NULL)::int)             AS urban_population_nulls,
  SUM((rural_population IS NULL)::int)             AS rural_population_nulls,
  SUM((urban_population_under_5m IS NULL)::int)    AS urban_pop_under_5m_nulls,
  SUM((birth_rate IS NULL)::int)                   AS birth_rate_nulls,
  SUM((death_rate IS NULL)::int)                   AS death_rate_nulls,
  SUM((fertility_rate IS NULL)::int)               AS fertility_rate_nulls,
  SUM((median_age IS NULL)::int)                   AS median_age_nulls,
  SUM((life_expectancy IS NULL)::int)              AS life_expectancy_nulls,
  SUM((net_migration IS NULL)::int)                AS net_migration_nulls,
  SUM((women_parliament_seats_pct IS NULL)::int)   AS women_parl_seats_nulls
FROM population;
-- Nulls in 3 columns
-- No nulls in population, a key metric that will be used for analysis and constructing land_use variables

-----------------------------------------------------------------------------------------------------------------

-- Null counts by column for Security Table
SELECT
  SUM((armed_forces IS NULL)::int)                 AS armed_forces_nulls,
  SUM((internally_displaced_persons IS NULL)::int) AS idp_nulls,
  SUM((military_expenditure_pct_gdp IS NULL)::int) AS mil_exp_pct_gdp_nulls
FROM security;
-- Nulls in each column, won't be used for analysis of the selected business scenario

-----------------------------------------------------------------------------------------------------------------
-- Metric Construction & Analysis:
-- Business scenario will consider countries in Africa
-----------------------------------------------------------------------------------------------------------------

-- GDP per Capita Creation & Country Selection:

-- Create the GDP per Capita column in the Economy Table
ALTER TABLE economy
ADD COLUMN gdp_per_capita NUMERIC;

-- Populate the GDP per Capita column using GDP / Population
UPDATE economy e
SET gdp_per_capita = (e.gdp_2025 * 1e6) / NULLIF(p.population, 0) -- gdp_2024 and gdp_2025 entries are stored in millions USD, scale up to improve readability
FROM population p
WHERE e.iso_code = p.iso_code;

-- Review which entry is null in gdp_per_capita as it is a key metric for our analysis
SELECT e.iso_code, c.country, c.region, e.gdp_per_capita
FROM economy e
JOIN countries c USING (iso_code)
WHERE e.gdp_per_capita IS NULL;
-- Null ISO Codes: AF, LK, PK, LB, MC, LI, ER, KP, CU, SY, PS
-- Imputation by using region means was attempted but values were heavily influenced by significantly wealthier countries in the same region
-- Countries with null gdp values are thus not to be considered

-- Steps 2-4:
-- Screen African countries by combined criteria (GDP per capita, electricity, internet)
-- Criteria:
--   - Continent = Africa
--   - GDP per capita >= 4000 USD
--   - Electricity access >= 95%
--   - Internet access >= 65%
-- Resulting set will be used for further unemployment, inflation, and land-use analysis.
WITH base AS (
  SELECT
    c.iso_code,
    c.country_long,
    c.continent,
    c.region,
    e.gdp_growth,
    e.gdp_per_capita,
    e.inflation,
    e.unemployment_pct,
    en.electricity_access_pct,
    i.internet_pct
  FROM countries c
  JOIN economy e USING (iso_code)
  JOIN energy en USING (iso_code)
  JOIN ict i  	 USING (iso_code)
  WHERE c.continent = 'Africa'
),
screened AS (
  SELECT *
  FROM base
  WHERE gdp_per_capita IS NOT NULL
    AND gdp_per_capita >= 4000
    AND electricity_access_pct >= 95
    AND internet_pct >= 65
)
SELECT
  iso_code,
  country_long AS country,
  region,
  ROUND(gdp_growth, 2)            AS gdp_growth_pct,
  ROUND(gdp_per_capita, 2)        AS gdp_per_capita_usd,
  ROUND(inflation, 2)             AS inflation_pct,
  ROUND(unemployment_pct, 2)      AS unemployment_pct,
  ROUND(electricity_access_pct,2) AS electricity_access_pct,
  ROUND(internet_pct, 2)          AS internet_pct
FROM screened
ORDER BY ROUND(gdp_growth, 2) DESC, ROUND(gdp_per_capita, 2) DESC;
-- Shortlisted Countries: MA, TN, MU, CV, DZ, SC
-- Countries were shortlisted on the basis of GDP Growth, GDP per Capita, inflation, unemployment, Electricity Access, Internet Access

--Step 5: Unemployment Analysis (Shortlisted countries from step 4)
WITH shortlisted(iso_code) AS (
  VALUES ('MA'), ('TN'), ('MU'), ('CV'), ('DZ'), ('SC')
)
SELECT 
  c.iso_code,
  c.country_long              AS country,
  ROUND(e.gdp_per_capita, 2)  AS gdp_per_capita,
  ROUND(e.unemployment_pct,2) AS unemployment_pct,
  ROUND(e.inflation,2)        AS inflation
FROM shortlisted
JOIN economy e 	 USING (iso_code)
JOIN countries c USING (iso_code)
WHERE e.gdp_per_capita IS NOT NULL
ORDER BY e.gdp_per_capita DESC;

-----------------------------------------------------------------------------------------------------------------

-- Create the new metrics for urban land per capita and urban density:

-- Add the urban_land_per_capita and urban_density_proxy columns to the land_use table
ALTER TABLE land_use
  ADD COLUMN urban_land_per_capita NUMERIC,
  ADD COLUMN urban_density_proxy NUMERIC;

-- Updated the urban_land_per_capita column by computing
UPDATE land_use lu
SET urban_land_per_capita = ROUND((COALESCE(urban_land,0) * 1.0) / NULLIF(p.population,0), 6)
FROM population p
WHERE lu.iso_code = p.iso_code;

-- Updated the urban_density_proxy column by computing
UPDATE land_use lu
SET urban_density_proxy = ROUND((p.population * 1.0) / NULLIF(urban_land,0), 2)
FROM population p
WHERE lu.iso_code = p.iso_code;

-- Step 6: Land Use Analysis – Urban & Population (Shortlisted countries)
-- Review that the columns were updated correctly and review shortlisted African countries
WITH shortlisted(iso_code) AS (
  VALUES ('MA'), ('TN'), ('MU'), ('CV'), ('DZ'), ('SC')
)
SELECT 
  lu.iso_code                               AS "ISO2 Code",
  c.country_long                            AS "Country Name",
  c.region                                  AS "Region",
  ROUND(e.gdp_growth, 2)                    AS "GDP Growth",
  p.population                              AS "Population",
  lu.urban_land                             AS "Urban Land",
  ROUND(lu.urban_land_per_capita * 1e6, 1)  AS "Urban m² per Person", -- Scale to m² to improve readibility
  ROUND(lu.urban_density_proxy, 2)          AS "Urban People per km²"
FROM shortlisted
JOIN land_use   lu USING (iso_code)
JOIN countries  c  USING (iso_code)
JOIN population p  USING (iso_code)
JOIN economy    e  USING (iso_code)
ORDER BY lu.urban_density_proxy DESC;

-- Master view of shortlisted African countries (final selection)
WITH shortlisted(iso_code) AS (
  VALUES ('MA'), ('TN'), ('MU'), ('CV'), ('DZ'), ('SC')
)
SELECT
  c.iso_code                               AS "ISO2 Code",
  c.country_long                           AS "Country",
  c.capital                                AS "Capital City",
  c.region                                 AS "Region",
  ROUND(e.gdp_2024, 2)                     AS "GDP 2024 (USD M)",
  ROUND(e.gdp_2025, 2)                     AS "GDP 2025 (USD M)",
  ROUND(e.gdp_growth, 2)                   AS "GDP Growth (%)",
  ROUND(e.gdp_per_capita, 2)               AS "GDP per Capita",
  ROUND(e.inflation, 2)                    AS "Inflation (%)",
  ROUND(e.unemployment_pct, 2)             AS "Unemployment (%)",
  ROUND(en.electricity_access_pct, 2)      AS "Electricity Access (%)",
  ROUND(i.internet_pct, 2)                 AS "Internet Access (%)",
  ROUND(l.urban_land_per_capita * 1e6, 1)  AS "Urban m² per Person", -- Scale to m² for readability
  ROUND(l.urban_density_proxy, 1)          AS "Urban People per km²"
FROM shortlisted
JOIN countries c  		USING (iso_code)
LEFT JOIN economy e  	USING (iso_code)
LEFT JOIN energy en 	USING (iso_code)
LEFT JOIN governance g  USING (iso_code)
LEFT JOIN ict i  		USING (iso_code)
LEFT JOIN land_use l  	USING (iso_code)
LEFT JOIN population p  USING (iso_code)
ORDER BY c.region, c.country_long;
-- Selected Countries: MU, TN, MA
-- Countries were selected on the basis of: 
-- GDP Growth, GDP per Capita, Inflation, Unemployment, Electricity Access, Internet Access, urban_density_proxy, urban_land_per_capita

-----------------------------------------------------------------------------------------------------------------
-- Compile data for Master View & Plotting
-----------------------------------------------------------------------------------------------------------------

-- Select the data for master view of selected countries, save as Selected Countries Master View CSV
WITH shortlisted(iso_code) AS (
  VALUES ('MU'), ('TN'), ('MA')
)
SELECT
  c.iso_code                               AS "ISO2 Code",
  c.country_long                           AS "Country",
  c.capital                                AS "Capital City",
  c.region                                 AS "Region",
  ROUND(e.gdp_2024, 2)                     AS "GDP 2024 (USD M)",
  ROUND(e.gdp_2025, 2)                     AS "GDP 2025 (USD M)",
  ROUND(e.gdp_growth, 2)                   AS "GDP Growth (%)",
  ROUND(e.gdp_per_capita, 2)               AS "GDP per Capita",
  ROUND(e.inflation, 2)                    AS "Inflation (%)",
  ROUND(e.unemployment_pct, 2)             AS "Unemployment (%)",
  ROUND(en.electricity_access_pct, 2)      AS "Electricity Access (%)",
  ROUND(i.internet_pct, 2)                 AS "Internet Access (%)",
  ROUND(l.urban_land_per_capita * 1e6, 1)  AS "Urban m² per Person", -- Scale to m² for readability
  ROUND(l.urban_density_proxy, 1)          AS "Urban People per km²"
FROM shortlisted
JOIN countries  c  		USING (iso_code)
LEFT JOIN economy e  	USING (iso_code)
LEFT JOIN energy en 	USING (iso_code)
LEFT JOIN governance g  USING (iso_code)
LEFT JOIN ict i  		USING (iso_code)
LEFT JOIN land_use l  	USING (iso_code)
LEFT JOIN population p  USING (iso_code)
ORDER BY c.region, c.country_long;

-- Select the data for the master view, save as Master View CSV
SELECT
    c.iso_code                           	AS "ISO2 Code",
    c.country_long                       	AS "Country",
    c.capital                            	AS "Capital City",
    c.region                             	AS "Region",
    ROUND(e.gdp_2024, 2)                 	AS "GDP 2024 (USD M)",
    ROUND(e.gdp_2025, 2)                 	AS "GDP 2025 (USD M)",
    ROUND(e.gdp_growth, 2)               	AS "GDP Growth (%)",
    ROUND(e.gdp_per_capita, 2)           	AS "GDP per Capita",
    ROUND(e.inflation, 2)                	AS "Inflation (%)",
    ROUND(e.unemployment_pct, 2)         	AS "Unemployment (%)",
    ROUND(en.electricity_access_pct, 2)  	AS "Electricity Access (%)",
    ROUND(i.internet_pct, 2)             	AS "Internet Access (%)",
    ROUND(l.urban_land_per_capita * 1e6, 1) AS "Urban m² per Person", -- Scale to m² to improve readibility
    ROUND(l.urban_density_proxy, 1)        	AS "Urban People per km²"
FROM countries c
LEFT JOIN economy    e  USING (iso_code)
LEFT JOIN energy     en USING (iso_code)
LEFT JOIN governance g  USING (iso_code)
LEFT JOIN ict        i  USING (iso_code)
LEFT JOIN land_use   l  USING (iso_code)
LEFT JOIN population p  USING (iso_code)
ORDER BY c.region, c.country_long;

-- Select the data for plotting in python, save as plotting CSV
SELECT
    c.iso_code,
	c.country,
    c.country_long,
    c.capital,
    c.region,
    c.latitude,
    c.longitude,
    ROUND(e.gdp_2024, 2)                   	AS gdp_2024_usd_m,
    ROUND(e.gdp_2025, 2)                   	AS gdp_2025_usd_m,
    ROUND(e.gdp_growth, 2)                 	AS gdp_growth_pct,
    ROUND(e.gdp_per_capita, 2)             	AS gdp_per_capita,
    ROUND(e.inflation, 2)                  	AS inflation_pct,
    ROUND(e.unemployment_pct, 2)           	AS unemployment_pct,
    ROUND(en.electricity_access_pct, 2)    	AS electricity_access_pct,
    ROUND(g.democracy_score, 2)            	AS democracy_score,
    g.democracy_type                       	AS democracy_type,
    ROUND(i.internet_pct, 2)               	AS internet_access_pct,
    ROUND(l.urban_land_per_capita * 1e6, 1) AS urban_m2_per_person,
    ROUND(l.urban_density_proxy, 1)        	AS urban_people_per_km2
FROM countries c
LEFT JOIN economy    e  USING (iso_code)
LEFT JOIN energy     en USING (iso_code)
LEFT JOIN governance g  USING (iso_code)
LEFT JOIN ict        i  USING (iso_code)
LEFT JOIN land_use   l  USING (iso_code)
LEFT JOIN population p  USING (iso_code)
ORDER BY c.region, c.country_long;

-----------------------------------------------------------------------------------------------------------------