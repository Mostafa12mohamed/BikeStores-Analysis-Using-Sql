--A- Explore Data

-- Production
select * from production.brands
select * from production.categories
select * from production.products
select * from production.stocks

-- Sales
select * from sales.customers
select * from sales.order_items
select * from sales.orders
select * from sales.staffs
select * from sales.stores

-------------------------------------------

--B- Questions

--1- Which bike is most expensive? What could be the motive behind pricing this bike at the high price?
select top 1 product_name as Product_Name, list_price as Product_Price
from production.products 
order by list_price desc
-- it is could be the quality and features of this bike and also the cost of production 


--2- How many total customers does BikeStore have? Would you consider people with order status 3 as customers substantiate your answer?
select  count(customer_id) as Total_Customers 
from sales.customers

-- Note: customer_id is a primary key in this table
-- customer who has a rejected order is still considered a customer
-- they may have made purchases in the past or may choose to purchase again in the future 
-- we should get the feedback from them about why they rejected the orders



--3- How many stores does BikeStore have?
select count(store_id) as Total_Stores 
from sales.stores



--4- What is the total price spent per order?
select order_id as Order_ID, sum(list_price*quantity *(1-discount)) as Total_Price  from sales.order_items
group by Order_ID



--5- What’s the sales/revenue per store?select ss.store_name, so.store_id, sum(soi.list_price * soi.quantity * (1- soi.discount)) Total_Sales from

sales.stores ss join sales.orders so 
on ss.store_id = so.store_id

join  sales.order_items soi 
on soi.order_id = so.order_id

group by so.store_id, ss.store_nameorder by Total_Sales desc
--6- Which category is most sold?
select top 1 pc.category_name Most_Category_Sold, sum(soi.list_price * soi.quantity * (1- soi.discount)) Total_Sales from 

production.categories pc join production.products pp
on pc.category_id = pp.category_id

join  sales.order_items soi 
on  pp.product_id = soi.product_id

join sales.orders so 
on so.order_id = soi.order_id

where so.order_status = 4

group by pc.category_name
order by Total_Sales desc



--7- Which category rejected more orders?
select top 1 pc.category_name Most_Category_Rejected, count(soi.order_id) Total_Order from 

production.categories pc join production.products pp
on pc.category_id = pp.category_id

join  sales.order_items soi
on  pp.product_id = soi.product_id

join sales.orders so 
on so.order_id = soi.order_id

where so.order_status = 3

group by pc.category_name
order by Total_Order desc


--8- Which bike is the least sold?
select top 1 product_name Product_Name, sum(ps.quantity) Total_Quantity_Sold from 

production.products pp join production.stocks ps
on pp.product_id = ps.product_id

join sales.order_items soi
on soi.product_id = pp.product_id

join sales.orders so 
on soi.order_id  = so.order_id

where so.order_status = 4

group by product_name
order by Total_Quantity_Sold 



--9- What’s the full name of a customer with ID 259?
select concat(first_name,' ',last_name), phone, email, city Full_Name from sales.customers
where customer_id = 295


--10- What did the customer on question 9 buy and when? What’s the status of this order
select product_name, order_status from 

sales.orders so join sales.order_items soi
on so.order_id = soi.order_id

join production.products pp 
on pp.product_id = soi.product_id

where customer_id = 295


--11- Which staff processed the order of customer 259? And from which store?
select ss.staff_id , ss.first_name, ss.store_id from sales.staffs ss join sales.orders so 
on ss.store_id = so.store_id
where so.customer_id = 259


--12- How many staff does BikeStore have? Who seems to be the lead Staff at BikeStore?
select count(*) Total_Staff from sales.staffs
select * from sales.staffs 
where manager_id  is null


--13- Which brand is the most liked?
select top 1 pb.brand_name, sum(soi.quantity) total_sold from  
production.brands pb join production.products pp 
on pb.brand_id = pp.brand_id

join sales.order_items soi
on pp.product_id = soi.product_id

group by pb.brand_name
order by total_sold desc

-- 14-How many categories does BikeStore have, and which one is the least liked?
select count(*) total_categories from production.categories

select top 1 pc.category_name, sum(soi.quantity) total_sold from 

production.categories pc join production.products pp 
on pc.category_id = pp.brand_id

join sales.order_items soi
on pp.product_id = soi.product_id

group by pc.category_name
order by total_sold 


--15- Which store still have more products of the most liked brand?
with MostLikedBrand as (
   select top 1 pb.brand_id from 

    production.brands pb join production.products pp 
	on pb.brand_id = pp.brand_id

    join sales.order_items soi 
	on pp.product_id = soi.product_id

    group by pb.brand_id
    order by sum(soi.quantity) desc
)

select top 1 st.store_name,  sum(ps.quantity) as total_products from

production.stocks ps join  production.products pp
on ps.product_id = pp.product_id

join MostLikedBrand mlb 
on pp.brand_id = mlb.brand_id

join sales.stores st 
on ps.store_id = st.store_id

group by st.store_name
order by total_products desc
 


--16- Which state is doing better in terms of sales?
select sc.state, sum(soi.quantity * (soi.list_price - soi.discount))  total_sales from  

sales.orders so  join    sales.customers sc 
on so.customer_id = sc.customer_id

join sales.order_items soi 
on so.order_id = soi.order_id

group by sc.state
order by total_sales desc
 


--17- What’s the discounted price of product id 259?
select (list_price * ( 1- discount)) discounted_price from sales.order_items
where product_id = 259



--18- What’s the product name, quantity, price, category, model year and brand name of product number 44?
select  pp.product_name, pb.brand_name, pc.category_name, ps.quantity, pp.model_year, pp.list_price from 

production.products pp join production.stocks ps
on ps.product_id = pp.product_id

join production.brands pb
on pp.brand_id = pb.brand_id

join production.categories pc
on pp.category_id = pc.category_id

where pp.product_id = 44

--19- What’s the zip code of CA?
select distinct zip_code from sales.customers 
where state = 'CA'


--20- How many states does BikeStore operate in?
select  count(distinct state)  total_states from sales.customers


--21- How many bikes under the children category were sold in the last 8 months?
select sum(soi.quantity) Total_Quantity_Sold from 

sales.order_items soi join production.products pp
on soi.product_id = pp.product_id

join production.categories pc
on pp.category_id = pc.category_id

join sales.orders so
on soi.order_id = so.order_id

where pc.category_name = 'Children Bicycles' and so.order_status = 4  and order_date between '2018-05-01' and '2018-12-30' 


--22- What’s the shipped date for the order from customer 523?
select shipped_date from sales.orders 
where customer_id = 523


--23- How many orders are still pending?
select count(*) Total_Pending_Orders 
from sales.orders 
where order_status = 1



--24- What’s the names of category and brand does "Electra white water 3i -2018" fall under?
select  pc.category_name, pb.brand_name
from
production.products pp join production.categories pc 
on pp.category_id = pc.category_id

join production.brands pb 
on pp.brand_id = pb.brand_id

where pp.product_name = 'Electra white water 3i - 2018';














 











 