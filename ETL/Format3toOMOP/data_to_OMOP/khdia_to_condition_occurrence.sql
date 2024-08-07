/*primary diagnosis*/
DROP TABLE IF EXISTS tmp_khdia_diagnosis;

DROP TABLE IF EXISTS icd_tmp;

CREATE TEMP TABLE icd_tmp AS with sec_tmp as(
    SELECT
        khdiag.fallidkh,
        khdiag.sekicd as source_icd,
        khdiag.sekicdlokal as lokal,
        2 as diagnois_typ,
        --secondary diagnosis
        regexp_replace(khdiag.sekicd, '[^\w\s^.]', '') as icd,
        --the test data has either special characters nor '.', This must be checked for real data 
        32908 AS diagart_concept,
        --since it is reported asin column secondary diagnosis (Nebendiagnose)
        'N' as source_diagart
    FROM
        stationaere_faelle.khdiag khdiag
    WHERE
        khdiag.sekicd IS NOT NULL
),
prim_tmp as (
    SELECT
        khdiag.fallidkh,
        khdiag.icdkh as source_icd,
        khdiag.icdlokal as lokal,
        1 as diagnois_typ,
        --primary diagnosis
        regexp_replace(khdiag.icdkh, '[^\w\s^.]', '') as icd,
        --the test data has either special characters nor '.', This must be checked for real data 
        CASE
            khdiag.diagart
            WHEN 'A' then 32890 --A (Aufhnahmediagnose) => Admission diagnosis
            WHEN 'H' then 32902 --H (Hauptdiagnose) =>32902 Primary diagnosis
            WHEN 'N' then 32908 --N (Nebendiagnose) => 32908 Secondary diagnosis 
        END AS diagart_concept,
        khdiag.diagart as source_diagart
    FROM
        stationaere_faelle.khdiag khdiag
    WHERE
        khdiag.icdkh IS NOT NULL
)
SELECT
    *
FROM
    sec_tmp
UNION
SELECT
    *
FROM
    prim_tmp;

CREATE TEMP TABLE tmp_khdia_diagnosis AS
SELECT
    icd_tmp.fallidkh,
    icd_tmp.source_icd,
    icd_tmp.lokal,
    icd_tmp.diagnois_typ,
    icd_tmp.icd,
    icd_tmp.diagart_concept,
    icd_tmp.source_diagart,
    mv_diag.condition_source_concept_id,
    mv_diag.condition_target_concept_id,
    mv_diag.domain_id
FROM
    icd_tmp
    LEFT JOIN {target_schema}.icd_standard_domain_lookup mv_diag ON icd_tmp.icd = replace(mv_diag.source_code, '.', '');

INSERT INTO
    {target_schema}.condition_occurrence (
        visit_occurrence_id,
        condition_occurrence_id,
        person_id,
        condition_concept_id,
        condition_source_concept_id,
        condition_source_value,
        condition_status_concept_id,
        condition_start_date,
        condition_status_source_value,
        condition_start_datetime,
        condition_end_date,
        condition_end_datetime,
        condition_type_concept_id,
        -- 32810 Claim 
        stop_reason,
        provider_id,
        -- Use visit_occurence provider_id
        visit_detail_id
    )
SELECT
    vo.visit_occurrence_id AS visit_occurrence_id,
    nextval('{target_schema}.condition_occurrence_id'),
    khfall.arbnr AS person_id,
    COALESCE(
        tmp_khdia_diagnosis.condition_target_concept_id,
        0
    ) AS condition_concept_id,
    COALESCE(
        tmp_khdia_diagnosis.condition_source_concept_id,
        0
    ) AS condition_source_concept_id,
    CONCAT(
        tmp_khdia_diagnosis.source_icd,
        ',',
        tmp_khdia_diagnosis.lokal
    ) AS condition_source_value,
    tmp_khdia_diagnosis.diagart_concept AS condition_status_concept_id,
    TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD') AS condition_start_date,
    tmp_khdia_diagnosis.source_diagart AS condition_status_source_value,
    NULL AS condition_start_datetime,
    NULL AS condition_end_date,
    NULL AS condition_end_datetime,
    32810 AS condition_type_concept_id,
    --32810 Claim 
    NULL AS stop_reason,
    khfall.einweispseudo AS provider_id,
    NULL AS visit_detail_id
FROM
    tmp_khdia_diagnosis
    LEFT JOIN stationaere_faelle.khfall khfall ON tmp_khdia_diagnosis.fallidkh = khfall.fallidkh
    LEFT JOIN {target_schema}.visit_occurrence vo tmp_khdia_diagnosis.fallidkh = vo.fallid_temp 
WHERE
    tmp_khdia_diagnosis.domain_id = 'Condition'
    OR tmp_khdia_diagnosis.domain_id IS NULL;

--All ICD10 Codes of domain procedure 
INSERT INTO
    {target_schema}.procedure_occurrence (
        procedure_occurrence_id,
        visit_occurrence_id,
        person_id,
        procedure_concept_id,
        procedure_source_concept_id,
        procedure_source_value,
        procedure_date,
        provider_id,
        -- can be linked through visit_occurence 
        procedure_type_concept_id,
        -- 32810 Claim
        procedure_datetime,
        procedure_end_date,
        procedure_end_datetime,
        modifier_concept_id,
        quantity,
        visit_detail_id,
        modifier_source_value
    )
