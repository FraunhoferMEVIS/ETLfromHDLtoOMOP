/*
 Versichertenstammdaten 151 (Masta data) to observation
 - observation date
 - insured days because of taking care of child to observation_concept_id, value_as_number, observation_source_value
 
 Versichertenstammdaten 152 (Masta data) to observation 
 - observation date
 - insured days by category (e.g
 days abroad) to observation_concept_id, value_as_number, observation_source_value
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
    -- Not given, set to first day of the year.  
    make_date({prefix}.{prefix}_berichtsjahr :: int, 01, 01) AS observation_date,
    -- not suitable standard concept available
    0 AS observation_concept_id,
    -- Customized vocabulary 
    cpt.concept_id AS observation_source_concept_id,
    NULL AS observation_source_value,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    -- 32810  Claim 
    {prefix}.{prefix}_{column} AS value_as_number,
    NULL AS value_source_value,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS provider_id,
    NULL AS visit_occurrence_id,
    NULL AS visit_detail_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    {source_schema}.{table}{prefix} {prefix}
    INNER JOIN {target_schema}.person per ON {prefix}.{prefix}_psid = per.person_source_value
    LEFT JOIN {target_schema}.concept cpt ON cpt.concept_code like '%%{column}'
WHERE
    cpt.vocabulary_id = 'Insured days'
    AND cpt.invalid_reason is NULL
    AND {prefix}.{prefix}_{column} is not NULL;