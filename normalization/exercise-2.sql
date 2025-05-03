/* ──────────────────────────────────────────────────
Fresh start
────────────────────────────────────────────────── */
DROP TABLE IF EXISTS student_grade;

DROP TABLE IF EXISTS subject;

DROP TABLE IF EXISTS student;

/* ──────────────────────────────────────────────────
Create tables
────────────────────────────────────────────────── */
CREATE TABLE
    student (
        student_id SERIAL PRIMARY KEY,
        full_name VARCHAR(120) NOT NULL UNIQUE
    );

CREATE TABLE
    subject (
        subject_id SERIAL PRIMARY KEY,
        subject_name VARCHAR(80) NOT NULL UNIQUE
    );

CREATE TABLE
    student_grade (
        student_id INTEGER NOT NULL REFERENCES student (student_id) ON DELETE CASCADE,
        subject_id INTEGER NOT NULL REFERENCES subject (subject_id) ON DELETE CASCADE,
        grade_value INTEGER NOT NULL CHECK (grade_value BETWEEN 0 AND 12),
        PRIMARY KEY (student_id, subject_id)
    );

/* ──────────────────────────────────────────────────
Insert data
────────────────────────────────────────────────── */
INSERT INTO
    subject (subject_name)
VALUES
    ('Mathematics'),
    ('Danish'),
    ('English'),
    ('Physics'),
    ('Biology');

/* ──────────────────────────────────────────────────
Insert data
────────────────────────────────────────────────── */
INSERT INTO
    student (full_name)
VALUES
    ('Peter Smith'),
    ('John Petersen'),
    ('Helen Hunt');

INSERT INTO
    student_grade (student_id, subject_id, grade_value)
SELECT
    s.student_id,
    sub.subject_id,
    g
FROM
    (
        VALUES
            -- full_name,   subject,       grade
            ('Peter Smith', 'Mathematics', 10),
            ('Peter Smith', 'Danish', 7),
            ('Peter Smith', 'English', 12),
            ('John Petersen', 'Physics', 4),
            ('John Petersen', 'Biology', 2),
            ('John Petersen', 'English', 0),
            ('Helen Hunt', 'Biology', 7),
            ('Helen Hunt', 'Danish', 2),
            ('Helen Hunt', 'Physics', 12)
    ) AS raw (full_name, subject_name, g)
    JOIN student AS s ON s.full_name = raw.full_name
    JOIN subject AS sub ON sub.subject_name = raw.subject_name;

/* ──────────────────────────────────────────────────
Query data
────────────────────────────────────────────────── */
/* A) Full grade report per student */
SELECT
    st.full_name,
    jsonb_object_agg (
        sb.subject_name,
        sg.grade_value
        ORDER BY
            sb.subject_name
    ) AS grades
FROM
    student_grade sg
    JOIN student st USING (student_id)
    JOIN subject sb USING (subject_id)
GROUP BY
    st.student_id
ORDER BY
    st.full_name;

/* B) Who scored ≥10 in any subject? */
SELECT
    st.full_name,
    sb.subject_name,
    sg.grade_value
FROM
    student_grade sg
    JOIN student st USING (student_id)
    JOIN subject sb USING (subject_id)
WHERE
    sg.grade_value >= 10
ORDER BY
    sg.grade_value DESC;

/* C) Average grade per subject */
SELECT
    sb.subject_name,
    ROUND(AVG(sg.grade_value), 2) AS avg_grade
FROM
    student_grade sg
    JOIN subject sb USING (subject_id)
GROUP BY
    sb.subject_name
ORDER BY
    avg_grade DESC;