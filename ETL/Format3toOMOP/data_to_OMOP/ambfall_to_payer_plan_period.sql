/*
 Payer_plan_period captures the basic information of the health insurance contract which is identified by svnr
 */

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
    DISTINCT ON (ambfall.psid, ambfall.vsid, vers.bnr) 
    nextval('{target_schema}.payer_plan_period_id'),
    ambfall.psid AS person_id,
    make_date(
        LEFT(MIN(ambfall.abrq)::VARCHAR, 4)::int, 
        (1 + (RIGHT(MIN(ambfall.abrq)::VARCHAR, 1)::int - 1) * 3), 
        1
    ) AS payer_plan_period_start_date,
    make_date(
        LEFT(MAX(ambfall.abrq)::VARCHAR, 4)::int, 
        (RIGHT(MAX(ambfall.abrq)::VARCHAR, 1)::int * 3), 
        1
    ) + interval '1 Month -1 day' AS payer_plan_period_end_date,
    NULL AS payer_concept_id,
    vers.bnr AS payer_source_value,
    NULL AS payer_source_concept_id,
    NULL AS plan_concept_id,
    -- only for selective contracts (more information is needed!) alphanumeric to numeric 
    LAST_VALUE(ambfall.svnr) OVER(
        PARTITION BY ambfall.psid
        ORDER BY ambfall.abrq
    ) AS plan_source_value,
    NULL AS plan_source_concept_id,
    NULL AS sponsor_concept_id,
    LAST_VALUE(ambfall.svtyp) OVER(
        PARTITION BY ambfall.psid
        ORDER BY ambfall.abrq
    ) AS sponsor_source_value,
    NULL AS sponsor_source_concept_id,
    NULL AS family_source_value,
    NULL AS stop_reason_concept_id,
    NULL AS stop_reason_source_value,
    NULL AS stop_reason_source_concept_id
FROM
    ambulante_faelle.ambfall ambfall
    LEFT JOIN versicherte.vers vers ON ambfall.psid = vers.psid
GROUP BY
    ambfall.psid, ambfall.vsid, vers.bnr;