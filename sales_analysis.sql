--- have a look at the data
select * from sales_data

--- unique values
select distinct STATUS from sales_data  
select distinct YEAR_ID from sales_data 
select distinct PRODUCTLINE from sales_data 
select distinct COUNTRY from sales_data 
select distinct DEALSIZE from sales_data 
select distinct TERRITORY from sales_data 

--- analysis

--- sales by product
select PRODUCTLINE, SUM(SALES) as Revenue
from sales_data
group by PRODUCTLINE
order by Revenue desc
--- Classic Cars are the best saler followed by Vintage Cars
--- Trains made the least revenue

--- sales by year
select YEAR_ID, SUM(SALES) as Revenue
from sales_data
group by YEAR_ID
order by Revenue desc
--- the best year for revenue was 2004 while 2005 happened to be the worst
--- but the data for 2005 is only till May
select distinct MONTH_ID from sales_data
where YEAR_ID = 2005

--- but if take only first 5 months of each year
--- we can see that 2005 is the biggest by revenue
select YEAR_ID, SUM(SALES) as Revenue
from sales_data where MONTH_ID in (1,2,3,4,5)
group by YEAR_ID
order by Revenue desc

--- sales by deal size
select DEALSIZE, SUM(SALES) as Revenue
from sales_data
group by DEALSIZE
order by Revenue desc
--- medium size deals were bringing by far the most revenue

--- best months for sales in 2003 
select MONTH_ID, sum(SALES) as Revenue, count(ORDERNUMBER) as num_orders
from sales_data
where YEAR_ID = 2003
group by MONTH_ID
order by Revenue desc
--- November was the best month in 2003

--- best months for sales in 2004 
select MONTH_ID, sum(SALES) as Revenue, count(ORDERNUMBER) as num_orders
from sales_data
where YEAR_ID = 2004
group by MONTH_ID
order by Revenue desc
--- November was the best month again in 2004

--- best months for sales in 2005 (only first 5 months) 
select MONTH_ID, sum(SALES) as Revenue, count(ORDERNUMBER) as num_orders
from sales_data
where YEAR_ID = 2005
group by MONTH_ID
order by Revenue desc
--- May was the best month in 2005

--- November seems to be the best month for the company
--- let's see what product is the best seller on November

--- in November 2003
select PRODUCTLINE, sum(SALES) as Revenue, count(ORDERNUMBER) as num_orders
from sales_data
where YEAR_ID = 2003 and MONTH_ID = 11
group by PRODUCTLINE
order by Revenue desc

--- in November 2004
select PRODUCTLINE, sum(SALES) as Revenue, count(ORDERNUMBER) as num_orders
from sales_data
where YEAR_ID = 2004 and MONTH_ID = 11
group by PRODUCTLINE
order by Revenue desc

--- as expected Classic cars are the best sellers 

--- countries with most revenue and purchases
--- and percent of revenue by country
with revenue_by_country as (
	select COUNTRY, count(ORDERNUMBER) as num_purchases,
		sum(SALES) as revenue
	from sales_data
	group by COUNTRY
)
select *,
	round(revenue/(select sum(SALES) from sales_data)*100,2) as percent_revenue
from revenue_by_country
order by revenue desc
--- almost 70% of revenue comes from 5 countries: US, Spain, France, Australia and UK
--- and about 36% of revenue comes from US

--- RFM analysis Recency-Frequency-Monetary

--- Indexing technique that uses past purchase behaviour to segment customers
--- RFM report is a way to segment customers using three key metrics:
--- recency (how long ago their last purchase was)
--- frequency (how often they make purchases)
--- monetary (how much they spent)

--- a table to show:
--- how much each customer spent in total
--- how much each customer spent on average
--- number of purchases
--- last purchase date
--- and number of days passed since the customer's last purchase

--- also use ntile() to distribute rows into 4 groups by recency, frequency and monetary
--- groups are 1,2,3,4
--- in recency group, 1 for clients that made their purchase long time ago, 4 - for clients with recent purchases
--- in frequency group, 1 for clients with low amount of purchases, 4 - for clients with high amount of purchases
--- in monetary group, 1 for clients spending low amount of money, 4 - for clients with high amount of money spent
drop table if exists #rfm_table
with rfm as (
	select 
		CUSTOMERNAME,COUNTRY,
		sum(SALES) as total_spent,
		avg(SALES) as avg_spent,
		count(ORDERNUMBER) as num_purchases,
		max(ORDERDATE) as last_order_date,
		DATEDIFF(dd, max(ORDERDATE), (select max(ORDERDATE) from sales_data)) as days_from_last_purchase
	from sales_data
	group by CUSTOMERNAME, COUNTRY
),
rfm_calc as (
	select *,
		ntile(4) over (order by days_from_last_purchase desc) as recency_groups,
		ntile(4) over (order by num_purchases) as frequency_groups,
		ntile(4) over (order by total_spent) as monetary_groups
	from rfm
)
--- creating rfm cells that will be values of recency, frequency and monetary groups summed up for each client
--- and another colum where those values passed on as strings
select *, recency_groups+frequency_groups+monetary_groups as rfm_cell,
	cast(recency_groups as varchar)+cast(frequency_groups as varchar)+cast(monetary_groups as varchar) as rfm_cell_string
--- keep it in temp table
into #rfm_table
from rfm_calc


--- have a look
select * from #rfm_table

--- categorize those rfm cells as

--- 111,112,121,122,123,132,211,212,221,114,141 - lost cutomers, who didn't make big purchase and those they did were long time ago
--- 133,134,143,144,244,334,343,344 - can't lose, customers who spend big but their last purchase was some time ago
--- 311,411,331,412,421 - new customers with small recent purchases
--- 222,223,232,233,234,322 - potential churners who might be going away from our store
--- 323,333,321,422,423,332,432 - active customers, who make frequent small purchases
--- 433,434,443,444 - loyal customers, big and frequent buyers
select CUSTOMERNAME, COUNTRY, recency_groups, frequency_groups, monetary_groups,
	case
		when rfm_cell_string in (111,112,121,122,123,132,211,212,221,114,141) then 'lost_customers'
		when rfm_cell_string in (133,134,143,144,244,334,343,344) then 'cannot_lose'
		when rfm_cell_string in (311,411,331,412,421) then 'new_customers'
		when rfm_cell_string in (222,223,232,233,234,322) then 'potential_churners'
		when rfm_cell_string in (323,333,321,422,423,332,432) then 'active_customers'
		when rfm_cell_string in (433,434,443,444) then 'loyal_customers'
	end as rfm_segment
into #rfm_segment_table
from #rfm_table

--- have a look
select * from #rfm_segment_table


--- what 2 products most often sold together
select distinct ORDERNUMBER, stuff (
	(
		select ',' + PRODUCTCODE from sales_data as p
		where ORDERNUMBER in (
			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) as num_prod --- number of products in order
				from sales_data
				where STATUS = 'Shipped'
				group by ORDERNUMBER) as orders
			where num_prod = 2)
			and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path ('')
	),
	1,1,'') as ProductCodes
from sales_data as s
order by ProductCodes desc
--- to see what products are commonly sold together and 
--- maybe run some promotions trying to advertise them together

