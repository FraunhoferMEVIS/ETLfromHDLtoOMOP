CREATE TEMPORARY TABLE tmp_obs AS (
   SELECT
      versq.psid,
      make_date(LEFT(MIN(versq.versq)::VARCHAR, 4)::INT, (1 + (RIGHT(MIN(versq.versq)::VARCHAR, 1)::INT - 1) * 3), 01) AS update_start_date,
      make_date(LEFT(MAX(versq.versq)::VARCHAR, 4)::INT, ((RIGHT(MAX(versq.versq)::VARCHAR, 1)::INT) * 3), 01) + INTERVAL '1 Month -1 day' AS update_end_date
   FROM
      versicherte.versq versq
   GROUP BY
      versq.psid
);

UPDATE
   {target_schema}.observation_period op
SET
   observation_period_start_date = LEAST(tmp_obs.update_start_date, op.observation_period_start_date),
   observation_period_end_date = GREATEST(tmp_obs.update_end_date, op.observation_period_end_date)
FROM
   tmp_obs
WHERE
   op.person_id = tmp_obs.psid
  ;

INSERT INTO
   {target_schema}.observation_period (
      observation_period_id,
      person_id,
      observation_period_start_date,
      observation_period_end_date,
      period_type_concept_id
   )
SELECT
   nextval('{target_schema}.observation_period_id') AS observation_period_id,
   tmp_obs.psid AS person_id,
   tmp_obs.update_start_date AS observation_period_start_date,
   tmp_obs.update_end_date AS observation_period_end_date,
   32810 AS period_type_concept_id
FROM
   tmp_obs
WHERE
   NOT EXISTS (
      SELECT 1
      FROM {target_schema}.observation_period op
      WHERE op.person_id = tmp_obs.psid
   );
 DROP TABLE tmp_obs;