SELECT
    nextval('{target_schema}.procedure_occurrence_id'),
    vo.visit_occurrence_id AS visit_occurrence_id,
    khfall.arbnr AS person_id,
    COALESCE(
        tmp_khdia_diagnosis.condition_target_concept_id,
        0
    ) AS procedure_concept_id,
    COALESCE(
        tmp_khdia_diagnosis.condition_source_concept_id,
        0
    ) AS procedure_source_concept_id,
    CONCAT(
        tmp_khdia_diagnosis.source_icd,
        ',',
        tmp_khdia_diagnosis.lokal
    ) AS procedure_source_value,
    TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD') AS procedure_date,
    khfall.einweispseudo AS provider_id,
    32810 AS procedure_type_concept_id,
    --claim 
    NULL AS procedure_datetime,
    NULL AS procedure_end_date,
    NULL AS procedure_end_datetime,
    NULL AS modifier_concept_id,
    NULL AS quantity,
    NULL AS visit_detail_id,
    NULL AS modifier_source_value
FROM
    tmp_khdia_diagnosis
    LEFT JOIN stationaere_faelle.khfall khfall ON tmp_khdia_diagnosis.fallidkh = khfall.fallidkh
    LEFT JOIN {target_schema}.visit_occurrence vo tmp_khdia_diagnosis.fallidkh = vo.fallid_temp 
WHERE
    tmp_khdia_diagnosis.domain_id = 'Procedure';

INSERT INTO
    {target_schema}.observation (
        observation_type_concept_id,
        -- 32810 Claim 
        observation_id,
        person_id,
        observation_concept_id,
        observation_date,
        observation_datetime,
        value_as_number,
        value_as_string,
        value_as_concept_id,
        qualifier_concept_id,
        unit_concept_id,
        provider_id,
        visit_occurrence_id,
        visit_detail_id,
        observation_source_value,
        observation_source_concept_id,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    32810 AS observation_type_concept_id,
    --Claim
    nextval('{target_schema}.observation_id'),
    khfall.arbnr AS person_id,
    COALESCE(
        tmp_khdia_diagnosis.condition_target_concept_id,
        0
    ) observation_concept_id,
    TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD') AS observation_date,
    NULL AS observation_datetime,
    NULL AS value_as_number,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    khfall.einweispseudo AS provider_id,
    vo.visit_occurrence_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    CONCAT(
        tmp_khdia_diagnosis.source_icd,
        ',',
        tmp_khdia_diagnosis.lokal
    ) AS observation_source_value,
    COALESCE(
        tmp_khdia_diagnosis.condition_source_concept_id,
        0
    ) AS observation_source_concept_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    tmp_khdia_diagnosis
    LEFT JOIN stationaere_faelle.khfall khfall ON tmp_khdia_diagnosis.fallidkh = khfall.fallidkh
    LEFT JOIN {target_schema}.visit_occurrence vo tmp_khdia_diagnosis.fallidkh = vo.fallid_temp 
WHERE
    tmp_khdia_diagnosis.domain_id = 'Observation';

INSERT INTO
    {target_schema}.measurement (
        measurement_id,
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
    nextval('{target_schema}.measurement_id'),
    khfall.arbnr AS person_id,
    COALESCE(
        tmp_khdia_diagnosis.condition_target_concept_id,
        0
    ) AS measurement_concept_id,
    TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD') AS measurement_date,
    NULL AS measurement_datetime,
    NULL AS measurement_time,
    32810 AS measurement_type_concept_id,
    NULL AS operator_concept_id,
    NULL AS value_as_number,
    NULL AS value_as_concept_id,
    NULL AS unit_concept_id,
    NULL AS range_low,
    NULL AS range_high,
    khfall.einweispseudo AS provider_id,
    vo.visit_occurrence_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    CONCAT(
        tmp_khdia_diagnosis.source_icd,
        ', ',
        tmp_khdia_diagnosis.lokal
    ) AS measurement_source_value,
    COALESCE(
        tmp_khdia_diagnosis.condition_source_concept_id,
        0
    ) AS measurement_source_concept_id,
    NULL AS unit_source_value,
    NULL AS unit_source_concept_id,
    NULL AS value_source_value,
    NULL AS measurement_event_id,
    NULL AS meas_event_field_concept_id
FROM
    tmp_khdia_diagnosis
    LEFT JOIN stationaere_faelle.khfall khfall ON tmp_khdia_diagnosis.fallidkh = khfall.fallidkh
    LEFT JOIN {target_schema}.visit_occurrence vo tmp_khdia_diagnosis.fallidkh = vo.fallid_temp 
WHERE
    tmp_khdia_diagnosis.domain_id = 'Measurement';

DROP TABLE IF EXISTS tmp_khdia_diagnosis;

DROP TABLE IF EXISTS icd_tmp;