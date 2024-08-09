INSERT INTO
    {target_schema}.procedure_occurrence (
        visit_occurrence_id,
        procedure_date,
        procedure_concept_id,
        -- OPS to standard
        procedure_source_concept_id,
        procedure_source_value,
        procedure_occurrence_id,
        person_id,
        procedure_datetime,
        procedure_end_date,
        procedure_end_datetime,
        procedure_type_concept_id,
        -- 32810 Claim
        modifier_concept_id,
        quantity,
        provider_id,
        visit_detail_id,
        modifier_source_value
    )
SELECT
    vo.visit_occurrence_id AS visit_occurrence_id,
    CASE
        WHEN COALESCE(ambfall.beginndatamb, ambfall.endedatamb) is NULL THEN make_date(
            LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
            (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
            01
        )
        ELSE TO_DATE(
            COALESCE(ambfall.beginndatamb, ambfall.endedatamb) :: VARCHAR,
            'YYYYMMDD'
        )
    END AS procedure_date,
    4032243 AS procedure_concept_id,
    --dialyses
    37097686 AS procedure_source_concept_id,
    --dialyses
    NULL AS procedure_source_value,
    nextval('{target_schema}.procedure_occurrence_id'),
    ambfall.psid AS person_id,
    NULL AS procedure_datetime,
    NULL AS procedure_end_date,
    NULL AS procedure_end_datetime,
    32810 AS procedure_type_concept_id,
    --Claim 
    NULL AS modifier_concept_id,
    NULL AS quantity,
    NULL AS provider_id,
    NULL AS visit_detail_id,
    NULL AS modifier_source_value
FROM
    ambulante_faelle.ambfall
    LEFT JOIN {target_schema}.visit_occurrence vo  ON ambfall.fallidamb = vo.fallidamb_temp and ambfall.vsid = vo.vsid_temp
WHERE
    ambfall.dialysesachko IS NOT NULL;