INSERT INTO
    {target_schema}.cost (
        payer_plan_period_id,
        cost_id,
        cost_event_id,
        cost_domain_id,
        cost_type_concept_id,
        -- 32810 Claim
        currency_concept_id,
        -- Euro
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
        amount_allowed,
        revenue_code_concept_id,
        revenue_code_source_value,
        drg_concept_id,
        drg_source_value
    )
SELECT
    pp.payer_plan_period_id AS payer_plan_period_id,
    nextval('{target_schema}.cost_id'),
    -- reznr is key of Drug table
    rez.reznr AS cost_event_id,
    'Drug' AS cost_domain_id,
    32810 AS cost_type_concept_id,
    --Claim
    44818568 AS currency_concept_id,
    --'Euro'
    rez.ambetrag AS total_charge,
    COALESCE(rez.ambetrag, 0) + COALESCE(rez.abschlaege, 0) AS total_cost,
    NULL AS total_paid,
    NULL AS paid_by_payer,
    COALESCE(rez.eigenbet, 0) + COALESCE(rez.zuzahlges, 0) AS paid_by_patient,
    NULL AS paid_patient_copay,
    NULL AS paid_patient_coinsurance,
    NULL AS paid_patient_deductible,
    NULL AS paid_by_primary,
    NULL AS paid_ingredient_cost,
    NULL AS paid_dispensing_fee,
    NULL AS amount_allowed,
    NULL AS revenue_code_concept_id,
    NULL AS revenue_code_source_value,
    NULL AS drg_concept_id,
    NULL AS drg_source_value
FROM
    arzneimittel.rez rez
    LEFT JOIN {target_schema}.payer_plan_period pp ON rez.psid = pp.person_id
    and TO_DATE(rez.abgabedat :: VARCHAR, 'YYYYMMDD') BETWEEN pp.payer_plan_period_start_date
    AND pp.payer_plan_period_end_date
WHERE
    rez.ambetrag IS NOT NULL
    OR rez.abschlaege IS NOT NULL
    OR rez.eigenbet IS NOT NULL
    OR rez.zuzahlges IS NOT NULL;