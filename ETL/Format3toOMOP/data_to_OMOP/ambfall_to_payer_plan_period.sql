/*
 Payer_plan_period captures the basic information of the health insurance contract which is identified by svnr
 */

with tmp_ppp as (
    SELECT
        ambfall.psid,
        RIGHT(MIN(ambfall.abrq) :: VARCHAR, 1) :: int AS start_quarter,
        RIGHT(MAX(ambfall.abrq) :: VARCHAR, 1) :: int AS last_quarter,
        LEFT(MAX(ambfall.abrq) :: VARCHAR, 4) :: int AS end_year,
        LEFT(MIN(ambfall.abrq) :: VARCHAR, 4) :: int AS start_year
    FROM
        ambulante_faelle.ambfall ambfall
    GROUP BY
        ambfall.psid, ambfall.kassenik)
INSERT INTO
    {target_schema}.payer_plan_period (
        payer_plan_period_id,
        person_id,
        payer_plan_period_start_date,
        payer_plan_period_end_date,
        payer_concept_id,
        payer_source_value,
        payer_source_concept_id,
        plan_concept_id,
        plan_source_value,
        plan_source_concept_id,
        sponsor_concept_id,
        sponsor_source_value,
        sponsor_source_concept_id,
        family_source_value,
        stop_reason_concept_id,
        stop_reason_source_value,
        stop_reason_source_concept_id
    )
SELECT
    DISTINCT ON (ambfall.psid,ambfall.kassenik ) 
    nextval('{target_schema}.payer_plan_period_id'),
    ambfall.psid AS person_id,
    make_date(tmp_ppp.start_year, (1 +(tmp_ppp.start_quarter -1) * 3), 01) AS payer_plan_period_start_date,
    make_date(tmp_ppp.end_year, ((tmp_ppp.last_quarter) * 3), 01) + interval '1 Month -1 day' AS payer_plan_period_end_date,
    NULL AS payer_concept_id,
    ambfall.kassenik AS payer_source_value,
    NULL AS payer_source_concept_id,
    NULL AS plan_concept_id,
    -- only for selective contracts (more information is needed!) alphanumeric to numeric 
    LAST_VALUE(ambfall.svnr) OVER(
        PARTITION BY ambfall.psid
        ORDER BY
            ambfall.abrq
    ) as plan_source_value,
    NULL AS plan_source_concept_id,
    NULL AS sponsor_concept_id,
    LAST_VALUE(ambfall.svtyp) OVER(
        PARTITION BY ambfall.psid
        ORDER BY
            ambfall.abrq
    ) as sponsor_source_value,
    NULL AS sponsor_source_concept_id,
    NULL AS family_source_value,
    NULL AS stop_reason_concept_id,
    NULL AS stop_reason_source_value,
    NULL AS stop_reason_source_concept_id
FROM
    ambulante_faelle.ambfall ambfall
    LEFT JOIN tmp_ppp tmp_ppp ON tmp_ppp.psid = ambfall.psid;