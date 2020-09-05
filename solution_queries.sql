--How many distinct zip codes are in this dataset?

SELECT 
	COUNT(DISTINCT zip_code) 'Number of Zip Codes'
FROM home_value_data;


--How many zip codes are from each state?

SELECT 
	state State,
	COUNT(DISTINCT zip_code) 'Number of Zip Codes'
FROM home_value_data
GROUP BY 1;


--What range of years are represented in the data?


SELECT
	MIN(substr(date,1,4)) 'Start Year',
	MAX(substr(date,1,4)) 'End Year'
FROM home_value_data;


--Using the most recent month of data available, what is the range of estimated home values across the nation?

SELECT 
	MIN(value) 'Minimum Value',
	MAX(value) 'Maximum Value'
FROM home_value_data
WHERE date = (SELECT MAX(date) FROM home_value_data);


--Using the most recent month of data available, which states have the highest average home values? How about the lowest?

SELECT 
	state State,
	CAST(AVG(value) AS INT) 'Average Value'
FROM home_value_data
WHERE date = (SELECT MAX(date) FROM home_value_data)
GROUP BY 1
ORDER BY 2 DESC;


--Which states have the highest/lowest average home values for the year of 2017? What about for the year of 2007? 1997?

WITH state_val AS(
	SELECT	
		substr(date,1,4) year,
		state,
		CAST(ROUND(AVG(value),0) AS INT) average
	FROM home_value_data
	WHERE year = '1997' --Change this value for different years
	GROUP BY 2,1
)
SELECT
	year,
	
	(SELECT
		state
	FROM state_val
	WHERE average = (SELECT MIN(average) FROM state_val GROUP BY year)
	) 'Min State',
	
	MIN(average) 'Minimum Value',
	
	(SELECT	
		state
	FROM state_val
	WHERE average = (SELECT MAX(average)FROM state_val GROUP BY year)
	) 'Max State',
	
	MAX(average) 'Maximum Value'
	
FROM state_val
GROUP BY 1;


--What is the percent change in average home values from 2007 to 2017 by state? How about from 1997 to 2017?

WITH new_val AS(
	SELECT	
		substr(date,1,4) year,
		state,
		ROUND(AVG(value),2) AS average
	FROM home_value_data
	WHERE year = '2017'
	GROUP BY 2,1
),
	old_val1 AS(
	SELECT	
		substr(date,1,4) year,
		state,
		ROUND(AVG(value),2) AS average
	FROM home_value_data
	WHERE year = '2007'
	GROUP BY 2,1
),
	old_val2 AS(
	SELECT	
		substr(date,1,4) year,
		state,
		ROUND(AVG(value),2) AS average
	FROM home_value_data
	WHERE year = '1997'
	GROUP BY 2,1
)

SELECT 
	new_val.state,
	old_val2.average '1997 Average',
	old_val1.average '2007 Average',
	new_val.average '2017 Average',
	ROUND((100.0 * (new_val.average - old_val1.average) / old_val1.average),2) AS '% Change 2007-2017',
	ROUND((100.0 * (new_val.average - old_val2.average) / old_val2.average),2) AS '% Change 1997-2017'
FROM new_val
JOIN old_val1
	ON new_val.state = old_val1.state
JOIN old_val2
	ON old_val1.state = old_val2.state
ORDER BY 5 DESC;

--How would you describe the trend in home values for each state from 1997 to 2017? How about from 2007 to 2017? 
--Which states would you recommend for making real estate investments?
	
-- Order results by % changes in the last query you can find the highest growing real estate markets.

--From this query I would suggest ND, DC, SD, TX, or CO, depending on how much you have to invest and how quickly you'd like to make a return on your investment.

--Join the house value data with the table of zip-code level census data. 
--Do there seem to be any correlations between the estimated house values and characteristics of the area, such as population count or median household income?

WITH zip_val AS(
	SELECT	
		substr(date,1,4) year,
		zip_code,
		CAST(ROUND(AVG(value),0) AS INT) average
	FROM home_value_data
	GROUP BY 2,1
)
	
SELECT zv.year,
	zv.zip_code,
	zv.average,
	cd.pop_total,
	cd.median_household_income
FROM zip_val zv
JOIN census_data cd
	ON zv.zip_code = cd.zip_code
WHERE year = '2017' AND cd.median_household_income != 'NULL'
ORDER BY cd.pop_total; --Change to median_household_income to study that correlation
