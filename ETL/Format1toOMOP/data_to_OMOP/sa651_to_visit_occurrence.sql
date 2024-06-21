/*
 Ambulante Diagnosen (Outpatient diagnosis) to visit occurrence 
 - visit duration 
 - visit concept (outpatient, outpatient hospital ...)
 */
INSERT INTO
  {target_schema}.visit_occurrence (
    person_id,
    visit_start_date,
    visit_end_date,
    visit_start_datetime,
    visit_end_datetime,
    visit_concept_id,
    visit_source_value,
    visit_source_concept_id,
    visit_type_concept_id,
    -- 32810 Claim
    provider_id,
    care_site_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    discharged_to_concept_id,
    discharged_to_source_value,
    preceding_visit_occurrence_id,
    source_idx_inpatient,
    source_idx_outpatient
  )
SELECT
        DISTINCT ON (
            sa651.sa651_psid,
            sa651_leistungsquartal
        ) 
  per.person_id AS person_id,
  make_date(
    sa651.sa651_berichtsjahr :: int,
    (1 +(sa651.sa651_leistungsquartal -1) * 3) :: int,
    01
  ) AS visit_start_date,
  make_date(
    sa651.sa651_berichtsjahr :: int,
    (1 +(sa651.sa651_leistungsquartal -1) * 3) :: int,
    01
  ) AS visit_end_date,
  NULL AS visit_start_datetime,
  NULL AS visit_end_datetime,
  case
    sa651.sa651_abrechnungsweg
    when 1 then 9202 --Outpatient Visit  Diagnose gem. § 295 SGB V
    when 2 then 8756 --Outpatient Hospital Diagnose aus ambulanter Behandlung im Krankenhaus
    else 0 -- in source table 3 euqals otherwise
  end AS visit_concept_id,
  sa651.sa651_abrechnungsweg AS visit_source_value,
  NULL AS visit_source_concept_id,
  32810 AS visit_type_concept_id,
  -- 32810  Claim
  NULL AS provider_id,
  NULL AS care_site_id,
  NULL AS admitted_from_concept_id,
  NULL AS admitted_from_source_value,
  NULL AS discharged_to_concept_id,
  NULL AS discharged_to_source_value,
  NULL AS preceding_visit_occurrence_id,
  NULL AS source_idx_inpatient,
  CONCAT(sa651.sa651_berichtsjahr, sa651.sa651_leistungsquartal,'_',sa651_psid) AS source_idx_outpatient
FROM
  {source_schema}.{table}sa651 sa651
  LEFT JOIN {target_schema}.person per ON sa651.sa651_psid = per.person_source_value;