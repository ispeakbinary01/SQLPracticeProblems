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