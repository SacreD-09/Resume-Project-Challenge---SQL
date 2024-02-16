-- 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
SELECT DISTINCT
    Market
FROM
    gdb023.dim_customer
WHERE
    region = 'APAC'
        AND customer = 'Atliq Exclusive';

Explanation

    SELECT DISTINCT Market: This part of the query specifies that we want to select unique values from the "Market" column.
    FROM gdb023.dim_customer: This specifies the table from which we are retrieving data, which is "dim_customer" in the "gdb023" database.
    WHERE region = 'APAC' AND customer = 'Atliq Exclusive': This condition filters the results to only include records where the region is "APAC" and the customer is "Atliq Exclusive".

-- 2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields

SELECT 
    COUNT(DISTINCT CASE
            WHEN year_manufactured = 2020 THEN products
            ELSE NULL
        END) AS unique_products_2020,
    COUNT(DISTINCT CASE
            WHEN year_manufactured = 2021 THEN products
            ELSE NULL
        END) AS unique_products_2021,
    CONCAT(((COUNT(DISTINCT CASE
                    WHEN year_manufactured = 2021 THEN products
                    ELSE NULL
                END) - COUNT(DISTINCT CASE
                    WHEN year_manufactured = 2020 THEN products
                    ELSE NULL
                END)) / COUNT(DISTINCT CASE
                    WHEN year_manufactured = 2020 THEN products
                    ELSE NULL
                END)) * 100,
            '%') AS percent_chng
FROM
    (SELECT 
        dim_product.product_code AS products,
            fact_manufacturing_cost.cost_year AS year_manufactured
    FROM
        gdb023.dim_product
    INNER JOIN gdb023.fact_manufacturing_cost ON fact_manufacturing_cost.product_code = dim_product.product_code) AS product_year_manufactured;

Explanation:

    The inner query selects the product code and the year of manufacturing from the "dim_product" and "fact_manufacturing_cost" tables, respectively.
    The outer query performs conditional counting to count the number of unique products manufactured in each year (2020 and 2021).
    COUNT(DISTINCT CASE WHEN year_manufactured = 2020 THEN products ELSE NULL END) counts the number of unique products manufactured in 2020.
    COUNT(DISTINCT CASE WHEN year_manufactured = 2021 THEN products ELSE NULL END) counts the number of unique products manufactured in 2021.
    The CONCAT function is used to calculate the percentage change between the two years, and the result is presented as a percentage. It calculates the percentage change as ((count of unique products in 2021 - count of unique products in 2020) / count of unique products in 2020) * 100.


-- 3 . Provide a report with all the unique product counts for each segment and sort them in -- descending order of product counts. The final output contains 2 fields

SELECT 
    segment, COUNT(DISTINCT product_code) AS product_count
FROM
    gdb023.dim_product
GROUP BY segment
ORDER BY 2 DESC;


SELECT segment, COUNT(DISTINCT product_code) AS product_count: This part of the query selects the "segment" column from the "dim_product" table and counts the distinct occurrences of "product_code" for each segment. The result is aliased as "product_count."
FROM gdb023.dim_product: This specifies the table from which we are retrieving data, which is "dim_product" in the "gdb023" database.
GROUP BY segment: This groups the results by the "segment" column, so the count is performed for each unique segment.
ORDER BY 2 DESC: This orders the results by the second column (product_count) in descending order. The "2" refers to the position of the "product_count" column in the SELECT statement

-- 4 . Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields

SELECT 
    segment,
    COUNT(DISTINCT CASE
            WHEN year_manufactured = 2020 THEN products
            ELSE NULL
        END) AS unique_products_2020,
    COUNT(DISTINCT CASE
            WHEN year_manufactured = 2021 THEN products
            ELSE NULL
        END) AS unique_products_2021,
    (COUNT(DISTINCT CASE
            WHEN year_manufactured = 2021 THEN products
            ELSE NULL
        END) - COUNT(DISTINCT CASE
            WHEN year_manufactured = 2020 THEN products
            ELSE NULL
        END)) AS difference
FROM
    (SELECT 
        dim_product.segment AS segment,
            dim_product.product_code AS products,
            fact_manufacturing_cost.cost_year AS year_manufactured
    FROM
        gdb023.dim_product
    INNER JOIN gdb023.fact_manufacturing_cost ON fact_manufacturing_cost.product_code = dim_product.product_code) AS product_year_manufactured
