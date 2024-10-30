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
    DISTINCT ON (versq.psid, versq.vsid, versq.bnr) 
    nextval('{target_schema}.payer_plan_period_id'),
    versq.psid AS person_id,
    make_date(
        LEFT(MIN(versq.versq)::VARCHAR, 4)::int, 
        (1 + (RIGHT(MIN(versq.versq)::VARCHAR, 1)::int - 1) * 3), 
        1
    ) AS payer_plan_period_start_date,  -- abrq format JJJJQ ->  Take the first 4 numbers and convert to year -> multiplicate quarter Q -1 by 3 and take the first day of the month
    make_date(
        LEFT(MAX(versq.versq)::VARCHAR, 4)::int, 
        (RIGHT(MAX(versq.versq)::VARCHAR, 1)::int * 3), 
        1
    ) + interval '1 Month -1 day' AS payer_plan_period_end_date,
    NULL AS payer_concept_id,
    versq.bnr AS payer_source_value,
    NULL AS payer_source_concept_id,
    NULL AS plan_concept_id,
    -- only for selective contracts (more information is needed!) alphanumeric to numeric 
    NULL AS plan_source_value,
    NULL AS plan_source_concept_id,
    NULL AS sponsor_concept_id,
    NULL AS sponsor_source_value,
    NULL AS sponsor_source_concept_id,
    NULL AS family_source_value,
    NULL AS stop_reason_concept_id,
    NULL AS stop_reason_source_value,
    NULL AS stop_reason_source_concept_id
FROM
    versicherte.versq versq
GROUP BY
    versq.psid, versq.vsid, versq.bnr,versq.versq;