INSERT INTO
  {target_schema}.visit_occurrence (
    visit_occurrence_id,
    person_id,
    visit_start_date,
    visit_start_datetime,
    visit_end_date,
    visit_concept_id,
    visit_source_concept_id,
    provider_id,
    visit_source_value,
    visit_end_datetime,
    visit_type_concept_id,
    care_site_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    discharged_to_concept_id,
    discharged_to_source_value,
    preceding_visit_occurrence_id,
    fallidamb_temp,
    vsid_temp
  )
SELECT
  nextval('{target_schema}.visit_occurrence_id'),
  ambfall.psid AS person_id,
  CASE
    WHEN COALESCE(ambfall.beginndatamb, ambfall.endedatamb) is NULL THEN make_date(
      LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
      (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
      01
    )
    ELSE TO_DATE(
      COALESCE(ambfall.beginndatamb, ambfall.endedatamb) :: VARCHAR,
      'YYYYMMDD'
    )
  END AS visit_start_date,
  NULL AS visit_start_datetime,
  CASE
    WHEN COALESCE(ambfall.endedatamb, ambfall.beginndatamb) is NULL THEN make_date(
      LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
      (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
      01
    )
    ELSE TO_DATE(
      COALESCE(ambfall.endedatamb, ambfall.beginndatamb) :: VARCHAR,
      'YYYYMMDD'
    )
  END AS visit_end_date,
  CASE
    ambfall.behandartamb
    WHEN '1' then 9202 -- ambulant (default) => 9202 Outpatient Visit 
    WHEN '2' then 9201 -- stationär =>  9201 Inpatient Visit  
    ELSE 0
  END AS visit_concept_id,
  NULL AS visit_source_concept_id,
  ambleist.lanrpseudo AS provider_id,
  ambfall.behandartamb AS visit_source_value,
  NULL AS visit_end_datetime,
  32810 AS visit_type_concept_id,
  --Claim
  ambfall.bsnrpseudo AS care_site_id,
  NULL AS admitted_from_concept_id,
  NULL AS admitted_from_source_value,
  NULL AS discharged_to_concept_id,
  NULL AS discharged_to_source_value,
  NULL AS preceding_visit_occurrence_id,
  ambfall.fallidamb as fallidamb_temp,
  ambfall.vsid as vsid_temp
FROM
  ambulante_faelle.ambfall ambfall
  LEFT JOIN ambulante_faelle.ambleist ambleist ON ambfall.fallidamb = ambleist.fallidamb and ambfall.vsid = ambleist.vsid
;