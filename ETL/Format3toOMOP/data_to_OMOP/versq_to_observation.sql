/*
 Need to be called for each category once 
 */
INSERT INTO
    {target_schema}.observation (
        observation_id,
        person_id,
        observation_date,
        -- 1st of quarter ((quarter-1)*3)+1 Format JJJJQ
        observation_datetime,
        observation_concept_id,
        observation_source_concept_id,
        value_as_number,
        observation_type_concept_id,
        -- 32810 Claim
        value_as_string,
        value_as_concept_id,
        qualifier_concept_id,
        unit_concept_id,
        provider_id,
        visit_occurrence_id,
        visit_detail_id,
        observation_source_value,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    nextval('{target_schema}.observation_id'),
    versq_.arbnr AS person_id,
    -- [MAPPING COMMENT] set to 1st of quarter  
    make_date(
        LEFT(versq_.versq :: VARCHAR, 4) :: int,
        1 + ((RIGHT(versq_.versq :: VARCHAR, 1) :: int) -1) * 3,
        01
    ) AS observation_date,
    NULL AS observation_datetime,
    -- custiom concept, no mapping to standard possibile
    0 AS observation_concept_id,
    -- custom vocabulary to keep meaning 
    cpt.concept_id AS observation_source_concept_id,
    versq_.{column_name} AS value_as_number,
    32810 AS observation_type_concept_id,
    --claim
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS provider_id,
    NULL AS visit_occurrence_id,
    NULL AS visit_detail_id,
    NULL AS observation_source_value,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    versicherte.versq versq_
    LEFT JOIN {target_schema}.concept cpt ON cpt.concept_code like '%%{value}'
WHERE
    cpt.vocabulary_id = 'Insured days'
    AND cpt.invalid_reason is NULL
    AND versq_.{column_name} > 0;