CREATE TABLE Main(RestaurantID INT,RestaurantName VARCHAR(255),CountryCode SMALLINT,City VARCHAR(100)
				,Address VARCHAR(255),Locality VARCHAR(100),LocalityVerbose VARCHAR(255),Longitude DECIMAL(12,9),Latitude DECIMAL(12,9)
                ,Cuisines VARCHAR(100),Currency VARCHAR(100),Has_Table_booking VARCHAR(100),Has_Online_delivery VARCHAR(100),Is_delivering_now VARCHAR(100),Switch_to_order_menu VARCHAR(100)
                ,Price_range TINYINT,Votes SMALLINT,Average_Cost_for_two bigint,Rating Decimal(4,2),Datekey_Opening DATE);

-- Q2 Build a Calendar Table using the Columns Datekey_Opening 
SELECT Datekey_Opening ,YEAR(Datekey_Opening) AS Opening_year
		,MONTH(Datekey_Opening) AS Opening_month_No
        ,MONTHNAME(Datekey_Opening) AS Opening_Month_Name
        ,CONCAT("Q",QUARTER(Datekey_Opening)) AS Opening_Quater
        ,WEEK(Datekey_Opening) AS Opening_week_no
        ,WEEKDAY(Datekey_Opening) AS Opening_week_Day
        ,DATE_FORMAT( Datekey_Opening , '%W' ) AS Opening_week_Day_Name -- ,DATE_FORMAT( Datekey_Opening , '%a' ) HALF NAME
		,DATE_FORMAT(Datekey_Opening, '%y-%b') AS Opening_year_month    -- DATE_FORMAT(date, '%d-%b-%y')
        ,CASE 
        WHEN MONTH(Datekey_Opening)>3 THEN CONCAT(YEAR(Datekey_Opening),"-",YEAR(Datekey_Opening)+1)
        ELSE CONCAT(YEAR(Datekey_Opening)-1,"-",YEAR(Datekey_Opening))
        END AS Financial_year
        ,CASE
        WHEN MONTH(Datekey_Opening)>=4 THEN CONCAT("FM-",MONTH(Datekey_Opening)-3)
        ELSE CONCAT("Fq-",MONTH(Datekey_Opening)+9)
        END  AS FISICAL_MONTH
        ,CASE 
        WHEN MONTH(Datekey_Opening) IN (4,5,6) THEN "FQ-1"
        WHEN MONTH(Datekey_Opening) IN (7,8,9) THEN "FQ-2"
        WHEN MONTH(Datekey_Opening) IN (10,11,12) THEN "FQ-3"
        ELSE "FQ-4"
        END AS FISICAL_QUATER
FROM main;
-- count of restaurent by country
 SELECT COUNT(m.RestaurantID),c.Countryname
 FROM main m
 LEFT OUTER JOIN csv_country c ON m.CountryCode=c.CountryID
 GROUP BY c.Countryname;
-- Q3 Convert the Average cost for 2 column into USD dollars (currently the Average cost for 2 in local currencies
SELECT Distinct Currency FROM main;
SELECT Distinct Currency FROM csv_currency;
SELECT m.RestaurantID,m.RestaurantName
		,CASE 
        WHEN m.Currency =cc.currency
        THEN CONCAT("$",m.Average_Cost_for_two*cc.USD_Rate )
        END AS USD_dollars
FROM main m
LEFT JOIN csv_currency cc ON m.Currency=cc.Currency;
-- Q4 Find the Numbers of Resturants based on City and Country.
SELECT m.RestaurantID,m.RestaurantName,m.Average_Cost_for_two/c.USD_RATE as US_dollar
FROM Main m
LEFT OUTER JOIN csv_currency c ON c.currency=m.currency
ORDER BY m.RestaurantID;
-- Q5 Numbers of Resturants opening based on Year , Quarter , Month
SELECT count(RestaurantID),YEAR(Datekey_Opening) AS Opening_year
		,CONCAT("Q",QUARTER(Datekey_Opening)) AS Opening_Quater
		,MONTHNAME(Datekey_Opening) AS Opening_Month_Name
FROM main m 
GROUP BY YEAR(Datekey_Opening) 
		,CONCAT("Q",QUARTER(Datekey_Opening)) 
		,MONTHNAME(Datekey_Opening) ;
-- Q6 Count of Resturants based on Average Ratings

select case when Rating <=1.5 then "0-1.5" when rating <=2 then "1.5-2" when rating <=2.5 then "2-2.5" when Rating<=3 then "2.5-3" when Rating<=3.5 then "3-3.5" when 
Rating<=4 then "3.5-4" when Rating<=4.5 then "4-4.5" when Rating<=5 then "4.5-5" end rating_range,count(RestaurantID) 
from main
group by Rating 
order by Rating;

-- Q7  Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
SELECT RestaurantID,RestaurantName,rating,Average_Cost_for_two
	,CASE
    WHEN Average_Cost_for_two BETWEEN 0 AND 10000 THEN "Cheapest"
    WHEN Average_Cost_for_two BETWEEN 10001 AND 50000 THEN "LOW COST"
    WHEN Average_Cost_for_two BETWEEN 10001 AND 50000 THEN "Moderate"
    WHEN Average_Cost_for_two BETWEEN 50001 AND 200000 THEN "pricey"
    WHEN Average_Cost_for_two BETWEEN 200001 AND 500000 THEN "exclusive"
    WHEN Average_Cost_for_two BETWEEN 500001 AND 1000000 THEN "high cost"
    END AS Bucket_list
FROM main;

-- Q8 Percentage of Resturants based on "Has_Table_booking"
 
 SELECT DISTINCT Has_Table_booking,CONCAT(ROUND((count(Has_Table_booking)/(SELECT count(RestaurantID) from main)*100),2),"%") as percent_restaurant
 FROM main
 GROUP BY Has_Table_booking;
 -- Q9 Percentage of Resturants based on "Has_Online_delivery"
  SELECT DISTINCT Has_Online_delivery,CONCAT(ROUND((count(Has_Online_delivery)/(SELECT count(RestaurantID) from main)*100),2),"%") as percent_restaurant
 FROM main
 GROUP BY Has_Online_delivery;