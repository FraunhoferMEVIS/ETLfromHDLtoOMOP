/*
 To capture treating hospital  and transfering (since this is kept in visit_occurence( admitted from))
 Note: 
 - Since a hospital  might appear in several tables we  apply a full join to report every hospital, but none twice
 - select distinct on khpseudo/veranlasskhpseudo
 - we do the same process once for khpseudo, once for veranlasskhpseudo
 */
-- First treating hospital 
INSERT INTO
    {target_schema}.care_site (
        care_site_id,
        care_site_name,
        place_of_service_concept_id,
        location_id,
        care_site_source_value,
        place_of_service_source_value
    )
SELECT
    DISTINCT ON (khfall.khpseudo) --  pseudonym of hospital  
    khfall.khpseudo AS care_site_id,
    NULL AS care_site_name,
    38004515 AS place_of_service_concept_id,
    --Hospital
    khfall.khregkz AS location_id,
    khfall.khpseudo AS care_site_source_value,
    NULL  AS place_of_service_source_value
FROM
    stationaere_faelle.khfall
WHERE
    khfall.khpseudo IS NOT NULL 
    AND khfall.khpseudo != ''
ON CONFLICT (care_site_id) DO NOTHING;

-- transfering hospital 
INSERT INTO
    {target_schema}.care_site (
        care_site_id,
        care_site_name,
        place_of_service_concept_id,
        location_id,
        care_site_source_value,
        place_of_service_source_value
    )
SELECT
    DISTINCT ON (khfall.veranlasskhpseudo) 
    khfall.veranlasskhpseudo AS care_site_id,
    NULL AS care_site_name,
    --In source data it is always set to 26 (=Hospital) 
    --38004515  Hospital 
    38004515 AS place_of_service_concept_id,
    khfall.veranlasskhregknz AS location_id,
    khfall.veranlasskhpseudo AS care_site_source_value,
   NULL AS place_of_service_source_value
FROM
    stationaere_faelle.khfall
WHERE
    khfall.veranlasskhpseudo IS NOT NULL 
    AND khfall.veranlasskhpseudo != ''
ON CONFLICT (care_site_id) DO NOTHING;