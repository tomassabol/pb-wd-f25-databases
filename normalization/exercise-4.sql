/* ──────────────────────────────────────────────────
Fresh start
────────────────────────────────────────────────── */
DROP TABLE IF EXISTS checkout;

DROP TABLE IF EXISTS borrower;

DROP TABLE IF EXISTS book_author;

DROP TABLE IF EXISTS author;

DROP TABLE IF EXISTS book;

/* ──────────────────────────────────────────────────
Create tables
────────────────────────────────────────────────── */
CREATE TABLE
    book (
        book_id SERIAL PRIMARY KEY,
        title TEXT NOT NULL,
        publication_year INTEGER,
        publisher TEXT,
        isbn TEXT UNIQUE
    );

CREATE TABLE
    author (
        author_id SERIAL PRIMARY KEY,
        author_name TEXT NOT NULL UNIQUE
    );

CREATE TABLE
    book_author (
        book_id INTEGER NOT NULL REFERENCES book (book_id) ON DELETE CASCADE,
        author_id INTEGER NOT NULL REFERENCES author (author_id) ON DELETE CASCADE,
        PRIMARY KEY (book_id, author_id)
    );

CREATE TABLE
    borrower (
        borrower_id SERIAL PRIMARY KEY,
        full_name TEXT NOT NULL,
        address TEXT
    );

CREATE TABLE
    checkout (
        checkout_id SERIAL PRIMARY KEY,
        borrower_id INTEGER NOT NULL REFERENCES borrower (borrower_id) ON DELETE RESTRICT,
        book_id INTEGER NOT NULL REFERENCES book (book_id) ON DELETE RESTRICT,
        checkout_date DATE NOT NULL,
        return_date DATE
    );

/* ──────────────────────────────────────────────────
Insert data
────────────────────────────────────────────────── */
/* 1) book + authors */
INSERT INTO
    book (title, publication_year, publisher, isbn)
VALUES
    ('The Great Gatsby', 1925, 'Scribner', '123456789');

WITH
    a (name) AS (
        VALUES
            ('F. Scott Fitzgerald'),
            ('William Faulkner')
    )
INSERT INTO
    author (author_name)
SELECT
    name
FROM
    a ON CONFLICT (author_name) DO NOTHING;

-- avoids dupes if you rerun
INSERT INTO
    book_author (book_id, author_id)
SELECT
    b.book_id,
    a.author_id
FROM
    book b
    CROSS JOIN author a
WHERE
    b.title = 'The Great Gatsby'
    AND a.author_name IN ('F. Scott Fitzgerald', 'William Faulkner');

/* 2) borrower */
INSERT INTO
    borrower (full_name, address)
VALUES
    ('John Smith', '123 Main St, Anytown');

/* 3) checkout record */
INSERT INTO
    checkout (borrower_id, book_id, checkout_date, return_date)
SELECT
    br.borrower_id,
    bk.book_id,
    '2023-02-05',
    '2023-03-05'
FROM
    borrower br,
    book bk
WHERE
    br.full_name = 'John Smith'
    AND bk.title = 'The Great Gatsby';

/* ──────────────────────────────────────────────────
Query data
────────────────────────────────────────────────── */
/* A) who has borrowed each book (with dates) */
SELECT
    b.title,
    br.full_name,
    c.checkout_date,
    c.return_date
FROM
    checkout c
    JOIN book b USING (book_id)
    JOIN borrower br USING (borrower_id);

/* B) list books with all their authors */
SELECT
    b.title,
    string_agg (
        a.author_name,
        ', '
        ORDER BY
            a.author_name
    ) AS authors
FROM
    book b
    JOIN book_author ba USING (book_id)
    JOIN author a USING (author_id)
GROUP BY
    b.book_id;