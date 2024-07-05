/*
 SA999 - Amtlicher Gemeindeschlüssel to location 
 -  Gemeindeschluessel to location_id
 -  state, county, zip
 */
/*
 Take unique Gemeindeschlüssel
 */
INSERT INTO
    {target_schema}.location (
        location_id,
        address_1,
        address_2,
        location_source_value,
        city,
        state,
        zip,
        county,
        country_concept_id,
        country_source_value,
        latitude,
        longitude
    )
SELECT
    DISTINCT ON (sa999.sa999_gs) sa999.sa999_gs AS location_id,
    NULL AS address_1,
    NULL AS address_2,
    sa999.sa999_gs AS location_source_value,
    sa999.sa999_gs AS city,
    sa999.sa999_gs_land AS state,
    sa999.sa999_gs_rb AS zip,
    sa999.sa999_gs_kreis AS county,
    NULL AS country_concept_id,
    NULL AS country_source_value,
    NULL AS latitude,
    NULL AS longitude
FROM
    {source_schema}.{table}sa999 sa999 ON CONFLICT (location_id) DO NOTHING;