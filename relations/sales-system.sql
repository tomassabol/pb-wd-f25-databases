/* ──────────────────────────────────────────────────
Fresh start
────────────────────────────────────────────────── */
DROP TABLE IF EXISTS invoice_lines;

DROP TABLE IF EXISTS invoices;

DROP TABLE IF EXISTS order_lines;

DROP TABLE IF EXISTS orders;

DROP TABLE IF EXISTS products;

DROP TABLE IF EXISTS client_phones;

DROP TABLE IF EXISTS clients;

/* ──────────────────────────────────────────────────
Create tables
────────────────────────────────────────────────── */
CREATE TABLE
    clients (
        client_id SERIAL PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        fax_number VARCHAR(30),
        email VARCHAR(255) UNIQUE
    );

CREATE TABLE
    client_phones (
        client_id INTEGER NOT NULL REFERENCES clients (client_id) ON DELETE CASCADE,
        phone_no VARCHAR(30) NOT NULL,
        phone_type VARCHAR(20),
        PRIMARY KEY (client_id, phone_no)
    );

CREATE TABLE
    products (
        product_id SERIAL PRIMARY KEY,
        product_name VARCHAR(150) NOT NULL,
        unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
    );

CREATE TABLE
    orders (
        order_id SERIAL PRIMARY KEY,
        client_id INTEGER NOT NULL REFERENCES clients (client_id) ON DELETE RESTRICT,
        order_date DATE NOT NULL DEFAULT CURRENT_DATE
    );

CREATE TABLE
    order_lines (
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL CHECK (quantity > 0),
        PRIMARY KEY (order_id, product_id),
        FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE RESTRICT
    );

CREATE TABLE
    invoices (
        invoice_id SERIAL PRIMARY KEY,
        order_id INTEGER NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
        invoice_date DATE NOT NULL,
        payment_date DATE,
        payment_method VARCHAR(50)
    );

CREATE TABLE
    invoice_lines (
        invoice_id INTEGER NOT NULL,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL CHECK (quantity > 0),
        PRIMARY KEY (invoice_id, order_id, product_id),
        FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id) ON DELETE CASCADE,
        FOREIGN KEY (order_id, product_id) REFERENCES order_lines (order_id, product_id) ON DELETE RESTRICT
    );

/* ──────────────────────────────────────────────────
Insert data
────────────────────────────────────────────────── */
INSERT INTO
    clients (first_name, last_name, fax_number, email)
VALUES
    (
        'Alice',
        'Green',
        '+45-555-0101',
        'alice.green@example.com'
    ),
    (
        'Brian',
        'Hansen',
        NULL,
        'brian.hansen@example.com'
    ),
    (
        'Clara',
        'Iversen',
        '+45-555-0201',
        'clara.iversen@example.com'
    );

INSERT INTO
    client_phones
VALUES
    (1, '+45-555-0101', 'mobile'),
    (1, '+45-555-0102', 'landline'),
    (2, '+45-555-0201', 'mobile');

INSERT INTO
    products (product_name, unit_price)
VALUES
    ('Widget A', 25.00),
    ('Widget B', 40.00),
    ('Gadget C', 15.50),
    ('Service D', 99.99);

INSERT INTO
    orders (client_id, order_date)
VALUES
    (1, '2025-05-01'), -- order_id = 1
    (2, '2025-05-02'), -- order_id = 2
    (1, '2025-05-03');

INSERT INTO
    order_lines
VALUES
    (1, 1, 3), -- order 1 : 3 × Widget A
    (1, 3, 5), --           5 × Gadget C
    (2, 2, 2), -- order 2 : 2 × Widget B
    (3, 4, 1), -- order 3 : 1 × Service D
    (3, 1, 2);

--           2 × Widget A
/* ---- invoices & invoice_lines ------------------------------------- */
INSERT INTO
    invoices (order_id, invoice_date, payment_method)
VALUES
    (1, '2025-05-02', 'Credit card'), -- invoice_id = 1
    (1, '2025-05-04', 'Bank transfer'), -- invoice_id = 2  (split billing)
    (2, '2025-05-03', 'Credit card'), -- invoice_id = 3
    (3, '2025-05-04', 'MobilePay');

INSERT INTO
    invoice_lines
VALUES
    (1, 1, 1, 1), -- invoice 1: 1 × Widget A
    (1, 1, 3, 2), --            2 × Gadget C
    (2, 1, 1, 2), -- invoice 2: 2 × Widget A
    (2, 1, 3, 3), --            3 × Gadget C
    /* order 2 fully on one invoice */
    (3, 2, 2, 2),
    /* order 3 fully on one invoice */
    (4, 3, 4, 1),
    (4, 3, 1, 2);

/* (Optionally mark some invoices paid) */
UPDATE invoices
SET
    payment_date = '2025-05-06'
WHERE
    invoice_id IN (1, 3);

/* ──────────────────────────────────────────────────
Query data
────────────────────────────────────────────────── */
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name
FROM
    orders AS o
    JOIN clients AS c ON c.client_id = o.client_id
ORDER BY
    o.order_id;

/* Q2. Show each order’s total value (simple sum) */
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(ol.quantity * p.unit_price) AS order_total
FROM
    orders AS o
    JOIN clients AS c ON c.client_id = o.client_id
    JOIN order_lines AS ol ON ol.order_id = o.order_id
    JOIN products AS p ON p.product_id = ol.product_id
GROUP BY
    o.order_id,
    customer_name
ORDER BY
    order_total DESC;

/* Q3. Outstanding invoices (not yet paid) */
SELECT
    i.invoice_id,
    i.invoice_date,
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    i.payment_method
FROM
    invoices AS i
    JOIN orders AS o ON o.order_id = i.order_id
    JOIN clients AS c ON c.client_id = o.client_id
WHERE
    i.payment_date IS NULL
ORDER BY
    i.invoice_date;

/* Q4. Best‑selling products by units ordered */
SELECT
    p.product_name,
    SUM(ol.quantity) AS units_sold
FROM
    order_lines AS ol
    JOIN products AS p ON p.product_id = ol.product_id
GROUP BY
    p.product_name
ORDER BY
    units_sold DESC;