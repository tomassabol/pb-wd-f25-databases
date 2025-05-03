CREATE TYPE emp_group_enum AS ENUM (
    'Human Resources',
    'IT',
    'Accounting',
    'Marketing',
    'Research and Development',
    'Production'
);

CREATE TABLE
    employees (
        id SERIAL PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        phone_number VARCHAR(30),
        hire_date DATE NOT NULL,
        salary_dkk NUMERIC(10, 2) NOT NULL,
        emp_group emp_group_enum NOT NULL,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

/* ─────────────────────────────────────────────
INSERT FIVE SAMPLE EMPLOYEES
───────────────────────────────────────────── */
INSERT INTO
    employees (
        first_name,
        last_name,
        email,
        phone_number,
        hire_date,
        salary_dkk,
        emp_group
    )
VALUES
    (
        'Laura',
        'Nguyen',
        'laura.nguyen@example.com',
        '+45-55-1234-5678',
        '2022-04-14',
        65000.00,
        'Marketing'
    ),
    (
        'Jamal',
        'Owens',
        'jamal.owens@example.com',
        '+45-55-9876-5432',
        '2023-01-10',
        72000.00,
        'IT'
    ),
    (
        'Franz',
        'Keller',
        'franz.keller@example.com',
        '+45-55-1234-5678',
        '2021-09-01',
        54000.00,
        'Accounting'
    ),
    (
        'Amina',
        'Darzi',
        'amina.darzi@example.com',
        '+45-55-1234-5678',
        '2024-07-22',
        88000.00,
        'Research and Development'
    ),
    (
        'Diego',
        'Santos',
        'diego.santos@example.com',
        NULL,
        '2020-12-05',
        60000.00,
        'Human Resources'
    );

INSERT INTO
    employees (
        first_name,
        last_name,
        email,
        phone_number,
        hire_date,
        salary_dkk,
        emp_group
    )
VALUES
    -- will match the “name starts with A” query
    (
        'Anton',
        'Bach',
        'anton.bach@example.com',
        '+45-55-1234-5678',
        '2022-06-01',
        540000.00,
        'IT'
    ),
    -- will match the “Accounting & >500 000 DKK” query
    (
        'Astrid',
        'Larsen',
        'astrid.larsen@example.com',
        '+45-55-9876-5432',
        '2023-02-15',
        510000.00,
        'Accounting'
    );

/* a) All employees whose first name starts with “A” (case‑sensitive) */
/*     → case‑insensitive:      WHERE first_name ILIKE 'a%' */
SELECT
    *
FROM
    employees
WHERE
    first_name LIKE 'A%';

/* b) Accounting staff with salary > 500 000 DKK
ordered from lowest to highest salary            */
SELECT
    *
FROM
    employees
WHERE
    emp_group = 'Accounting'
    AND salary_dkk > 500000 -- treat salary column as DKK for this query
ORDER BY
    salary_dkk ASC;