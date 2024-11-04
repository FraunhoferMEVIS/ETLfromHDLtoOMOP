INSERT INTO
    {target_schema}.location (
        location_id,
        address_1,
        address_2,
        city,
        state,
        zip,
        county,
        location_source_value,
        country_concept_id,
        country_source_value,
        latitude,
        longitude
    )
SELECT
    DISTINCT ON (rez.bsnrvoregknz) rez.bsnrvoregknz :: int AS location_id,
    NULL AS address_1,
    NULL AS address_2,
    NULL AS city,
    NULL AS state,
    NULL AS zip,
    NULL AS county,
    rez.bsnrvoregknz AS location_source_value,
    NULL AS country_concept_id,
    NULL AS country_source_value,
    NULL AS latitude,
    NULL AS longitude
FROM
    arzneimittel.rez rez 
WHERE
    rez.bsnrvoregknz IS NOT NULL
ON CONFLICT (location_id) DO NOTHING;