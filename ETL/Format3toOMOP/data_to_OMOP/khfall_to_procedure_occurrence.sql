-- Artificial respiration as procedure
INSERT INTO
    {target_schema}.procedure_occurrence (
        visit_occurrence_id,
        procedure_date,
        procedure_concept_id,
        procedure_source_concept_id,
        procedure_source_value,
        procedure_occurrence_id,
        person_id,
        procedure_datetime,
        procedure_end_date,
        procedure_end_datetime,
        procedure_type_concept_id,
        modifier_concept_id,
        quantity,
        provider_id,
        visit_detail_id,
        modifier_source_value
    )
SELECT
    khfall.fallidkh AS visit_occurrence_id,
    TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD') AS procedure_date,
    4230167 AS procedure_concept_id,
    --Artificial respiration 
    NULL AS procedure_source_concept_id,
    NULL AS procedure_source_value,
    nextval('{target_schema}.procedure_occurrence_id'),
    khfall.arbnr AS person_id,
    NULL AS procedure_datetime,
    NULL AS procedure_end_date,
    NULL AS procedure_end_datetime,
    32810 AS procedure_type_concept_id,
    --Claim 
    NULL AS modifier_concept_id,
    khfall.beatstd :: NUMERIC AS quantity,
    NULL AS provider_id,
    NULL AS visit_detail_id,
    NULL AS modifier_source_value
FROM
    stationaere_faelle.khfall khfall
WHERE
    khfall.beatstd IS NOT NULL
    AND khfall.beatstd :: NUMERIC > 0;