/*
 Versichertenstammdaten SA151 (Masta data) to person
 - gender
 - year of birth
 SA999 - Amtlicher Gemeindeschlüssel to person 
 -  Gemeindeschluessel to location_id
 */
/* update person data which already exists in the table*/
UPDATE
   {target_schema}.person
SET
   year_of_birth = COALESCE (sa151.sa151_geburtsjahr, year_of_birth),
   gender_concept_id = case
      sa151.sa151_geschlecht
      when 1 then 8532 --female
      when 2 then 8507 --male
      else gender_concept_id
   end,
   location_id = COALESCE (sa999.sa999_gs, location_id),
   gender_source_value = COALESCE (
      sa151.sa151_geschlecht :: VARCHAR,
      gender_source_value
   )
FROM
   {source_schema}.{table}sa151 sa151
   LEFT JOIN {source_schema}.{table}sa999 sa999 ON sa151.sa151_psid = sa999.sa999_psid
WHERE
   person_source_value = sa151.sa151_psid;

/* Insert not existing persons*/
INSERT INTO
   {target_schema}.person (
      person_source_value,
      year_of_birth,
      gender_concept_id,
      month_of_birth,
      day_of_birth,
      location_id,
      birth_datetime,
      race_concept_id,
      -- set to 0 (not given) 
      ethnicity_concept_id,
      -- set to 0 (not given) 
      provider_id,
      care_site_id,
      gender_source_value,
      gender_source_concept_id,
      race_source_value,
      race_source_concept_id,
      ethnicity_source_value,
      ethnicity_source_concept_id
   )
SELECT
   DISTINCT ON (sa151.sa151_psid) sa151.sa151_psid AS person_source_value,
   sa151.sa151_geburtsjahr AS year_of_birth,
   case
      sa151.sa151_geschlecht
      when 1 then 8532 --female
      when 2 then 8507 --male
      else 0
   end AS gender_concept_id,
   NULL AS month_of_birth,
   NULL AS day_of_birth,
   sa999.sa999_gs AS location_id,
   NULL AS birth_datetime,
   0 AS race_concept_id,
   0 AS ethnicity_concept_id,
   NULL AS provider_id,
   NULL AS care_site_id,
   sa151.sa151_geschlecht AS gender_source_value,
   NULL AS gender_source_concept_id,
   NULL AS race_source_value,
   NULL AS race_source_concept_id,
   NULL AS ethnicity_source_value,
   NULL AS ethnicity_source_concept_id
FROM
   {source_schema}.{table}sa151 sa151
   LEFT JOIN {source_schema}.{table}sa999 sa999 ON sa151.sa151_psid = sa999.sa999_psid
WHERE
   NOT EXISTS (
      SELECT
         1
      FROM
         {target_schema}.person
      WHERE
         person_source_value = sa151.sa151_psid
   );