/*
 Versichertenstammdaten 151 (Masta data) to observation_period:
 - observation period
 */
/* Update observation_table if period already exists for person_id*/

with tmp as (
   SELECT
      person_id,
      make_date(sa151.sa151_berichtsjahr :: int, 12, 31) as update_end_date,
      make_date(sa151.sa151_berichtsjahr :: int, 01, 01) as update_start_date
   FROM
      {source_schema}.{table}sa151 sa151
      INNER JOIN {target_schema}.person per ON sa151.sa151_psid = per.person_source_value
)
UPDATE
   {target_schema}.observation_period
SET
   observation_period_end_date = GREATEST(tmp.update_end_date,observation_period_end_date),
   observation_period_start_date = LEAST(tmp.update_start_date,observation_period_start_date)
FROM
   tmp
WHERE
   observation_period.person_id = tmp.person_id;

INSERT INTO
   {target_schema}.observation_period (
      person_id,
      observation_period_start_date,
      observation_period_end_date,
      period_type_concept_id
   )
SELECT
   DISTINCT ON (sa151.sa151_psid) -- observation_period_id automically generated
   per.person_id AS person_id,
   -- observation is set to whole year (assumption)
   make_date(sa151.sa151_berichtsjahr :: int, 01, 01) AS observation_period_start_date,
   make_date(sa151.sa151_berichtsjahr :: int, 12, 31) AS observation_period_end_date,
   -- 32810 Claim
   32810 AS period_type_concept_id
FROM
   {source_schema}.{table}sa151 sa151
   INNER JOIN {target_schema}.person per ON sa151.sa151_psid = per.person_source_value
WHERE
   NOT EXISTS (
      SELECT
         1
      FROM
         {target_schema}.observation_period
      WHERE
         person_id = per.person_id
   );