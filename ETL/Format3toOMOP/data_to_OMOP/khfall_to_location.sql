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
    DISTINCT ON (khfall.khregkz) khfall.khregkz  AS location_id,
    NULL AS address_1,
    NULL AS address_2,
    NULL AS city,
    NULL AS state,
    NULL AS zip,
    NULL AS county,
    khfall.khregkz AS location_source_value,
    NULL AS country_concept_id,
    NULL AS country_source_value,
    NULL AS latitude,
    NULL AS longitude
FROM
    stationaere_faelle.khfall 
WHERE 
    khfall.khregkz IS NOT NULL
ON CONFLICT (location_id) DO NOTHING;

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
    DISTINCT ON (khfall.veranlasskhregknz) khfall.veranlasskhregknz  AS location_id,
    NULL AS address_1,
    NULL AS address_2,
    NULL AS city,
    NULL AS state,
    NULL AS zip,
    NULL AS county,
    khfall.veranlasskhregknz AS location_source_value,
    NULL AS country_concept_id,
    NULL AS country_source_value,
    NULL AS latitude,
    NULL AS longitude
FROM
    stationaere_faelle.khfall
WHERE
    khfall.veranlasskhregknz IS NOT NULL
ON CONFLICT (location_id) DO NOTHING;