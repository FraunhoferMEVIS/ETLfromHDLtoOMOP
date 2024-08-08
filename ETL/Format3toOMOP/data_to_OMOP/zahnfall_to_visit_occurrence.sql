/*
 Full join on pseudonym physician  identifier number
 */
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
      fallid_temp,
      vsid_temp
   )
SELECT
   nextval('{target_schema}.visit_occurrence_id'),
   zahnfall.psid AS person_id,
   CASE
      WHEN COALESCE(zahnfall.beginndatzahn, zahnfall.endedatzahn) is NULL THEN CASE
         WHEN zahnfall.leistq IS NULL THEN make_date(zahnfall.berjahr :: integer, 01, 01)
         ELSE make_date(
            LEFT(zahnfall.leistq :: VARCHAR, 4) :: integer,
            (RIGHT(zahnfall.leistq :: VARCHAR, 1) :: integer -1) * 3 + 1,
            01
         )
      END
      ELSE TO_DATE(
         COALESCE(zahnfall.beginndatzahn, zahnfall.endedatzahn) :: VARCHAR,
         'YYYYMMDD'
      )
   END as visit_start_date,
   NULL AS visit_start_datetime,
   CASE
      WHEN COALESCE(zahnfall.endedatzahn, zahnfall.beginndatzahn) is NULL THEN CASE
         WHEN zahnfall.leistq IS NULL THEN make_date(zahnfall.berjahr :: integer, 01, 01)
         ELSE make_date(
            LEFT(zahnfall.leistq :: VARCHAR, 4) :: integer,
            (RIGHT(zahnfall.leistq :: VARCHAR, 1) :: integer -1) * 3 + 1,
            01
         )
      END
      ELSE TO_DATE(
         COALESCE(zahnfall.endedatzahn, zahnfall.beginndatzahn) :: VARCHAR,
         'YYYYMMDD'
      )
   END AS visit_end_date,
   38004218 AS visit_concept_id,
   -- 38004218 Ambulatory Dental Clinic / Center 
   NULL AS visit_source_concept_id,
   COALESCE(zahnfall.zanrpseudo, zahnfall.zanrabrpseudo)  AS provider_id,
   CASE
      zahnfall.inansprartzahn
      WHEN 'A' then 'A: Regular treatment'
      WHEN 'F' then 'F: early treatment'
      WHEN 'V' then 'V: Prolonged treatment'
      WHEN 'L' then 'L: Empty quarter'
      WHEN 'D' then 'D: Diagnostics or individual measures'
      WHEN 'N' then 'N: Emergency stand-in'
      WHEN 'R' then 'R: Retention quarter'
      ELSE zahnfall.inansprartzahn
   END AS visit_source_value,
   NULL AS visit_end_datetime,
   32816 AS visit_type_concept_id,
   -- Dental Claim 
   NULL AS care_site_id,
   NULL AS admitted_from_concept_id,
   NULL AS admitted_from_source_value,
   NULL AS discharged_to_concept_id,
   NULL AS discharged_to_source_value,
   NULL AS preceding_visit_occurrence_id,
   zahnfall.fallidzahn as fallid_temp,
   NULL as vsid_temp
FROM
   ambulante_faelle.zahnfall
 ;