/*
 Capture excluded diagnosis as observation
 */
INSERT INTO
    {target_schema}.observation (
        visit_occurrence_id,
        observation_date,
        observation_source_value,
        person_id,
        observation_concept_id,
        value_as_string,
        value_as_concept_id,
        observation_id,
        provider_id,
        observation_datetime,
        observation_type_concept_id,
        -- 32810 Claim 
        value_as_number,
        qualifier_concept_id,
        unit_concept_id,
        visit_detail_id,
        observation_source_concept_id,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    vo.visit_occurrence_id AS visit_occurrence_id,
    CASE
        WHEN COALESCE(
            ambdiag.diagdat,
            ambfall.beginndatamb,
            ambfall.endedatamb
        ) is NULL THEN make_date(
            LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
            (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
            01
        )
        ELSE TO_DATE(
            COALESCE(
                ambdiag.diagdat,
                ambfall.beginndatamb,
                ambfall.endedatamb
            ) :: VARCHAR,
            'YYYYMMDD'
        )
    END AS observation_date,
    CONCAT(
        ambdiag.icdamb,
        ',',
        ambdiag.diagsich,
        ': Excluded Diagnosis'
    ) AS observation_source_value,
    ambfall.psid AS person_id,
    -- Disorder excluded
    4199812 AS observation_concept_id,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    nextval('{target_schema}.observation_id'),
    NULL AS provider_id,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    --Claim
    NULL AS value_as_number,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS visit_detail_id,
    NULL AS observation_source_concept_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    ambulante_faelle.ambdiag ambdiag
    INNER JOIN ambulante_faelle.ambfall ambfall ON ambfall.fallidamb = ambdiag.fallidamb 
    LEFT JOIN {target_schema}.visit_occurrence vo  ON ambfall.fallidamb = vo.fallid_temp -- and ambfall.vsid = vo.vsid_temp

WHERE
    ambdiag.diagsich = 'A';