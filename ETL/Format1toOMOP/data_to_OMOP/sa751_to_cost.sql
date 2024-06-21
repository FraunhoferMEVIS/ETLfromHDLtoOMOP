/*
 SA751 - Leistungsausgaben to cost 
 - costs
 - and cost domain ( e.g
 dental, pharmacy)
 */
with tmp as (
    SELECT
        sa751_psid2,
        sa751_aerzte,
        sa751_zahnaerzte,
        sa751_apotheken,
        sa751_krankenhaeuser,
        sa751_sonstigela,
        sa751_sachkostendialyse,
        sa751_krankengeld,
        32871 as sa751_aerzte_dummy,
        32816 as sa751_zahnaerzte_dummy,
        32869 as sa751_apotheken_dummy,
        32852 as sa751_krankenhaeuser_dummy,
        0 as sa751_sonstigela_dummy,
        0 as sa751_sachkostendialyse_dummy,
        1 as sa751_krankengeld_dummy
    FROM
        {source_schema}.{table}sa751
)
INSERT INTO
    {target_schema}.cost (
        payer_plan_period_id,
        cost_domain_id,
        -- 31985 Cost
        total_cost,
        cost_type_concept_id,
        currency_concept_id,
        total_charge,
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
    -- cost_id generated,
    -- cost_event_id generated,
    tmp.sa751_psid2 AS payer_plan_period_id,
    case
        tmp.{column}_dummy
        when 32869 then 'Drug'
        when 0 then 'Payer'
        when 1 then 'Procedure'
        else 'Visit'
    end AS cost_domain_id,
    tmp.{column} AS total_charge,
    case
        tmp.{column}_dummy
        when 1 then 0
        else tmp.{column}_dummy
    end AS cost_type_concept_id,
    44818568 AS currency_concept_id,
    --Euro
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
    NULL AS amount_allowed,
    NULL AS revenue_code_concept_id,
    NULL AS revenue_code_source_value,
    NULL AS drg_concept_id,
    NULL AS drg_source_value
FROM
    tmp;