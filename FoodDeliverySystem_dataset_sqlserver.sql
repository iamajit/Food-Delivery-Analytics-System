
-- Zomato Realistic Dataset for SQL Server
-- =======================================

-- Drop existing tables if they exist (to avoid conflicts)
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.Order_Items', 'U') IS NOT NULL DROP TABLE dbo.Order_Items;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Menu', 'U') IS NOT NULL DROP TABLE dbo.Menu;
IF OBJECT_ID('dbo.Delivery_Partners', 'U') IS NOT NULL DROP TABLE dbo.Delivery_Partners;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Restaurants', 'U') IS NOT NULL DROP TABLE dbo.Restaurants;

-- Restaurants Table
CREATE TABLE Restaurants (
    restaurant_id INT PRIMARY KEY,
    name NVARCHAR(255),
    city NVARCHAR(100),
    cuisine NVARCHAR(100),
    rating FLOAT,
    avg_cost INT,
    opening_hours NVARCHAR(100),
    is_veg_only BIT,
    delivery_available BIT,
    created_at DATE
);

-- Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name NVARCHAR(255),
    city NVARCHAR(100),
    email NVARCHAR(255),
    phone NVARCHAR(20),
    gender CHAR(1),
    dob DATE,
    join_date DATE,
    loyalty_points INT
);

-- Delivery Partners Table
CREATE TABLE Delivery_Partners (
    driver_id INT PRIMARY KEY,
    name NVARCHAR(255),
    city NVARCHAR(100),
    phone NVARCHAR(20),
    vehicle_type NVARCHAR(50),
    rating FLOAT,
    join_date DATE,
    active_status BIT
);

-- Menu Table
CREATE TABLE Menu (
    menu_id INT PRIMARY KEY,
    restaurant_id INT FOREIGN KEY REFERENCES Restaurants(restaurant_id),
    item_name NVARCHAR(255),
    category NVARCHAR(100),
    price INT,
    veg_nonveg NVARCHAR(20),
    calories INT,
    available BIT
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    restaurant_id INT FOREIGN KEY REFERENCES Restaurants(restaurant_id),
    order_date DATETIME,
    amount INT,
    discount INT,
    payment_mode NVARCHAR(50),
    delivery_time INT,
    delivery_status NVARCHAR(50),
    driver_id INT FOREIGN KEY REFERENCES Delivery_Partners(driver_id),
    promo_code NVARCHAR(50)
);

-- Order_Items Table
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES Orders(order_id),
    menu_id INT FOREIGN KEY REFERENCES Menu(menu_id),
    quantity INT,
    item_price INT
);

-- Reviews Table
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES Orders(order_id),
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    restaurant_id INT FOREIGN KEY REFERENCES Restaurants(restaurant_id),
    rating INT,
    comments NVARCHAR(500),
    review_date DATE,
    sentiment NVARCHAR(50)
);

-- =======================================
-- Bulk Insert from CSV (update file paths accordingly)
-- =======================================

-- Example for Restaurants (adjust path as per your system)
-- BULK INSERT Restaurants
-- FROM 'C:\path\to\zomato_realistic_restaurants.csv'
-- WITH (
--     FORMAT='CSV',
--     FIRSTROW=2,
--     FIELDTERMINATOR=',',
--     ROWTERMINATOR='\n',
--     TABLOCK
-- );
