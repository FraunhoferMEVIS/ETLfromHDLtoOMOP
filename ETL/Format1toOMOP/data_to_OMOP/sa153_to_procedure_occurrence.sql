/*
 SA153 - Extrakorporale Blutreinigung to procedure_occurrence:
 */
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
  per.person_id AS person_id,
  make_date(sa153.sa153_berichtsjahr :: int, 01, 01) AS procedure_date,
  NULL AS visit_occurrence_id,
  --no visit information 
  -- Z49.1  37097686 ICD10GM => 4032243 SNOMED 
  4032243 AS procedure_concept_id,
  37097686 AS procedure_source_concept_id,
  NULL AS procedure_datetime,
  NULL AS procedure_end_date,
  NULL AS procedure_end_datetime,
  32810 AS procedure_type_concept_id,
  --Claim
  NULL AS modifier_concept_id,
  NULL AS quantity,
  NULL AS provider_id,
  'Z49.1' AS procedure_source_value,
  NULL AS modifier_source_value
FROM
  {source_schema}.{table}sa153 sa153
  INNER JOIN {target_schema}.person per ON sa153.sa153_psid = per.person_source_value
WHERE
  sa153.sa153_extrablutreinigung > 0;