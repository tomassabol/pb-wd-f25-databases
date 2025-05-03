/* ──────────────────────────────────────────────────
Fresh start
────────────────────────────────────────────────── */
DROP TABLE IF EXISTS employee_skill;

DROP TABLE IF EXISTS skill;

DROP TABLE IF EXISTS employee;

/* ──────────────────────────────────────────────────
Create tables
────────────────────────────────────────────────── */
CREATE TABLE
    employee (
        employee_id SERIAL PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL UNIQUE
    );

CREATE TABLE
    skill (
        skill_id SERIAL PRIMARY KEY,
        skill_name VARCHAR(100) NOT NULL UNIQUE
    );

CREATE TABLE
    employee_skill (
        employee_id INTEGER NOT NULL REFERENCES employee (employee_id) ON DELETE CASCADE,
        skill_id INTEGER NOT NULL REFERENCES skill (skill_id) ON DELETE CASCADE,
        PRIMARY KEY (employee_id, skill_id)
    );

/* ──────────────────────────────────────────────────
Insert data
────────────────────────────────────────────────── */
INSERT INTO
    skill (skill_name)
VALUES
    ('Java'),
    ('Python'),
    ('SQL'),
    ('C++'),
    ('HTML');

INSERT INTO
    employee (first_name)
VALUES
    ('John'),
    ('Mary'),
    ('Bob');

INSERT INTO
    employee_skill (employee_id, skill_id)
SELECT
    e.employee_id,
    s.skill_id
FROM
    (
        VALUES
            ('John', 'Java'),
            ('John', 'Python'),
            ('John', 'SQL'),
            ('Mary', 'C++'),
            ('Mary', 'Python'),
            ('Bob', 'Java'),
            ('Bob', 'SQL'),
            ('Bob', 'HTML')
    ) AS x (emp_name, skill_name)
    JOIN employee AS e ON e.first_name = x.emp_name
    JOIN skill AS s ON s.skill_name = x.skill_name;

/* ──────────────────────────────────────────────────
Query data
────────────────────────────────────────────────── */
SELECT
    e.first_name
FROM
    employee_skill es
    JOIN employee e ON e.employee_id = es.employee_id
    JOIN skill s ON s.skill_id = es.skill_id
WHERE
    s.skill_name = 'Python';

/* Skill matrix */
SELECT
    e.first_name,
    STRING_AGG (
        s.skill_name,
        ', '
        ORDER BY
            s.skill_name
    ) AS skills
FROM
    employee e
    JOIN employee_skill es USING (employee_id)
    JOIN skill s USING (skill_id)
GROUP BY
    e.employee_id
ORDER BY
    e.first_name;