-- Find NULLs or empty strings
SELECT * FROM public.market
WHERE Invoice_ID IS NULL OR Invoice_ID = ''
   OR City IS NULL OR City = '';

DELETE FROM public.market
WHERE Invoice_ID IS NULL OR Invoice_ID = ''
   OR City IS NULL OR City = '';


   

select * from public.market

-- Daily Total Sales
SELECT date,SUM(total)as Daily_sales,
SUM(gross_income) as Daily_gross_income,
sum(cogs)as Daily_cogs
FROM public.market
group by date
order by date;




-- Monthly Sales Growth Rate (MoM)
WITH monthly_sales AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM') AS month, -- e.g., "2023-01"
        SUM(Total) AS Monthly_Sales
    FROM public.market
    GROUP BY month
)
SELECT
    month,
    Monthly_Sales,
    LAG(Monthly_Sales) OVER (ORDER BY month) AS Previous_Month_Sales,
    ROUND((Monthly_Sales - LAG(Monthly_Sales) OVER (ORDER BY month)) / LAG(Monthly_Sales) OVER (ORDER BY month) * 100, 2) AS MoM_Growth_Percentage
FROM monthly_sales;



-- Average Transaction Value (ATV) by Branch
SELECT branch,ROUND(AVG(total),3) as Avg_transaction_value
FROM public.market
group by branch


--Top-Selling Product Lines by Revenue
SELECT
    Product_Line,
    SUM(Total) AS Total_Revenue,
    SUM(Quantity) AS Total_Units_Sold
FROM public.market
GROUP BY Product_Line
ORDER BY Total_Revenue DESC;



-- Inventory Turnover (Assuming COGS is per product line)
SELECT
    Product_Line,
    count(COGS) AS Inventory_Turnover_Ratio
FROM public.market
GROUP BY Product_Line;

---- Revenue Contribution by City
SELECT
    City,
    SUM(Total) AS Total_Revenue,
    ROUND(SUM(Total) * 100.0 / (SELECT SUM(Total) FROM public.market), 2) AS Revenue_Contribution_Percentage
FROM public.market
GROUP BY City;


-- Branch Performance Comparison
SELECT
    Branch,
    City,
    SUM(Total) AS Total_Sales,
    SUM(Gross_Income) AS Total_Profit,
    ROUND(AVG(Rating), 2) AS Avg_Branch_Rating
FROM public.market
GROUP BY Branch, City;


-- Peak Shopping Hours
SELECT
    EXTRACT(HOUR FROM Time) AS Hour_of_Day,
    COUNT(Invoice_ID) AS Transaction_Count,
    SUM(Total) AS Hourly_Sales
FROM public.market
GROUP BY Hour_of_Day
ORDER BY Hour_of_Day;

-- Weekend vs. Weekday Sales
SELECT
    CASE
        WHEN EXTRACT(DOW FROM CAST(Date AS DATE)) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    SUM(Total) AS Total_Sales,
    AVG(Total) AS Avg_Sales_Per_Transaction
FROM public.market
GROUP BY 
    CASE
        WHEN EXTRACT(DOW FROM CAST(Date AS DATE)) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END;




-- Tax Collection Summary
SELECT
    City,
    SUM(Tax_5_percent) AS Total_Tax_Collected
FROM public.market
GROUP BY City;

-- Payment Method Preferences
SELECT
    Payment,
    COUNT(Invoice_ID) AS Transaction_Count,
    SUM(Total) AS Total_Revenue,
    ROUND(SUM(Total) * 100.0 / (SELECT SUM(Total) FROM public.market), 2) AS Payment_Method_Share
FROM public.market
GROUP BY Payment;
