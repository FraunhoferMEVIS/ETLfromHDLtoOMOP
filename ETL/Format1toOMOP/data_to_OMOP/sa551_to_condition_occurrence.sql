/*
 Stationäre Diagnoses 
 Inpatient diagnosis
 */
/*
 Stationäre Diagnosen (Inpatient diagnosis) to condition occurrence 
 - visit date
 - diagnosis
 - conditions status (primary, secondary diagnosis)
 */
-- Remove special characters +-!# since they are not included in the mapping. 
DROP TABLE IF EXISTS tmp_sa551_diagnosis CASCADE;

CREATE TEMP TABLE tmp_sa551_diagnosis AS
SELECT
    sa551.sa551_icd_code,
    sa551.sa551_artdiagnose,
    mv_diag.condition_source_concept_id,
    mv_diag.condition_target_concept_id,
    mv_diag.domain_id,
    CONCAT(sa551.sa551_entlassungsmonat,sa551.sa551_fallzaehler,'_',sa551_psid) as idx_sa551
FROM
    {source_schema}.{table}sa551 sa551
    LEFT JOIN {target_schema}.icd_standard_domain_lookup mv_diag ON sa551.sa551_icd_code = mv_diag.source_code;

INSERT INTO
    {target_schema}.condition_occurrence (
        person_id,
        --condition_occurrence_id generated 
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
    tmp_sa551_diagnosis.sa551_artdiagnose AS condition_status_source_value,
    case
        tmp_sa551_diagnosis.sa551_artdiagnose
        when 1 then 32902 --Primary diagnosis
        when 2 then 32908 --Secondary diagnosis  
        else 0
    end AS condition_status_concept_id,
    32810 AS condition_type_concept_id,
    --claim
    tmp_sa551_diagnosis.sa551_icd_code AS condition_source_value,
    COALESCE(
        tmp_sa551_diagnosis.condition_target_concept_id,
        0
    ) AS condition_concept_id,
    COALESCE(
        tmp_sa551_diagnosis.condition_source_concept_id,
        0
    ) AS condition_source_concept_id,
    NULL AS stop_reason,
    NULL AS provider_id,
    NULL AS visit_detail_id
FROM
    tmp_sa551_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa551_diagnosis.idx_sa551 = vo.source_idx_inpatient  
WHERE
    tmp_sa551_diagnosis.domain_id = 'Condition'
    OR tmp_sa551_diagnosis.domain_id IS NULL;

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
        tmp_sa551_diagnosis.condition_target_concept_id,
        0
    ) AS observation_concept_id,
    COALESCE(
        tmp_sa551_diagnosis.condition_source_concept_id,
        0
    ) AS observation_source_concept_id,
    --0 AS observation_source_concept_id,
    tmp_sa551_diagnosis.sa551_icd_code AS observation_source_value,
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
    tmp_sa551_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa551_diagnosis.idx_sa551 = vo.source_idx_inpatient
WHERE
    tmp_sa551_diagnosis.domain_id = 'Observation';

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
        tmp_sa551_diagnosis.condition_target_concept_id,
        0
    ) AS procedure_concept_id,
    COALESCE(
        tmp_sa551_diagnosis.condition_source_concept_id,
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
    tmp_sa551_diagnosis.sa551_icd_code AS procedure_source_value,
    NULL AS modifier_source_value
FROM
    tmp_sa551_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa551_diagnosis.idx_sa551 = vo.source_idx_inpatient
WHERE
    tmp_sa551_diagnosis.domain_id = 'Procedure';

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
        tmp_sa551_diagnosis.condition_target_concept_id,
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
    tmp_sa551_diagnosis.sa551_icd_code AS measurement_source_value,
    COALESCE(
        tmp_sa551_diagnosis.condition_source_concept_id,
        0
    ) AS measurement_source_concept_id,
    NULL AS unit_source_value,
    NULL AS unit_source_concept_id,
    NULL AS value_source_value,
    NULL AS measurement_event_id,
    NULL AS meas_event_field_concept_id
FROM
    tmp_sa551_diagnosis
    LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_sa551_diagnosis.idx_sa551 = vo.source_idx_inpatient
WHERE
    tmp_sa551_diagnosis.domain_id = 'Measurement';

DROP TABLE IF EXISTS tmp_sa551_diagnosis CASCADE;