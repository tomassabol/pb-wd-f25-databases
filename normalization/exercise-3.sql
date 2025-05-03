/* ──────────────────────────────────────────────────
Fresh start
────────────────────────────────────────────────── */
DROP TABLE IF EXISTS login_attempt;

DROP TABLE IF EXISTS app_user;

DROP TABLE IF EXISTS address;

/* ──────────────────────────────────────────────────
Create tables
────────────────────────────────────────────────── */
CREATE TABLE
    address (
        address_id SERIAL PRIMARY KEY,
        street TEXT NOT NULL,
        city TEXT NOT NULL,
        zipcode TEXT NOT NULL,
        country TEXT NOT NULL
    );

CREATE TABLE
    app_user (
        user_id SERIAL PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        passwd_hash TEXT NOT NULL,
        address_id INTEGER NOT NULL REFERENCES address (address_id) ON DELETE RESTRICT
    );

CREATE TABLE
    login_attempt (
        attempt_id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES app_user (user_id) ON DELETE CASCADE, -- drop history if account removed
        attempted_pw TEXT NOT NULL,
        success BOOLEAN NOT NULL,
        attempt_ts TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

/* ──────────────────────────────────────────────────
Insert data
────────────────────────────────────────────────── */
INSERT INTO
    address (street, city, zipcode, country)
VALUES
    ('Hansensvej 15', 'Hellerup', '2900', 'Denmark'), -- id 1
    (
        'Jensensvej 10 1.TH',
        'København NV',
        '2400',
        'Denmark'
    );

INSERT INTO
    app_user (username, passwd_hash, address_id)
VALUES
    ('CK', '1234', 1),
    ('PJ', 'PJ1', 2),
    ('PK', 'PJ1', 2);

INSERT INTO
    login_attempt (user_id, attempted_pw, success)
VALUES
    -- CK’s three tries
    (
        (
            SELECT
                user_id
            FROM
                app_user
            WHERE
                username = 'CK'
        ),
        '1235',
        FALSE
    ),
    (
        (
            SELECT
                user_id
            FROM
                app_user
            WHERE
                username = 'CK'
        ),
        '1245',
        FALSE
    ),
    (
        (
            SELECT
                user_id
            FROM
                app_user
            WHERE
                username = 'CK'
        ),
        '1234',
        TRUE
    ),
    -- PK’s single failed try
    (
        (
            SELECT
                user_id
            FROM
                app_user
            WHERE
                username = 'PK'
        ),
        'PJ1',
        FALSE
    ),
    -- PJ’s successful try
    (
        (
            SELECT
                user_id
            FROM
                app_user
            WHERE
                username = 'PJ'
        ),
        'PJ1',
        TRUE
    );

/* ──────────────────────────────────────────────────
Query data
────────────────────────────────────────────────── */
/* A) All users with their (deduplicated) address */
SELECT
    u.username,
    a.street,
    a.city,
    a.zipcode,
    a.country
FROM
    app_user u
    JOIN address a USING (address_id)
ORDER BY
    u.username;

/* B) Login success‑rate per user */
SELECT
    u.username,
    COUNT(*) AS total_attempts,
    SUM(
        CASE
            WHEN l.success THEN 1
            ELSE 0
        END
    ) AS successes,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN l.success THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_pct
FROM
    app_user u
    JOIN login_attempt l USING (user_id)
GROUP BY
    u.username
ORDER BY
    success_pct DESC;

/* C) Show last attempt per user */
SELECT DISTINCT
    ON (u.username) u.username,
    l.success,
    l.attempt_ts
FROM
    app_user u
    JOIN login_attempt l USING (user_id)
ORDER BY
    u.username,
    l.attempt_ts DESC;