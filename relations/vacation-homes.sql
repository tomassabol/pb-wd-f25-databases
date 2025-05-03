-- Fresh start
DROP TABLE IF EXISTS reservation_huts;

DROP TABLE IF EXISTS reservations;

DROP TABLE IF EXISTS huts;

DROP TABLE IF EXISTS customers;

-- Create tables
CREATE TABLE
    customers (
        id SERIAL PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE
    );

CREATE TABLE
    huts (
        id SERIAL PRIMARY KEY,
        hut_name VARCHAR(150) NOT NULL,
        location TEXT,
        capacity SMALLINT NOT NULL,
        nightly_rate NUMERIC(8, 2) NOT NULL,
        notes TEXT
    );

CREATE TABLE
    reservations (
        id SERIAL PRIMARY KEY,
        customer_id INTEGER NOT NULL,
        start_ts TIMESTAMPTZ NOT NULL,
        end_ts TIMESTAMPTZ NOT NULL,
        CONSTRAINT fk_res_customer FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE RESTRICT, -- can’t drop a customer with bookings
        CHECK (end_ts > start_ts)
    );

/* ──────────────────────────────────────────────────
2)  Junction table for the many‑to‑many link
────────────────────────────────────────────────── */
CREATE TABLE
    reservation_huts (
        reservation_id INTEGER NOT NULL,
        hut_id INTEGER NOT NULL,
        PRIMARY KEY (reservation_id, hut_id),
        FOREIGN KEY (reservation_id) REFERENCES reservations (id) ON DELETE CASCADE, -- delete child rows if reservation goes
        FOREIGN KEY (hut_id) REFERENCES huts (id) ON DELETE RESTRICT -- refuse to delete a hut that has bookings
    );

-- Insert data
INSERT INTO
    customers (first_name, last_name, email)
VALUES
    ('Alice', 'Green', 'alice.green@example.com'),
    ('Brian', 'Hansen', 'brian.hansen@example.com'),
    ('Clara', 'Iversen', 'clara.iversen@example.com'),
    ('David', 'Jensen', 'david.jensen@example.com'),
    ('Emma', 'Knudsen', 'emma.knudsen@example.com');

INSERT INTO
    huts (hut_name, location, capacity, nightly_rate, notes)
VALUES
    (
        'Alpine Cabin',
        'Østfold mountains',
        4,
        950.00,
        'Wood‑burning stove'
    ),
    (
        'Seaside Lodge',
        'Bornholm coast',
        6,
        1250.00,
        'Sea view'
    ),
    ('Forest Retreat', 'Nordjylland', 2, 800.00, NULL),
    (
        'Lake House',
        'Silkeborg lakes',
        8,
        1750.00,
        'Includes canoe'
    ),
    (
        'Meadow Cottage',
        'Fyn countryside',
        5,
        1050.00,
        'Pet‑friendly'
    );

-- two reservations, each booking multiple huts
INSERT INTO
    reservations (customer_id, start_ts, end_ts)
VALUES
    (1, '2025-07-05 15:00+02', '2025-07-10 11:00+02'), -- id = 1
    (3, '2025-08-01 16:00+02', '2025-08-05 10:00+02');

-- id = 2
INSERT INTO
    reservation_huts (reservation_id, hut_id)
VALUES
    -- Alice’s booking
    (1, 1),
    (1, 3),
    -- Clara’s booking
    (2, 2),
    (2, 5);

-- Query data
-- A) Which customers have booked a specific hut (e.g. hut_id = 1)?
SELECT
    c.first_name,
    c.last_name,
    h.*
FROM
    huts AS h
    JOIN reservation_huts AS rh ON rh.hut_id = h.id
    JOIN reservations AS r ON r.id = rh.reservation_id
    JOIN customers AS c ON c.id = r.customer_id
WHERE
    h.id = 1;

-- B) Which huts has a specific customer (e.g. customer_id = 3) booked?
SELECT
    h.*,
    r.start_ts,
    r.end_ts
FROM
    customers AS c
    JOIN reservations AS r ON r.customer_id = c.id
    JOIN reservation_huts AS rh ON rh.reservation_id = r.id
    JOIN huts AS h ON h.id = rh.hut_id
WHERE
    c.id = 3;

-- ← change to the customer you’re checking
-- C) Which huts are booked in a given period?
--    (example: any overlap with 2025‑08‑02 → 2025‑08‑04)
SELECT DISTINCT
    h.*
FROM
    huts AS h
    JOIN reservation_huts AS rh ON rh.hut_id = h.id
    JOIN reservations AS r ON r.id = rh.reservation_id
WHERE
    r.start_ts < TIMESTAMPTZ '2025-08-04 00:00+02'
    AND r.end_ts > TIMESTAMPTZ '2025-08-02 00:00+02';