with tmp as(
 SELECT
        versq.arbnr,
        LAST_VALUE(versq.geschlecht) OVER(PARTITION BY versq.arbnr ORDER BY versq.versq DESC) as latest_gender,
        vers.gebjahr AS year_of_birth,
        vers.plz :: int as plz
        FROM  versicherte.versq )
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
    DISTINCT ON (vers.arbnr) vers.arbnr AS person_id,
    case
        tmp.latest_gender
        when 1 then 8532 --female
        when 2 then 8507 --male
        else 0
    end AS gender_concept_id,
    case
        tmp.latest_gender
        when 1 then '1: Female'
        when 2 then '2: Male'
        when 3 then '3: Missing'
        when 4 then '4: Divers'
        else tmp.latest_gender :: varchar
    end AS gender_source_value,
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
with tmp as(
 SELECT
        versq.arbnr,
        LAST_VALUE(versq.geschlecht) OVER(PARTITION BY versq.arbnr ORDER BY versq.versq DESC) as latest_gender,
        vers.gebjahr as year_of_birth,
        vers.plz :: int as plz
        FROM  versicherte.versq )
    year_of_birth = tmp.year_of_birth,
    gender_concept_id = case
        tmp.latest_gender
        when 1 then 8532 --female
        when 2 then 8507 --male
        else 0
    end,
    location_id = plz
    gender_source_value = case
        tmp.latest_gender
        when 1 then '1: Female'
        when 2 then '2: Male'
        when 3 then '3: Missing'
        when 4 then '4: Divers'
        else tmp.latest_gender :: varchar
    end
FROM
    tmp ;
