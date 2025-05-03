CREATE TABLE
  animals (
    id SERIAL PRIMARY KEY,
    arrival_ts TIMESTAMPTZ NOT NULL,
    previous_owner VARCHAR(255),
    fur_color VARCHAR(100) NOT NULL,
    eye_color VARCHAR(100) NOT NULL,
    weight_kg NUMERIC(5, 2) NOT NULL,
    length_cm NUMERIC(5, 1),
    height_cm NUMERIC(5, 1),
    health_issues TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
  );

-- 1) Ensure weight is positive
ALTER TABLE animals ADD CONSTRAINT chk_weight_positive CHECK (weight_kg > 0);

-- 2) Arrival date can’t be in the future
ALTER TABLE animals ADD CONSTRAINT chk_arrival_not_future CHECK (arrival_ts <= CURRENT_TIMESTAMP);

-- 3) Fast queries by arrival date
CREATE INDEX idx_animals_arrival ON animals (arrival_ts);

/* ──────────────────────────────────────────
1) INSERT FIVE SAMPLE ROWS
(omit animal_id to let AUTO_INCREMENT / SERIAL fill it)
────────────────────────────────────────── */
INSERT INTO
  animals (
    arrival_ts,
    previous_owner,
    fur_color,
    eye_color,
    weight_kg,
    length_cm,
    height_cm,
    health_issues,
    notes
  )
VALUES
  -- 1  Domestic cat
  (
    '2025-05-02 09:15:00',
    'Alice Johnson',
    'Brown',
    'Hazel',
    4.10,
    NULL,
    30.5,
    'Requires daily insulin shots',
    'Very calm cat'
  ),
  -- 2  Stray ferret
  (
    '2025-05-02 11:45:00',
    NULL,
    'Black',
    'Green',
    2.30,
    45.0,
    NULL,
    NULL,
    'Found near Riverside Park'
  ),
  -- 3  Labrador retriever
  (
    '2025-05-03 08:20:00',
    'Carlos Ramirez',
    'White',
    'Brown',
    5.60,
    NULL,
    42.0,
    'Allergic dermatitis',
    'Needs grain-free diet'
  ),
  -- 4  Mini‑lop rabbit
  (
    '2025-05-03 10:05:00',
    'Debbie Smith',
    'Brown',
    'Brown',
    1.20,
    25.0,
    NULL,
    'Needs medication for heartworm',
    'Bonded pair candidate'
  ),
  -- 5  Schnauzer
  (
    '2025-05-03 12:30:00',
    'Evan Lee',
    'Grey',
    'Blue',
    3.70,
    NULL,
    35.0,
    NULL,
    NULL
  );

/* ──────────────────────────────────────────
2) SELECT EXAMPLES
────────────────────────────────────────── */
/* a) Exact‑match on former owner */
SELECT
  *
FROM
  animals
WHERE
  previous_owner = 'Carlos Ramirez';

/* b) Any pet with brown fur OR brown eyes */
SELECT
  *
FROM
  animals
WHERE
  fur_color = 'Brown'
  OR eye_color = 'Brown';

/* c) Weight larger than 3 200 g  (3.2 kg) */
SELECT
  *
FROM
  animals
WHERE
  weight_kg > 3.2;

/* d) Word appears anywhere in the special‑needs field
(case‑insensitive: ILIKE works in Postgres; use LOWER() or COLLATE in MySQL) */
-- PostgreSQL
SELECT
  *
FROM
  animals
WHERE
  health_issues ILIKE '%medication%';

-- MySQL (one option)
SELECT
  *
FROM
  animals
WHERE
  LOWER(health_issues) LIKE '%medication%';