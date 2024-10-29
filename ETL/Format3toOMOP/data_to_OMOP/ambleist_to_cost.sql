INSERT INTO
    {target_schema}.cost (
        cost_id,
        cost_event_id,
        cost_domain_id,
        -- Visit
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
    vo.visit_occurrence_id AS cost_event_id,
    'Visit' AS cost_domain_id,
    32810 AS cost_type_concept_id,
    --Claim
    44818568 AS currency_concept_id,
    --Euro
    -- multiplikator* gonrbewert 
    -- Based on EBM "the value of the service"  in Euro  (Bewertung der Gebührenordnungsnummer) 
    ambleist.multiplikator * CAST(ambleist.gonrbewert AS NUMERIC) AS total_charge,
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
    NULL AS payer_plan_period_id,
    NULL AS amount_allowed,
    NULL AS revenue_code_concept_id,
    NULL AS revenue_code_source_value,
    NULL AS drg_concept_id,
    NULL AS drg_source_value
FROM
    ambulante_faelle.ambleist
    LEFT JOIN (
        SELECT DISTINCT ON (fallidamb_temp, vsid_temp, visit_occurrence_id)
            fallidamb_temp,
            vsid_temp,
            visit_occurrence_id
        FROM {target_schema}.visit_occurrence
    ) vo ON ambleist.fallidamb = vo.fallidamb_temp and ambleist.vsid = vo.vsid_temp
WHERE
    ambleist.gonrbewert IS NOT NULL AND ambleist.gonrbewert != ''
    AND ambleist.multiplikator IS NOT NULL AND ambleist.multiplikator  !='';