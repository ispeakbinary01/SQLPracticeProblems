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
select ShipCountry, avg(Freight) as AverageFreight from Orders
where OrderDate = (select DATEADD(YEAR, -1, (select max(orderDate) from Orders))) 
group by ShipCountry order by AverageFreight

-- Inventory list
select * from Orders
select EmployeeID as eID, LastName, OrderID, Product, Quantity from Employees e
join Orders o on eiD = o.EmployeeID