GROUP BY 1;

    The inner query selects the segment, product code, and year of manufacturing from the "dim_product" and "fact_manufacturing_cost" tables, respectively.
    The outer query calculates the count of unique products manufactured in each year (2020 and 2021) for each segment using conditional counting.
    COUNT(DISTINCT CASE WHEN year_manufactured = 2020 THEN products ELSE NULL END) counts the number of unique products manufactured in 2020.
    COUNT(DISTINCT CASE WHEN year_manufactured = 2021 THEN products ELSE NULL END) counts the number of unique products manufactured in 2021.
    The difference between the counts of unique products in 2021 and 2020 is calculated to determine the increase.
    GROUP BY 1 groups the results by the first column (segment).

-- 5. Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields

(SELECT 
    dim_product.product_code AS product_code,
    dim_product.product AS product,
    fact_manufacturing_cost.manufacturing_cost AS manufacturing_cost
FROM
    gdb023.dim_product
        INNER JOIN
    gdb023.fact_manufacturing_cost ON fact_manufacturing_cost.product_code = dim_product.product_code
ORDER BY fact_manufacturing_cost.manufacturing_cost
LIMIT 1) UNION (SELECT 
    dim_product.product_code AS product_code,
    dim_product.product AS product,
    fact_manufacturing_cost.manufacturing_cost AS manufacturing_cost
FROM
    gdb023.dim_product
        INNER JOIN
    gdb023.fact_manufacturing_cost ON fact_manufacturing_cost.product_code = dim_product.product_code
ORDER BY fact_manufacturing_cost.manufacturing_cost DESC
LIMIT 1)
;


The query uses a UNION operator to combine the results of two separate queries
The first part of the UNION retrieves the product with the lowest manufacturing cost:
This subquery selects the product_code, product, and manufacturing_cost fields from the dim_product and fact_manufacturing_cost tables, joining them on the product_code column. It then orders the results by manufacturing_cost in ascending order and selects only the top record using LIMIT 1.
The second part of the UNION retrieves the product with the highest manufacturing cost:
This subquery is similar to the first one but orders the results by manufacturing_cost in descending order to get the product with the highest manufacturing cost.
The UNION operator combines the results of the two subqueries into a single result set.


-- 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. The final output contains these fields

SELECT 
    dim_customer.customer AS customers,
    fact_pre_invoice_deductions.fiscal_year,
    CONCAT(ROUND((AVG(fact_pre_invoice_deductions.pre_invoice_discount_pct) * 100),
                    2),
            '%') AS Average_Discount_pct
FROM
    fact_pre_invoice_deductions
        LEFT JOIN
    dim_customer ON dim_customer.customer_code = fact_pre_invoice_deductions.customer_code
WHERE
    fact_pre_invoice_deductions.fiscal_year = 2021
        AND dim_customer.sub_zone = 'India'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5;

    The query selects the following fields:
        dim_customer.customer as 'customers': This selects the customer names.
        fact_pre_invoice_deductions.fiscal_year: This selects the fiscal year.
        CONCAT(ROUND((AVG(fact_pre_invoice_deductions.pre_invoice_discount_pct) * 100), 2), '%') AS Average_Discount_pct: This calculates the average pre-invoice discount percentage, rounds it to two decimal places, and converts it to a percentage format.

    It retrieves data from the fact_pre_invoice_deductions table and joins it with the dim_customer table using the customer_code column.

    It filters the data based on the following conditions:
        fact_pre_invoice_deductions.fiscal_year = 2021: Restricts the data to the fiscal year 2021.
        dim_customer.sub_zone = 'India': Limits the data to customers in the Indian market.

    The results are grouped by the dim_customer.customer field, which represents the customer names.

    The results are then ordered in descending order of the average discount percentage (ORDER BY 3 DESC) and limited to the top 5 customers (LIMIT 5).


    -- 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions.

SELECT 
    MONTH(s.date) month_number,
    YEAR(s.date) Year,
    ROUND(SUM(gp.gross_price * s.sold_quantity), 0) AS gross_sales
FROM
    fact_sales_monthly s
        JOIN
    fact_gross_price gp ON s.product_code = gp.product_code
        JOIN
    (SELECT 
        customer_code
    FROM
        dim_customer
    WHERE
        customer = 'Atliq Exclusive') c ON s.customer_code = c.customer_code
GROUP BY YEAR(s.date) , MONTH(s.date)
ORDER BY Year;

It selects the following fields:

    MONTH(s.date) as 'month_number': This extracts the month from the sales date.
    YEAR(s.date) as 'Year': This extracts the year from the sales date.
    ROUND(SUM(gp.gross_price * s.sold_quantity), 0) AS gross_sales: This calculates the gross sales amount by multiplying the gross price of each product by the quantity sold, summing up the values, and rounding the result to the nearest integer.

It retrieves data from the fact_sales_monthly table and joins it with the fact_gross_price table based on the product_code column to get the gross price of each product.

