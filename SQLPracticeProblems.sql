-- Which shippers do we have?
select * from Shippers

-- Certain fields from Categories
select CategoryName, Description from Categories

-- Sales representatives
select FirstName, LastName, HireDate from Employees where title = 'Sales Representative'

-- Sales representatives in the United States
select FirstName, LastName, HireDate from Employees where title = 'Sales Representative' and Country = 'USA'

-- Orders places by specific EmployeeID
select * from Orders where EmployeeID = 5

-- Suppliers and ContactTitles
select SupplierID, ContactName, ContactTitle from Suppliers where ContactName != 'Marketing Manager'

-- Products with "queso" in ProductName
select ProductID, ProductName from Products where ProductName like '%queso%'

-- Orders shipping from France to Belgium
select OrderID, CustomerID, ShipCountry from Orders where ShipCountry = 'France' or ShipCountry = 'Belgium'

-- Orders shipping from any country 
select OrderId, CustomerID, ShipCountry from Orders where ShipCountry in ('Brazil', 'Mexico', 'Argentina', 'Venezuela')

-- Employees, in order of age
select FirstName, LastName, Title, BirthDate from Employees order by BirthDate

-- Showing only the date with a DateTime field
select FirstName, LastName, Title, convert(date, BirthDate) from Employees order by BirthDate

-- Employees full name
select FirstName, LastName, CONCAT(FirstName, ' ', LastName) as FullName from Employees

-- OrderDetails amount per line item
select OrderID, ProductID, UnitPrice, Quantity, UnitPrice * Quantity as TotalPrice from [Order Details] order by OrderID, ProductID

-- How many customers?
select count(CustomerID) as TotalCustomers from Customers

-- When was the first order?
select min(OrderDate) from Orders

-- Countries where there are customers
select Country from Customers group by Country

-- Contact titles for Customers
select ContactTitle, count(ContactTitle) as Num from Customers group by ContactTitle

-- Products with associated supplier names
select ProductID, ProductName, CompanyName from Suppliers s join Products p on s.SupplierID = p.SupplierID order by ProductID

-- Orders and the Shipper that was used
select OrderID, convert(date, OrderDate), CompanyName from Shippers s join Orders o on s.ShipperID = o.ShipVia

-- Categories, and the total products in each category
select * from products
select CategoryName, count(ProductID) as TotalProducts from Products p 
join Categories c on p.CategoryID = c.CategoryID group by CategoryName order by TotalProducts desc

-- Total customers per country/city
select Country, City, count(CustomerID) as TotalCustomer from Customers group by Country, City order by TotalCustomer desc

-- Products that need reordering
select ProductID, ProductName, UnitsInStock, ReorderLevel from products where UnitsInStock < ReorderLevel order by ProductID

-- Products that need reoreding (Continued)
select ProductID, ProductName, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued from Products 
where UnitsInStock + UnitsOnOrder <= ReorderLevel and Discontinued = 0

-- Customer list by region
select CustomerID, CompanyName, Region from Customers 
order by case when region is null then 1 else 0 end, Region

-- High freight charges
select TOP 3 ShipCountry, avg(Freight) as AverageFreight from Orders group by ShipCountry order by AVG(Freight) desc 

-- High freight charges - 1997
select * from Orders
select TOP 3 ShipCountry, avg(Freight) as AverageFreight from Orders where year(OrderDate) = 1997 group by ShipCountry order by AVG(Freight) desc 

-- High freight charges with between
select * from orders order by OrderDate

-- High freight charges - last year
select TOP 3 ShipCountry, avg(Freight) as AverageFreight from Orders
where OrderDate >= (select DATEADD(YEAR, -1, (select max(orderDate) from Orders))) 
group by ShipCountry order by AverageFreight DESC

-- Inventory list
select e.EmployeeID, e.LastName, od.OrderID, p.ProductName, od.Quantity from Orders o
join [Order Details] od on o.OrderID = od.OrderID
join Products p on od.ProductID = p.ProductID
join Employees e on o.EmployeeID = e.EmployeeID
order by o.OrderID, p.ProductID

-- Customers with no orders
select Customers.CustomerID, Orders.CustomerID from Customers
left join Orders on customers.CustomerID = orders.CustomerID
where orders.CustomerID is null

-- Customers with no Orders for EmployeeID 4
select c.CustomerID, o.CustomerID
from Customers as c
left join Orders o on o.CustomerID = c.CustomerID and o.EmployeeID = 4
where o.CustomerID is null

-- High-Value Customers
select c.CustomerID, c.CompanyName, o.OrderID, sum(od.UnitPrice * od.Quantity) totalPrice
from customers c 
inner join orders o on c.CustomerID = o.CustomerID
inner join [Order Details] od on o.OrderID = od.OrderID
where year(o.OrderDate) = 2016
group by c.CustomerID, c.CompanyName, o.OrderID
HAVING totalPrice >= 1000 -- To solve
order by totalPrice desc;

-- High-Value customers - total orders ???

-- High-Value customers - with discount ???

-- Month-End orders
select o.EmployeeID, OrderID, OrderDate from Orders o
join Employees e on o.EmployeeID = e.EmployeeID
where day(OrderDate) in (31, 30, 28, 29)

-- Orders with many line items
select top 2 percent od.OrderID, count(*) as totalOrders
from [Order Details] od
join orders o on od.OrderID = o.OrderID
group by od.OrderID
order by totalOrders desc

-- Orders - random assortment ?? figure out random values
select OrderID from Orders 
WHERE 0.02 >= CAST(CHECKSUM(NEWID(), OrderID) & 0x7fffffff AS float) / CAST (0x7fffffff AS int)
-- Orders - accidental double-entry
select OrderID from [Order Details]
where Quantity >= 60
group by OrderID, Quantity
having count(*) > 1

