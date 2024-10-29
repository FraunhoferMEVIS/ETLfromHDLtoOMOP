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
    DISTINCT ON (vers.plz) vers.plz :: int AS location_id,
    NULL AS address_1,
    NULL AS address_2,
    NULL AS city,
    NULL AS state,
    vers.plz AS zip,
    NULL AS county,
    NULL AS location_source_value,
    4330424 AS country_concept_id,
    NULL AS country_source_value,
    NULL AS latitude,
    NULL AS longitude
FROM
    versicherte.vers 
WHERE 
    vers.plz IS NOT NULL
    AND vers.plz !=''
ON CONFLICT (location_id) DO NOTHING;