It joins the result with a subquery that selects the customer_code from the dim_customer table where the customer name is 'Atliq Exclusive'. This filters the sales data to include only transactions from this specific customer.

The results are grouped by year and month (GROUP BY YEAR(s.date), MONTH(s.date)) to aggregate the sales data for each month.

Finally, the results are ordered by year (ORDER BY Year).


-- 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity,

SELECT 
    CASE
        WHEN MONTH(date) IN (9 , 10, 11) THEN 'Q1'
        WHEN MONTH(date) IN (12 , 1, 2) THEN 'Q2'
        WHEN MONTH(date) IN (3 , 4, 5) THEN 'Q3'
        ELSE 'Q4'
    END AS quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM
    fact_sales_monthly
WHERE
    fiscal_year = 2020
GROUP BY quarter
ORDER BY total_sold_quantity DESC;

    It uses a CASE statement to categorize each month into quarters based on its numerical representation:
        Months 9, 10, and 11 (September, October, November) are categorized as 'Q1'.
        Months 12, 1, and 2 (December, January, February) are categorized as 'Q2'.
        Months 3, 4, and 5 (March, April, May) are categorized as 'Q3'.
        All other months are categorized as 'Q4'.

    It calculates the total quantity sold (SUM(sold_quantity)) for each quarter.

    It filters the data to include only sales data from the fiscal year 2020 (WHERE fiscal_year = 2020).

    The results are grouped by the quarter calculated using the CASE statement (GROUP BY quarter).

    Finally, the results are sorted in descending order based on the total quantity sold (ORDER BY total_sold_quantity DESC), allowing us to see which quarter had the maximum total sold quantity first.


    -- 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields,

SELECT channel,
       gross_sales_mln,
       CONCAT(ROUND(gross_sales_mln/SUM(gross_sales_mln) over()*100,2),'%') as percentage
FROM
    (SELECT c.channel,
            ROUND(SUM(s.sold_quantity * gp.gross_price)/1000000,2) AS gross_sales_mln
     FROM dim_customer c
     JOIN fact_sales_monthly s ON c.customer_code = s.customer_code
     AND s.fiscal_year = 2021
     JOIN fact_gross_price gp ON gp.product_code = s.product_code
     AND gp.fiscal_year = 2021
     GROUP BY c.channel) e
ORDER BY percentage DESC;

    The inner query calculates the gross sales in millions (gross_sales_mln) for each channel in the fiscal year 2021:
        It joins the dim_customer table c with the fact_sales_monthly table s based on the customer_code.
        It also joins the fact_gross_price table gp based on the product_code.
        Data is filtered to include only sales data from the fiscal year 2021.
        The SUM(s.sold_quantity * gp.gross_price) calculates the total gross sales for each customer.
        The GROUP BY c.channel groups the data by channel.

    The outer query selects the channel, gross sales in millions, and calculates the percentage contribution of each channel to total gross sales:
        SUM(gross_sales_mln) over() calculates the total gross sales across all channels.
        ROUND(gross_sales_mln / SUM(gross_sales_mln) over() * 100, 2) calculates the percentage contribution of each channel.
        CONCAT(...) formats the percentage with '%' symbol.

    The final output is ordered by the percentage contribution in descending order.


-- 10. Get the Top 3 products in each division that have a high total sold quantity in the fiscal year 2021 ? 

SELECT division,
       product_code,
       product,
       total_sold_quantity,
       rnk AS rank_order
FROM
    (SELECT p.division,
            p.product_code,
            p.product,
            SUM(m.sold_quantity) total_sold_quantity,
            RANK() OVER(PARTITION BY p.division
                        ORDER BY SUM(m.sold_quantity) DESC) as rnk
     FROM fact_sales_monthly m
     JOIN dim_product p ON m.product_code = p.product_code
     WHERE m.fiscal_year = 2021
     GROUP BY 1,
              2,
              3) a
WHERE rnk < 4 ;


    The inner query calculates the total sold quantity for each product within each division for the fiscal year 2021:
        It joins the fact_sales_monthly table m with the dim_product table p based on the product_code.
        Data is filtered to include only sales data from the fiscal year 2021.
        The SUM(m.sold_quantity) calculates the total sold quantity for each product.
        The results are grouped by division, product code, and product.

    Within each division, the RANK() function assigns a rank to each product based on its total sold quantity in descending order.

    The outer query selects the division, product code, product name, total sold quantity, and rank:
        It filters the results to include only products with ranks less than 4, effectively selecting the top 3 products in each division.
        The rnk AS rank_order column represents the rank of each product within its division.

