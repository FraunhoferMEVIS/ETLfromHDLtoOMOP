/*
 
 Ambulante Diagnosen (Outpatient diagnosis) to condition occurrence 
 - visit date
 - diagnosis
 - conditions status (preliminary, confirmed, .
 )
 */
CREATE TEMP TABLE tmp_sa651_diagnosis AS
SELECT
    sa651.sa651_qualifizierung,
    sa651.sa651_icd_code,
    mv_diag.condition_source_concept_id,
    mv_diag.condition_target_concept_id,
    mv_diag.domain_id,
    CONCAT(sa651.sa651_berichtsjahr, sa651.sa651_leistungsquartal,'_',sa651_psid) as idx_sa651
FROM
    {source_schema}.{table}sa651 sa651
    LEFT JOIN {target_schema}.icd_standard_domain_lookup mv_diag ON sa651.sa651_icd_code = mv_diag.source_code
WHERE
    sa651.sa651_qualifizierung != 'A';

INSERT INTO
    {target_schema}.condition_occurrence (
        person_id,
        -- condition_occurrence_id is generated 
        visit_occurrence_id,
        condition_start_date,
        condition_start_datetime,
        condition_end_date,
        condition_end_datetime,
        condition_status_source_value,
        condition_status_concept_id,
        condition_type_concept_id,
        condition_source_value,
        condition_concept_id,
        condition_source_concept_id,
        stop_reason,
        provider_id,
        visit_detail_id
    )
SELECT
    vo.person_id AS person_id,
    -- generated condition_occurrence_id,
    vo.visit_occurrence_id AS visit_occurrence_id,
    vo.visit_start_date AS condition_start_date,
    NULL AS condition_start_datetime,
    NULL AS condition_end_date,
    NULL AS condition_end_datetime,
    tmp_sa651_diagnosis.sa651_qualifizierung AS condition_status_source_value,
    case
        tmp_sa651_diagnosis.sa651_qualifizierung
        when 'V' then 32899 --Verdachtsdiagnose => Preliminary diagnosis
        when 'Z' then 32906 --Zustand nach betreffender Diagnose => 32906  Resolved condition
        when 'G' then 32906 --gesicherte Diagnose => 32893 Confirmed diagnosis
        --A  ausgeschlossene Diagnose => excluded !
        else 0 -- in source table 3 euqals otherwise
    end AS condition_status_concept_id,
    32810 AS condition_type_concept_id,
    --claim
    tmp_sa651_diagnosis.sa651_icd_code AS condition_source_value,
    COALESCE(
        tmp_sa651_diagnosis.condition_target_concept_id,
        0
    ) AS condition_concept_id,
    COALESCE(
        tmp_sa651_diagnosis.condition_source_concept_id,
        0
    ) AS condition_source_concept_id,
    NULL AS stop_reason,
    NULL AS provider_id,
    NULL AS visit_detail_id
FROM
    tmp_sa651_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa651_diagnosis.idx_sa651 = vo.source_idx_outpatient
WHERE
    tmp_sa651_diagnosis.domain_id = 'Condition'
    OR tmp_sa651_diagnosis.domain_id IS NULL;

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
    vo.person_id AS person_id,
    vo.visit_start_date AS observation_date,
    COALESCE(
        tmp_sa651_diagnosis.condition_target_concept_id,
        0
    ) AS observation_concept_id,
    -- Customized vocabulary 
    COALESCE(
        tmp_sa651_diagnosis.condition_source_concept_id,
        0
    ) AS observation_source_concept_id,
    tmp_sa651_diagnosis.sa651_icd_code AS observation_source_value,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    -- 32810  Claim 
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
    tmp_sa651_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa651_diagnosis.idx_sa651 = vo.source_idx_outpatient
WHERE
    tmp_sa651_diagnosis.domain_id = 'Observation';

INSERT INTO
    {target_schema}.procedure_occurrence (
        --procedure_occurrence_id  generated 
        visit_detail_id,
        person_id,
        procedure_date,
        visit_occurrence_id,
        procedure_concept_id,
        procedure_source_concept_id,
        procedure_datetime,
        procedure_end_date,
        procedure_end_datetime,
        procedure_type_concept_id,
        modifier_concept_id,
        quantity,
        provider_id,
        procedure_source_value,
        modifier_source_value
    )
SELECT
    -- procedure_occurrence_id generated
    NULL AS visit_detail_id,
    vo.person_id AS person_id,
    vo.visit_start_date AS procedure_date,
    vo.visit_occurrence_id AS visit_occurrence_id,
    COALESCE(
        tmp_sa651_diagnosis.condition_target_concept_id,
        0
    ) AS procedure_concept_id,
    COALESCE(
        tmp_sa651_diagnosis.condition_source_concept_id,
        0
    ) AS procedure_source_concept_id,
    NULL AS procedure_datetime,
    NULL AS procedure_end_date,
    NULL AS procedure_end_datetime,
    32810 AS procedure_type_concept_id,
    --Claim
    NULL AS modifier_concept_id,
    NULL AS quantity,
    NULL AS provider_id,
    tmp_sa651_diagnosis.sa651_icd_code AS procedure_source_value,
    NULL AS modifier_source_value
FROM
    tmp_sa651_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa651_diagnosis.idx_sa651 = vo.source_idx_outpatient
WHERE
    tmp_sa651_diagnosis.domain_id = 'Procedure';

INSERT INTO
    {target_schema}.measurement (
        --measurement_id,
        person_id,
        measurement_concept_id,
        measurement_date,
        measurement_datetime,
        measurement_time,
        measurement_type_concept_id,
        operator_concept_id,
        value_as_number,
        value_as_concept_id,
        unit_concept_id,
        range_low,
        range_high,
        provider_id,
        visit_occurrence_id,
        visit_detail_id,
        measurement_source_value,
        measurement_source_concept_id,
        unit_source_value,
        unit_source_concept_id,
        value_source_value,
        measurement_event_id,
        meas_event_field_concept_id
    )
SELECT
    -- generated measurement_id,
    vo.person_id AS person_id,
    COALESCE(
        tmp_sa651_diagnosis.condition_target_concept_id,
        0
    ) AS measurement_concept_id,
    vo.visit_start_date AS measurement_date,
    NULL AS measurement_datetime,
    NULL AS measurement_time,
    32810 AS measurement_type_concept_id,
    NULL AS operator_concept_id,
    NULL AS value_as_number,
    NULL AS value_as_concept_id,
    NULL AS unit_concept_id,
    NULL AS range_low,
    NULL AS range_high,
    NULL AS provider_id,
    vo.visit_occurrence_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    tmp_sa651_diagnosis.sa651_icd_code AS measurement_source_value,
    COALESCE(
        tmp_sa651_diagnosis.condition_source_concept_id,
        0
    ) AS measurement_source_concept_id,
    NULL AS unit_source_value,
    NULL AS unit_source_concept_id,
    NULL AS value_source_value,
    NULL AS measurement_event_id,
    NULL AS meas_event_field_concept_id
FROM
    tmp_sa651_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa651_diagnosis.idx_sa651 = vo.source_idx_outpatient
WHERE
    tmp_sa651_diagnosis.domain_id = 'Measurement';

DROP TABLE IF EXISTS tmp_sa651_diagnosis CASCADE;