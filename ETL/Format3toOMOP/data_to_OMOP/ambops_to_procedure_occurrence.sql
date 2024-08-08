/*primary diagnosis*/
CREATE TEMP TABLE tmp_ambops AS
SELECT
  ambops.opsdat,
  ambops.ops,
  ambops.opslokal,
  ambops.fallidamb,
  mv_ops.procedure_source_concept_id,
  mv_ops.procedure_target_concept_id,
  mv_ops.domain_id
FROM
  ambulante_faelle.ambops ambops
  LEFT JOIN {target_schema}.ops_standard_domain_lookup mv_ops ON ambops.ops = mv_ops.source_code;

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
    WHEN tmp_ambops.opsdat is NULL THEN make_date(
      LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
      (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
      01
    )
    ELSE TO_DATE(tmp_ambops.opsdat :: VARCHAR, 'YYYYMMDD')
  END AS procedure_date,
  COALESCE(tmp_ambops.procedure_target_concept_id, 0) AS procedure_concept_id,
  COALESCE(tmp_ambops.procedure_source_concept_id, 0) AS procedure_source_concept_id,
  CONCAT(tmp_ambops.ops, ',', tmp_ambops.opslokal) AS procedure_source_value,
  nextval('{target_schema}.procedure_occurrence_id'),
  ambfall.arbnr AS person_id,
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
  tmp_ambops
  LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambops.fallidamb = ambfall.fallidamb
  LEFT JOIN {target_schema}.visit_occurrence vo  ON tmp_ambops.fallidamb = vo.fallid_temp  
WHERE
  tmp_ambops.domain_id = 'Procedure'
  OR tmp_ambops.domain_id IS NULL;

INSERT INTO
  {target_schema}.observation (
    visit_occurrence_id,
    observation_date,
    observation_source_value,
    person_id,
    -- link 
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
    WHEN tmp_ambops.opsdat is NULL THEN make_date(
      LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
      (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
      01
    )
    ELSE TO_DATE(tmp_ambops.opsdat :: VARCHAR, 'YYYYMMDD')
  END AS observation_date,
  CONCAT(tmp_ambops.ops, ',', tmp_ambops.opslokal) AS observation_source_value,
  ambfall.arbnr AS person_id,
  -- Disorder excluded
  COALESCE(tmp_ambops.procedure_target_concept_id, 0) AS observation_concept_id,
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
  COALESCE(tmp_ambops.procedure_source_concept_id, 0) AS observation_source_concept_id,
  NULL AS unit_source_value,
  NULL AS qualifier_source_value,
  NULL AS value_source_value,
  NULL AS observation_event_id,
  NULL AS obs_event_field_concept_id
FROM
  tmp_ambops
  LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambops.fallidamb = ambfall.fallidamb
  LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_ambops.fallidamb = vo.fallid_temp  
WHERE
  tmp_ambops.domain_id = 'Observation';

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
  ambfall.arbnr AS person_id,
  COALESCE(tmp_ambops.procedure_target_concept_id, 0) AS measurement_concept_id,
  CASE
    WHEN tmp_ambops.opsdat is NULL THEN make_date(
      LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
      (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
      01
    )
    ELSE TO_DATE(tmp_ambops.opsdat :: VARCHAR, 'YYYYMMDD')
  END AS measurement_date,
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
  CONCAT(tmp_ambops.ops, ',', tmp_ambops.opslokal) AS measurement_source_value,
  COALESCE(tmp_ambops.procedure_source_concept_id, 0) AS measurement_source_concept_id,
  NULL AS unit_source_value,
  NULL AS unit_source_concept_id,
  NULL AS value_source_value,
  NULL AS measurement_event_id,
  NULL AS meas_event_field_concept_id
FROM
  tmp_ambops
  LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambops.fallidamb = ambfall.fallidamb
  LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_ambops.fallidamb = vo.fallid_temp  
WHERE
  tmp_ambops.domain_id = 'Measurement';

INSERT INTO
  {target_schema}.drug_exposure (
    drug_exposure_id,
    -- one common entry for ezd and rez; join by reznr (FULL JOIN!)
    provider_id,
    person_id,
    drug_exposure_start_date,
    drug_concept_id,
    drug_source_value,
    quantity,
    drug_exposure_start_datetime,
    drug_exposure_end_date,
    drug_exposure_end_datetime,
    verbatim_end_date,
    drug_type_concept_id,
    -- 32810 Claim
    stop_reason,
    refills,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    visit_occurrence_id,
    visit_detail_id,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
  )
SELECT
  nextval('{target_schema}.drug_exposure_id') AS drug_exposure_id,
  NULL AS provider_id,
  ambfall.arbnr AS person_id,
  CASE
    WHEN tmp_ambops.opsdat is NULL THEN make_date(
      LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
      (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
      01
    )
    ELSE TO_DATE(tmp_ambops.opsdat :: VARCHAR, 'YYYYMMDD')
  END AS drug_exposure_start_date,
  --  Map from PZN to RxNorm (no mapping available yet)
  COALESCE(tmp_ambops.procedure_target_concept_id, 0) as drug_concept_id,
  CONCAT(tmp_ambops.ops, ',', tmp_ambops.opslokal) AS drug_source_value,
  NULL AS quantity,
  NULL AS drug_exposure_start_datetime,
  CASE
    WHEN tmp_ambops.opsdat is NULL THEN make_date(
      LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
      (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
      01
    )
    ELSE TO_DATE(tmp_ambops.opsdat :: VARCHAR, 'YYYYMMDD')
  -- drug_exposure_start_datetime=drug_exposure_end_date if no end date is available (OMOP recommendation)
  END AS drug_exposure_end_date,
  NULL AS drug_exposure_end_datetime,
  NULL AS verbatim_end_date,
  32810 AS drug_type_concept_id,
  NULL AS stop_reason,
  NULL AS refills,
  NULL AS days_supply,
  NULL AS sig,
  NULL AS route_concept_id,
  NULL AS lot_number,
  vo.visit_occurrence_id AS visit_occurrence_id,
  NULL AS visit_detail_id,
  COALESCE(tmp_ambops.procedure_source_concept_id, 0) AS drug_source_concept_id,
  NULL AS route_source_value,
  NULL AS dose_unit_source_value
FROM
  tmp_ambops
  LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambops.fallidamb = ambfall.fallidamb
  LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_ambops.fallidamb = vo.fallid_temp  
WHERE
  tmp_ambops.domain_id = 'Drug';

DROP TABLE IF EXISTS tmp_ambops CASCADE;