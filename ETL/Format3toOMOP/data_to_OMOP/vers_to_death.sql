INSERT INTO
    {target_schema}.death (
        person_id,
        death_date,
        death_datetime,
        death_type_concept_id,
        cause_concept_id,
        cause_source_value,
        cause_source_concept_id
    )
SELECT
    -- [MAPPING COMMENT] only if  
    vers.arbnr AS person_id,
    -- [MAPPING COMMENT] original format: JJJJMMTT only if vitalstatus = 1  
    TO_DATE(vers.sterbedat :: text, 'YYYYMMDD') AS death_date,
    NULL AS death_datetime,
    NULL AS death_type_concept_id,
    NULL AS cause_concept_id,
    NULL AS cause_source_value,
    NULL AS cause_source_concept_id
FROM
    versicherte.vers
WHERE
    vitalstatus = 1;