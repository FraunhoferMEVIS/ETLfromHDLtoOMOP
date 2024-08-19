DROP TABLE IF EXISTS tmp_ambdiag_diagnosis CASCADE;

CREATE TEMP TABLE tmp_ambdiag_diagnosis AS
SELECT
   ambdiag.diagdat,
   ambdiag.icdamb_code,
   ambdiag.diaglokal,
   ambdiag.diagsich,
   ambdiag.fallidamb,
   ambdiag.vsid,
   ambdiag.psid,
   mv_diag.condition_source_concept_id,
   mv_diag.condition_target_concept_id,
   mv_diag.domain_id
FROM
   ambulante_faelle.ambdiag ambdiag
   LEFT JOIN {target_schema}.icd_standard_domain_lookup mv_diag ON ambdiag.icdamb_code = replace(mv_diag.source_code, '.', '')
WHERE
   ambdiag.diagsich != 'A';

INSERT INTO
   {target_schema}.condition_occurrence (
      visit_occurrence_id,
      condition_occurrence_id,
      condition_start_date,
      condition_concept_id,
      condition_source_concept_id,
      condition_source_value,
      condition_status_concept_id,
      person_id,
      condition_start_datetime,
      condition_end_date,
      condition_end_datetime,
      condition_type_concept_id,
      -- 32810 Claim
      stop_reason,
      provider_id,
      visit_detail_id,
      condition_status_source_value
   )
