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
    DISTINCT ON (ambfall.bsnrpseudo) -- [VALUE   COMMENT] pseudonym of hospital  
    ambfall.bsnrpseudo AS care_site_id,
    NULL AS care_site_name,
    38004207 AS place_of_service_concept_id,
    ambfall.bsnrkv AS location_id,
    ambfall.bsnrpseudo AS care_site_source_value,
    NULL AS place_of_service_source_value
FROM
    ambulante_faelle.ambfall
WHERE
    ambfall.bsnrpseudo IS NOT NULL ON CONFLICT (care_site_id) DO NOTHING;
