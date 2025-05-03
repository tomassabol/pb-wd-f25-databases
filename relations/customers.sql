-- Create tables
CREATE TABLE
    customers (
        id SERIAL PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE,
        phone_number VARCHAR(30),
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE
    reservations (
        id SERIAL PRIMARY KEY,
        customer_id INTEGER NOT NULL,
        reservation_ts TIMESTAMPTZ NOT NULL,
        party_size SMALLINT NOT NULL,
        notes TEXT,
        CONSTRAINT fk_res_customer FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE RESTRICT
    );

-- Insert data
INSERT INTO
    reservations (customer_id, reservation_ts, party_size, notes)
VALUES
    (1, '2025-05-05 18:30:00+02:00', 2, 'Window seat'),
    (2, '2025-05-06 19:00:00+02:00', 4, 'Birthday'),
    (3, '2025-05-07 20:15:00+02:00', 3, NULL),
    (
        4,
        '2025-05-08 17:45:00+02:00',
        6,
        'High chair needed'
    ),
    (5, '2025-05-09 18:00:00+02:00', 2, 'Anniversary');

-- Query data
SELECT
    customers.*,
    reservations.*
FROM
    customers AS customers
    JOIN reservations AS reservations ON reservations.id = customers.id
WHERE
    customers.id = 1;

SELECT
    customers.*,
    reservations.*
FROM
    customers AS customers
    JOIN reservations AS reservations ON reservations.id = customers.id
WHERE
    customers.id = 1;

SELECT
    customers.*
FROM
    customers
    JOIN reservations ON reservations.id = customers.id
WHERE
    customers.id = 1;

SELECT
    customers.*
FROM
    customers
    JOIN reservations ON reservations.id = customers.id
WHERE
    customers.first_name LIKE 'A%'
ORDER BY
    customers.last_name DESC,
    customers.first_name DESC;