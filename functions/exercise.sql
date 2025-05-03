-- 1
SELECT
    customerName,
    phone,
    creditLimit
FROM
    classicmodels.customers
WHERE
    creditLimit > 70000;

-- note: use 70000, not 70.000
-- 2
SELECT
    customerName,
    phone,
    creditLimit
FROM
    classicmodels.customers
WHERE
    creditLimit > 70000
ORDER BY
    creditLimit DESC;

-- largest first
-- 3
SELECT
    AVG(amount) AS avg_amount
FROM
    classicmodels.payments;

-- 4
SELECT
    AVG(amount) AS avg_amount
FROM
    classicmodels.payments
WHERE
    amount > 5000;

-- 5  all columns/rows from customers ✕ payments
SELECT
    *
FROM
    classicmodels.customers c
    JOIN classicmodels.payments p ON p.customerNumber = c.customerNumber;

-- 6  orderDate, customerName, amount
SELECT
    o.orderDate,
    c.customerName,
    p.amount
FROM
    classicmodels.orders o
    JOIN classicmodels.customers c ON c.customerNumber = o.customerNumber
    JOIN classicmodels.payments p ON p.customerNumber = c.customerNumber;

-- 7  how many rows does the previous join return?
SELECT
    COUNT(*)
FROM
    classicmodels.orders o
    JOIN classicmodels.customers c ON c.customerNumber = o.customerNumber
    JOIN classicmodels.payments p ON p.customerNumber = c.customerNumber;

-- 8  sum per country, smallest first
SELECT
    c.country,
    SUM(p.amount) AS total_amount
FROM
    classicmodels.payments p
    JOIN classicmodels.customers c ON c.customerNumber = p.customerNumber
GROUP BY
    c.country
ORDER BY
    total_amount ASC;

-- 9  only countries whose total > 100 000, largest first
SELECT
    c.country,
    SUM(p.amount) AS total_amount
FROM
    classicmodels.payments p
    JOIN classicmodels.customers c ON c.customerNumber = p.customerNumber
GROUP BY
    c.country
HAVING
    SUM(p.amount) > 100000
ORDER BY
    total_amount DESC;

-- 10  all orders with their order details
SELECT
    o.*,
    od.*
FROM
    classicmodels.orders o
    LEFT JOIN classicmodels.orderdetails od ON od.orderNumber = o.orderNumber;

CREATE
OR REPLACE VIEW classicmodels.v_customer_service AS
SELECT
    p.productName,
    od.priceEach,
    od.quantityOrdered,
    o.orderDate,
    c.customerName
FROM
    classicmodels.products p
    JOIN classicmodels.orderdetails od ON od.productCode = p.productCode
    JOIN classicmodels.orders o ON o.orderNumber = od.orderNumber
    JOIN classicmodels.customers c ON c.customerNumber = o.customerNumber;

-- Customer service can now run:
SELECT
    *
FROM
    classicmodels.v_customer_service;

-- 11 View for the customer‑service team
CREATE
OR REPLACE VIEW classicmodels.v_customer_service AS
SELECT
    p.productName,
    od.priceEach,
    od.quantityOrdered,
    o.orderDate,
    c.customerName
FROM
    classicmodels.products p
    JOIN classicmodels.orderdetails od ON od.productCode = p.productCode
    JOIN classicmodels.orders o ON o.orderNumber = od.orderNumber
    JOIN classicmodels.customers c ON c.customerNumber = o.customerNumber;

-- Customer service can now run:
SELECT
    city
FROM
    classicmodels.offices
UNION -- UNION removes duplicates
SELECT
    city
FROM
    classicmodels.customers;

-- 12 Index on orders.orderDate
CREATE INDEX IF NOT EXISTS idx_orders_orderdate ON classicmodels.orders (orderDate);

-- 13 Products whose buyPrice is above the average priceEach sold
SELECT
    *
FROM
    classicmodels.products
WHERE
    buyPrice > (
        SELECT
            AVG(priceEach)
        FROM
            classicmodels.orderdetails
    );

-- 14 Customers that have at least one payment over 50 000
SELECT
    *
FROM
    classicmodels.customers
WHERE
    customerNumber IN (
        SELECT
            customerNumber
        FROM
            classicmodels.payments
        WHERE
            amount > 50000
    );

-- 15 Cities that appear either in offices or in customers
SELECT
    city
FROM
    classicmodels.offices
UNION -- UNION removes duplicates
SELECT
    city
FROM
    classicmodels.customers;