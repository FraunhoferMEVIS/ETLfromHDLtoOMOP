/*
 Ausgeschlossene Ambulante Diagnosen  ( Excluded outpatient diagnosis) to observation
 - observation date
 - excluded diagnosis
 */
INSERT INTO
    {target_schema}.observation (
        -- observation_id is generated 
        person_id,
        observation_date,
        observation_concept_id,
        observation_source_concept_id,
        observation_source_value,
        observation_datetime,
        observation_type_concept_id,
        -- 32810 Claim 
        value_as_number,
        value_source_value,
        value_as_string,
        value_as_concept_id,
        qualifier_concept_id,
        unit_concept_id,
        provider_id,
        visit_occurrence_id,
        visit_detail_id,
        unit_source_value,
        qualifier_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    per.person_id AS person_id,
    vo.visit_start_date AS observation_date,
    -- Disorder excluded
    4199812 AS observation_concept_id,
    NULL AS observation_source_concept_id,
    sa651.sa651_diagnose AS observation_source_value,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    --  32810 Claim 
    NULL AS value_as_number,
    NULL AS value_source_value,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS provider_id,
    vo.visit_occurrence_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    {source_schema}.{table}sa651 sa651
    INNER JOIN {target_schema}.person per ON sa651.sa651_psid = per.person_source_value
    INNER JOIN {target_schema}.visit_occurrence vo ON CONCAT(sa651.sa651_berichtsjahr, sa651.sa651_leistungsquartal,'_',sa651_psid) = vo.source_idx_outpatient
WHERE
    sa651.sa651_qualifizierung = 'A';