-- Orders - accidental double-entry details
SELECT * 
FROM [Order Details]
WHERE OrderID in (SELECT DISTINCT OrderID FROM [Order Details] WHERE Quantity >= 60 GROUP BY OrderID, Quantity HAVING COUNT(*) > 1)
ORDER BY Quantity;

-- Orders - accidental double-entry details, derived table
select od.OrderID, UnitPrice, Quantity, Discount from [Order Details] od
join (select distinct OrderID from [Order Details] where Quantity >= 60 group by OrderID, Quantity having count(*) > 1) PotentialProblemOrders on PotentialProblemOrders.OrderID = od.OrderID
order by OrderID, ProductID

-- Late Orders
select * from Orders where RequiredDate < ShippedDate

-- Late Orders - which employees?
select o.EmployeeID, LastName, Count(OrderID) TotalLateOrders from Orders o 
join Employees e on o.EmployeeID = e.EmployeeID where RequiredDate < ShippedDate 
group by o.EmployeeID, LastName order by TotalLateOrders desc

-- Late orders vs total orders
with LateOrders as (
	select EmployeeID, Count(*) LateOrders from Orders where RequiredDate <= ShippedDate
	group by EmployeeID
), TotalOrders as (
	select EmployeeID, Count(*) TotalOrders from Orders group by EmployeeID
) 
select TotalOrders.EmployeeID, LastName, TotalOrders, LateOrders from TotalOrders
join Employees e on TotalOrders.EmployeeID = e.EmployeeID
join LateOrders lo on TotalOrders.EmployeeID = lo.EmployeeID
order by TotalOrders desc

-- Late Orders vs total orders - percentage
with LateOrders as (
	select EmployeeID, Count(*) LateOrders from Orders where RequiredDate <= ShippedDate
	group by EmployeeID
), TotalOrders as (
	select EmployeeID, Count(*) TotalOrders from Orders group by EmployeeID
) 
select TotalOrders.EmployeeID, LastName, TotalOrders, LateOrders, 
round(LateOrders * 100.0 / TotalOrders, 2) PercentLateOrders from TotalOrders
join Employees e on TotalOrders.EmployeeID = e.EmployeeID
join LateOrders lo on TotalOrders.EmployeeID = lo.EmployeeID
order by TotalOrders desc

-- Late orders vs total orders - fix decimal
with LateOrders as (
	select EmployeeID, Count(*) LateOrders from Orders where RequiredDate <= ShippedDate
	group by EmployeeID
), TotalOrders as (
	select EmployeeID, Count(*) TotalOrders from Orders group by EmployeeID
) 
select TotalOrders.EmployeeID, LastName, TotalOrders, LateOrders, 
cast(round(LateOrders * 100.0 / TotalOrders, 2) as numeric(36, 2)) PercentLateOrders from TotalOrders
join Employees e on TotalOrders.EmployeeID = e.EmployeeID
join LateOrders lo on TotalOrders.EmployeeID = lo.EmployeeID
order by TotalOrders desc

-- Customer grouping
select *,
	case when TotalOrderAmount between 0 and 1000 then 'Low' 
	when TotalOrderAmount between 1000 and 5000 then 'Medium'
	when TotalOrderAmount between 5000 and 10000 then 'High' 
	when TotalOrderAmount >= 10000 then 'Very High'
	end CustomerGroup
from (
	select o.CustomerID, c.CompanyName, sum(od.UnitPrice * od.Quantity) as TotalOrderAmount
	from Orders o
	join [Order Details] od on o.OrderID = od.OrderID
	join Customers c on o.CustomerID = c.CustomerID
	where o.OrderDate between '19960101' and '19970101'
	group by o.CustomerID, c.CompanyName
	) cg

-- Customer grouping - fix null (Fixed in above query)

-- Customer grouping with percentage
with Order1996 as (
	select c.CustomerID, c.CompanyName, sum(Quantity * UnitPrice) TotalOrderAmount
	from Customers c
	join Orders o on o.CustomerID = c.CustomerID
	join [Order Details] od on o.OrderID = od.OrderID
	where OrderDate >= '19960101' and OrderDate < '19970101'
	group by c.CustomerID, c.CompanyName
), CustomerGroupuing as (
	select CustomerID, CompanyName, TotalOrderAmount, CustomerGroup =
	case
		when TotalOrderAmount between 0 and 1000 then 'Low'
		when TotalOrderAmount between 1000 and 5000 then 'Medium'
		when TotalOrderAmount between 5000 and 10000 then 'High'
		when TotalOrderAmount >= 10000 then 'Very High'
		end from Order1996
)
select CustomerGroup, count(*) TotalInGroup, count(*) * 1.0 / (select count(*) from CustomerGroupuing)
from CustomerGroupuing group by CustomerGroup 
order by TotalInGroup desc;

-- Customer grouping - flexible (Missing CustomerGroupThresholds table)

-- Countries with suplliers or customers
select Country from Customers union select Country from Suppliers

-- Countries with suppliers or customers, version 2
;with s as (select distinct Country from Suppliers), c as (select distinct Country from Customers)
select s.Country SupplierCountry , c.Country CustomerCountry from s
full outer join c
on c.Country = s.Country

-- Countries with suppliers or customers, version 3
with SupplierCountries as (select Country, Total = Count(*) from Suppliers group by Country),
CustomerCountries as (select Country, Total = Count(*) from Customers group by Country)
select isnull(sc.Country, cc.Country) Country, isnull(sc.Total, 0) TotalSuppliers, isnull(cc.Total, 0) TotalCustomers from SupplierCountries sc
full outer join CustomerCountries cc on cc.Country = sc.Country

-- First order in each country
with OrdersByCountry as (
	select
)