SELECT
   vo.visit_occurrence_id AS visit_occurrence_id,
   nextval('{target_schema}.condition_occurrence_id'),
   CASE
      WHEN COALESCE(
         tmp_ambdiag_diagnosis.diagdat,
         ambfall.beginndatamb,
         ambfall.endedatamb
      ) is NULL THEN make_date(
         LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
         (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
         01
      )
      ELSE TO_DATE(
         COALESCE(
            tmp_ambdiag_diagnosis.diagdat,
            ambfall.beginndatamb,
            ambfall.endedatamb
         ) :: VARCHAR,
         'YYYYMMDD'
      )
   END AS condition_start_date,
   COALESCE(
      tmp_ambdiag_diagnosis.condition_target_concept_id,
      0
   ) AS condition_concept_id,
   COALESCE(
      tmp_ambdiag_diagnosis.condition_source_concept_id,
      0
   ) AS condition_source_concept_id,
   CONCAT(
      tmp_ambdiag_diagnosis.icdamb_code,
      ',',
      tmp_ambdiag_diagnosis.diaglokal
   ) AS condition_source_value,
   CASE
      tmp_ambdiag_diagnosis.diagsich
      WHEN 'V' then 32899 -- Preliminary diagnosis
      WHEN 'Z' then 32906 -- Resolved condition
      WHEN 'G' then 32893 --  Confirmed diagnosis 
      ELSE 0 -- A = ausgeschlossene Diagnose (excluded diagnosis) => excluded here!
   END AS condition_status_concept_id,
   tmp_ambdiag_diagnosis.psid AS person_id,
   NULL AS condition_start_datetime,
   NULL AS condition_end_date,
   NULL AS condition_end_datetime,
   32810 AS condition_type_concept_id,
   --  Claim
   NULL AS stop_reason,
   NULL AS provider_id,
   NULL AS visit_detail_id,
   NULL AS condition_status_source_value
FROM
   tmp_ambdiag_diagnosis
   LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambdiag_diagnosis.fallidamb = ambfall.fallidamb and tmp_ambdiag_diagnosis.vsid = ambfall.vsid
   LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_ambdiag_diagnosis.fallidamb = vo.fallidamb_temp and tmp_ambdiag_diagnosis.vsid = vo.vsid_temp
WHERE
   tmp_ambdiag_diagnosis.domain_id = 'Condition'
   OR tmp_ambdiag_diagnosis.domain_id IS NULL;

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
         tmp_ambdiag_diagnosis.diagdat,
         ambfall.beginndatamb,
         ambfall.endedatamb
      ) is NULL THEN make_date(
         LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
         (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
         01
      )
      ELSE TO_DATE(
         COALESCE(
            tmp_ambdiag_diagnosis.diagdat,
            ambfall.beginndatamb,
            ambfall.endedatamb
         ) :: VARCHAR,
         'YYYYMMDD'
      )
   END AS observation_date,
   CONCAT(
      tmp_ambdiag_diagnosis.icdamb_code,
      ',',
      tmp_ambdiag_diagnosis.diaglokal
   ) AS observation_source_value,
   tmp_ambdiag_diagnosis.psid AS person_id,
   -- Disorder excluded
   COALESCE(
      tmp_ambdiag_diagnosis.condition_target_concept_id,
      0
   ) AS observation_concept_id,
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
   COALESCE(
      tmp_ambdiag_diagnosis.condition_source_concept_id,
      0
   ) AS observation_source_concept_id,
   NULL AS unit_source_value,
   CASE
      tmp_ambdiag_diagnosis.diagsich
      WHEN 'V' then 32899 -- Preliminary diagnosis
      WHEN 'Z' then 32906 -- Resolved condition
      WHEN 'G' then 32893 --  Confirmed diagnosis 
      ELSE 0 -- A = ausgeschlossene Diagnose (excluded diagnosis) => excluded here!
   END AS qualifier_source_value,
   NULL AS value_source_value,
   NULL AS observation_event_id,
   NULL AS obs_event_field_concept_id
FROM
   tmp_ambdiag_diagnosis
   LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambdiag_diagnosis.fallidamb = ambfall.fallidamb and tmp_ambdiag_diagnosis.vsid = ambfall.vsid
   LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_ambdiag_diagnosis.fallidamb = vo.fallidamb_temp and tmp_ambdiag_diagnosis.vsid = vo.vsid_temp
WHERE
   tmp_ambdiag_diagnosis.domain_id = 'Observation';

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
      WHEN COALESCE(
         tmp_ambdiag_diagnosis.diagdat,
         ambfall.beginndatamb,
         ambfall.endedatamb
      ) is NULL THEN make_date(
         LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
         (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
         01
      )
      ELSE TO_DATE(
         COALESCE(
            tmp_ambdiag_diagnosis.diagdat,
            ambfall.beginndatamb,
            ambfall.endedatamb
         ) :: VARCHAR,
         'YYYYMMDD'
      )
   END AS procedure_date,
   COALESCE(
      tmp_ambdiag_diagnosis.condition_target_concept_id,
      0
   ) AS procedure_concept_id,
   COALESCE(
      tmp_ambdiag_diagnosis.condition_source_concept_id,
      0
   ) AS procedure_source_concept_id,
   CONCAT(
      tmp_ambdiag_diagnosis.icdamb_code,
      ',',
      tmp_ambdiag_diagnosis.diaglokal
   ) AS procedure_source_value,
   nextval('{target_schema}.procedure_occurrence_id'),
   tmp_ambdiag_diagnosis.psid AS person_id,
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
   tmp_ambdiag_diagnosis
   LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambdiag_diagnosis.fallidamb = ambfall.fallidamb and tmp_ambdiag_diagnosis.vsid = ambfall.vsid
   LEFT JOIN {target_schema}.visit_occurrence vo ON tmp_ambdiag_diagnosis.fallidamb = vo.fallidamb_temp and tmp_ambdiag_diagnosis.vsid = vo.vsid_temp
WHERE
   tmp_ambdiag_diagnosis.domain_id = 'Procedure';

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
   tmp_ambdiag_diagnosis.psid AS person_id,
   COALESCE(
      tmp_ambdiag_diagnosis.condition_target_concept_id,
      0
   ) AS measurement_concept_id,
   CASE
      WHEN COALESCE(
         tmp_ambdiag_diagnosis.diagdat,
         ambfall.beginndatamb,
         ambfall.endedatamb
      ) is NULL THEN make_date(
         LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
         (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
         01
      )
      ELSE TO_DATE(
         COALESCE(
            tmp_ambdiag_diagnosis.diagdat,
            ambfall.beginndatamb,
            ambfall.endedatamb
         ) :: VARCHAR,
         'YYYYMMDD'
      )
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
   CONCAT(
      tmp_ambdiag_diagnosis.icdamb_code,
      ',',
      tmp_ambdiag_diagnosis.diaglokal
   ) AS measurement_source_value,
   COALESCE(
      tmp_ambdiag_diagnosis.condition_source_concept_id,
      0
   ) AS measurement_source_concept_id,
   NULL AS unit_source_value,
   NULL AS unit_source_concept_id,
   NULL AS value_source_value,
   NULL AS measurement_event_id,
   NULL AS meas_event_field_concept_id
FROM
   tmp_ambdiag_diagnosis
   LEFT JOIN ambulante_faelle.ambfall ambfall ON tmp_ambdiag_diagnosis.fallidamb = ambfall.fallidamb and  tmp_ambdiag_diagnosis.vsid = ambfall.vsid
   LEFT JOIN {target_schema}.visit_occurrence vo  ON tmp_ambdiag_diagnosis.fallidamb = vo.fallidamb_temp and tmp_ambdiag_diagnosis.vsid = vo.vsid_temp
WHERE
   tmp_ambdiag_diagnosis.domain_id = 'Measurement';

DROP TABLE IF EXISTS tmp_ambdiag_diagnosis CASCADE;