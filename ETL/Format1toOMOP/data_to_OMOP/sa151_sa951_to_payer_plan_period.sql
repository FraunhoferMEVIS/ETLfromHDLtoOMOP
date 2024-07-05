/*
 Versichertenstammdaten 151 (Masta data) to payer_plan_period:
 - defining payer_plan_period with psid2 and insured days
 */
INSERT INTO
    {target_schema}.payer_plan_period (
        payer_plan_period_id,
        person_id,
        payer_plan_period_start_date,
        payer_plan_period_end_date,
        payer_concept_id,
        payer_source_concept_id,
        payer_source_value,
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
    DISTINCT ON (sa151.sa151_psid, sa151.sa151_psid2) sa151.sa151_psid2 AS payer_plan_period_id,
    per.person_id AS person_id,
    make_date(sa151.sa151_berichtsjahr :: int, 01, 01) AS payer_plan_period_start_date,
    make_date(sa151.sa151_berichtsjahr :: int, 12, 31) AS payer_plan_period_end_date,
    0 AS payer_concept_id,
    sa951.sa951_betriebsnummer AS payer_source_concept_id,
    NULL AS payer_source_value,
    NULL AS plan_concept_id,
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
    {source_schema}.{table}sa151 sa151
    INNER JOIN {target_schema}.person per ON sa151.sa151_psid = per.person_source_value
    INNER JOIN {source_schema}.{table}sa951 sa951 ON sa951.sa951_psid2 = sa151.sa151_psid2;