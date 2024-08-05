-- dialysesachkosten
INSERT INTO
    {target_schema}.cost (
        cost_id,
        cost_event_id,
        cost_domain_id,
        cost_type_concept_id,
        currency_concept_id,
        total_charge,
        total_cost,
        total_paid,
        paid_by_payer,
        paid_by_patient,
        paid_patient_copay,
        paid_patient_coinsurance,
        paid_patient_deductible,
        paid_by_primary,
        paid_ingredient_cost,
        paid_dispensing_fee,
        payer_plan_period_id,
        amount_allowed,
        revenue_code_concept_id,
        revenue_code_source_value,
        drg_concept_id,
        drg_source_value
    )
SELECT
    nextval('{target_schema}.cost_id'),
    ambfall.fallidamb AS cost_event_id,
    'Visit' AS cost_domain_id,
    32810 AS cost_type_concept_id,
    44818568 AS currency_concept_id,
    ambfall.dialysesachko AS total_charge,
    NULL AS total_cost,
    NULL AS total_paid,
    NULL AS paid_by_payer,
    NULL AS paid_by_patient,
    NULL AS paid_patient_copay,
    NULL AS paid_patient_coinsurance,
    NULL AS paid_patient_deductible,
    NULL AS paid_by_primary,
    NULL AS paid_ingredient_cost,
    NULL AS paid_dispensing_fee,
    ppp.payer_plan_period_id AS payer_plan_period_id,
    NULL AS amount_allowed,
    NULL AS revenue_code_concept_id,
    NULL AS revenue_code_source_value,
    NULL AS drg_concept_id,
    NULL AS drg_source_value
FROM
    ambulante_faelle.ambfall ambfall
    LEFT JOIN {target_schema}.payer_plan_period ppp ON ambfall.arbnr = ppp.person_id
    and make_date(
        LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
        (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
        01
    ) BETWEEN ppp.payer_plan_period_start_date
    AND ppp.payer_plan_period_end_date
WHERE
    ambfall.dialysesachko IS NOT NULL;

--All other costs of type visit
INSERT INTO
    {target_schema}.cost (
        cost_id,
        cost_event_id,
        cost_domain_id,
        -- Visit
        cost_type_concept_id,
        -- Based on maped table  32810 Claim 32816  Dental Claim 
        currency_concept_id,
        -- 44818568 Euro
        total_charge,
        total_cost,
        total_paid,
        paid_by_payer,
        paid_by_patient,
        paid_patient_copay,
        paid_patient_coinsurance,
        paid_patient_deductible,
        paid_by_primary,
        paid_ingredient_cost,
        paid_dispensing_fee,
        payer_plan_period_id,
        amount_allowed,
        revenue_code_concept_id,
        revenue_code_source_value,
        drg_concept_id,
        drg_source_value
    )
SELECT
    nextval('{target_schema}.cost_id'),
    ambfall.fallidamb AS cost_event_id,
    'Visit' AS cost_domain_id,
    32810 AS cost_type_concept_id,
    --Claim
    44818568 AS currency_concept_id,
    --Euro 
    -- punktzahl * 5,82873 Cent 
    (0.0582873 * COALESCE(ambfall.punktzahl, 0)) + COALESCE(ambfall.fallkoamb, 0) AS total_charge,
    NULL AS total_cost,
    NULL AS total_paid,
    NULL AS paid_by_payer,
    NULL AS paid_by_patient,
    NULL AS paid_patient_copay,
    NULL AS paid_patient_coinsurance,
    NULL AS paid_patient_deductible,
    NULL AS paid_by_primary,
    NULL AS paid_ingredient_cost,
    NULL AS paid_dispensing_fee,
    ppp.payer_plan_period_id AS payer_plan_period_id,
    NULL AS amount_allowed,
    NULL AS revenue_code_concept_id,
    NULL AS revenue_code_source_value,
    NULL AS drg_concept_id,
    NULL AS drg_source_value
FROM
    ambulante_faelle.ambfall ambfall
    LEFT JOIN {target_schema}.payer_plan_period ppp ON ambfall.arbnr = ppp.person_id
    and make_date(
        LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
        (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
        01
    ) BETWEEN ppp.payer_plan_period_start_date
    AND ppp.payer_plan_period_end_date
WHERE
    ambfall.punktzahl IS NOT NULL
    OR ambfall.fallkoamb IS NOT NULL;