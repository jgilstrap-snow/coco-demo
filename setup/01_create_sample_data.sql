-- Retail Analytics Demo - Sample Data Setup
-- Run this script to create sample tables for the demo

USE ROLE SYSADMIN;
USE DATABASE JACK;
USE SCHEMA DEMO;

-- Customers table
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    signup_date DATE,
    customer_segment VARCHAR(20)
);

INSERT INTO CUSTOMERS VALUES
(1, 'Sarah', 'Johnson', 'sarah.j@email.com', 'Seattle', 'WA', '2023-01-15', 'Premium'),
(2, 'Mike', 'Chen', 'mike.c@email.com', 'San Francisco', 'CA', '2023-02-20', 'Standard'),
(3, 'Emily', 'Davis', 'emily.d@email.com', 'Austin', 'TX', '2023-03-10', 'Premium'),
(4, 'James', 'Wilson', 'james.w@email.com', 'Denver', 'CO', '2023-04-05', 'Standard'),
(5, 'Lisa', 'Anderson', 'lisa.a@email.com', 'Portland', 'OR', '2023-05-22', 'Premium'),
(6, 'David', 'Martinez', 'david.m@email.com', 'Phoenix', 'AZ', '2023-06-18', 'Standard'),
(7, 'Jennifer', 'Taylor', 'jen.t@email.com', 'Seattle', 'WA', '2023-07-30', 'Premium'),
(8, 'Robert', 'Brown', 'rob.b@email.com', 'Los Angeles', 'CA', '2023-08-12', 'Standard'),
(9, 'Amanda', 'Garcia', 'amanda.g@email.com', 'Dallas', 'TX', '2023-09-25', 'Premium'),
(10, 'Chris', 'Lee', 'chris.l@email.com', 'Chicago', 'IL', '2023-10-08', 'Standard');

-- Products table
CREATE OR REPLACE TABLE PRODUCTS (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    cost DECIMAL(10,2)
);

INSERT INTO PRODUCTS VALUES
(101, 'Wireless Headphones', 'Electronics', 149.99, 65.00),
(102, 'Smart Watch', 'Electronics', 299.99, 120.00),
(103, 'Running Shoes', 'Apparel', 129.99, 45.00),
(104, 'Yoga Mat', 'Fitness', 49.99, 15.00),
(105, 'Coffee Maker', 'Home', 89.99, 35.00),
(106, 'Backpack', 'Accessories', 79.99, 25.00),
(107, 'Bluetooth Speaker', 'Electronics', 69.99, 28.00),
(108, 'Water Bottle', 'Fitness', 24.99, 8.00),
(109, 'Desk Lamp', 'Home', 44.99, 18.00),
(110, 'Sunglasses', 'Accessories', 159.99, 55.00);

-- Orders table
CREATE OR REPLACE TABLE ORDERS (
    order_id INT,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20)
);

INSERT INTO ORDERS VALUES
(1001, 1, '2024-01-05', 'Completed'),
(1002, 2, '2024-01-08', 'Completed'),
(1003, 3, '2024-01-12', 'Completed'),
(1004, 1, '2024-01-20', 'Completed'),
(1005, 4, '2024-02-02', 'Completed'),
(1006, 5, '2024-02-14', 'Completed'),
(1007, 6, '2024-02-18', 'Completed'),
(1008, 7, '2024-03-01', 'Completed'),
(1009, 2, '2024-03-10', 'Completed'),
(1010, 8, '2024-03-15', 'Completed'),
(1011, 9, '2024-03-22', 'Completed'),
(1012, 3, '2024-04-05', 'Completed'),
(1013, 10, '2024-04-12', 'Completed'),
(1014, 1, '2024-04-20', 'Completed'),
(1015, 5, '2024-05-01', 'Completed'),
(1016, 7, '2024-05-15', 'Shipped'),
(1017, 4, '2024-05-22', 'Shipped'),
(1018, 9, '2024-06-01', 'Processing'),
(1019, 6, '2024-06-05', 'Processing'),
(1020, 10, '2024-06-08', 'Pending');

-- Order Items table
CREATE OR REPLACE TABLE ORDER_ITEMS (
    item_id INT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2)
);

INSERT INTO ORDER_ITEMS VALUES
(1, 1001, 101, 1, 149.99),
(2, 1001, 104, 2, 49.99),
(3, 1002, 102, 1, 299.99),
(4, 1003, 103, 1, 129.99),
(5, 1003, 108, 3, 24.99),
(6, 1004, 105, 1, 89.99),
(7, 1004, 109, 1, 44.99),
(8, 1005, 106, 2, 79.99),
(9, 1006, 101, 1, 149.99),
(10, 1006, 107, 1, 69.99),
(11, 1007, 110, 1, 159.99),
(12, 1008, 102, 1, 299.99),
(13, 1008, 104, 1, 49.99),
(14, 1009, 103, 2, 129.99),
(15, 1010, 105, 1, 89.99),
(16, 1010, 108, 2, 24.99),
(17, 1011, 101, 1, 149.99),
(18, 1011, 106, 1, 79.99),
(19, 1012, 107, 2, 69.99),
(20, 1012, 109, 1, 44.99),
(21, 1013, 102, 1, 299.99),
(22, 1014, 110, 1, 159.99),
(23, 1014, 103, 1, 129.99),
(24, 1015, 104, 3, 49.99),
(25, 1015, 108, 2, 24.99),
(26, 1016, 101, 1, 149.99),
(27, 1017, 105, 2, 89.99),
(28, 1018, 102, 1, 299.99),
(29, 1019, 106, 1, 79.99),
(30, 1020, 107, 1, 69.99);
