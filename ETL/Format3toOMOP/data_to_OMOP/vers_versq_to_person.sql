WITH tmp AS (
    SELECT
        versq.psid,
        LAST_VALUE(versq.geschlecht) OVER(PARTITION BY versq.psid ORDER BY versq.versq DESC) AS latest_gender,
        vers.gebjahr AS year_of_birth,
        vers.plz::int AS plz
    FROM 
    versicherte.vers vers
    LEFT JOIN  versicherte.versq versq ON vers.psid = versq.psid
)
INSERT INTO
    {target_schema}.person (
        person_id,
        gender_concept_id,
        gender_source_value,
        gender_source_concept_id,
        year_of_birth,
        location_id,
        month_of_birth,
        day_of_birth,
        birth_datetime,
        race_concept_id,
        ethnicity_concept_id,
        provider_id,
        care_site_id,
        person_source_value,
        race_source_value,
        race_source_concept_id,
        ethnicity_source_value,
        ethnicity_source_concept_id
    )
SELECT
    DISTINCT ON (tmp.psid) tmp.psid AS person_id,
    CASE
        WHEN tmp.latest_gender = 1 THEN 8532 --female
        WHEN tmp.latest_gender = 2 THEN 8507 --male
        ELSE 0
    END AS gender_concept_id,
    CASE
        WHEN tmp.latest_gender = 1 THEN '1: Female'
        WHEN tmp.latest_gender = 2 THEN '2: Male'
        WHEN tmp.latest_gender = 3 THEN '3: Missing'
        WHEN tmp.latest_gender = 4 THEN '4: Divers'
        ELSE tmp.latest_gender::varchar
    END AS gender_source_value,
    tmp.latest_gender AS gender_source_concept_id,
    tmp.year_of_birth AS year_of_birth,
    tmp.plz AS location_id,
    NULL AS month_of_birth,
    NULL AS day_of_birth,
    NULL AS birth_datetime,
    0 AS race_concept_id,
    0 AS ethnicity_concept_id,
    NULL AS provider_id,
    NULL AS care_site_id,
    NULL AS person_source_value,
    NULL AS race_source_value,
    NULL AS race_source_concept_id,
    NULL AS ethnicity_source_value,
    NULL AS ethnicity_source_concept_id
FROM
    tmp
ON CONFLICT (person_id)
DO UPDATE SET 
    year_of_birth = EXCLUDED.year_of_birth,
    gender_concept_id = CASE
        WHEN EXCLUDED.latest_gender = 1 THEN 8532 --female
        WHEN EXCLUDED.latest_gender = 2 THEN 8507 --male
        ELSE 0
    END,
    location_id = EXCLUDED.plz,
    gender_source_value = CASE
        WHEN EXCLUDED.latest_gender = 1 THEN '1: Female'
        WHEN EXCLUDED.latest_gender = 2 THEN '2: Male'
        WHEN EXCLUDED.latest_gender = 3 THEN '3: Missing'
        WHEN EXCLUDED.latest_gender = 4 THEN '4: Divers'
        ELSE EXCLUDED.latest_gender::varchar
    END
;