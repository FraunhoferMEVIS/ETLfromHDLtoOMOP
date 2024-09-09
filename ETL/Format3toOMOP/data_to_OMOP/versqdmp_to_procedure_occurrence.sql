/*
 Disease-Management-Programms -> These programs are not kept in OPS or ICD
 Needs to be captured individually
 */
INSERT INTO
    {target_schema}.procedure_occurrence (
        procedure_occurrence_id,
        person_id,
        procedure_date,
        procedure_datetime,
        procedure_end_date,
        -- We assume  a program duration of one quarter, since we do not know when the program started. 
        procedure_source_value,
        procedure_source_concept_id,
        procedure_concept_id,
        quantity,
        procedure_end_datetime,
        procedure_type_concept_id,
        -- 32810 Claim
        modifier_concept_id,
        provider_id,
        visit_occurrence_id,
        visit_detail_id,
        modifier_source_value
    )
SELECT
    nextval('{target_schema}.procedure_occurrence_id'),
    versqdmp.psid AS person_id,
    make_date(
        LEFT(versqdmp.versq :: VARCHAR, 4) :: int,
        1 + ((RIGHT(versqdmp.versq :: VARCHAR, 1) :: int) -1) * 3,
        01
    ) AS procedure_date,
    NULL AS procedure_datetime,
    make_date(
        LEFT(versqdmp.versq :: VARCHAR, 4) :: int,
        ((RIGHT(versqdmp.versq :: VARCHAR, 1) :: int)) * 3,
        01
    ) + Interval '1 Month -1 Day' AS procedure_end_date,
    case
        versqdmp.dmpprog
        when '1' then '1: Diabetes mellitus type 2 dmp'
        when '2' then '2: Breast cancer dmp'
        when '3' then '3: Coronary heart dmp'
        when '4' then '4: Diabetes mellitus type 1 dmp'
        when '5' then '5: Bronchial asthma dmp'
        when '6' then '6: COPD dmp'
        when '7' then '7: Chronic heart failure dmp'
        when '8' then '8: Depression dmp'
        when '9' then '9: Back pain dmp'
        when '10' then '10: Rheumatoid arthritis dmp'
        when '11' then '11: Osteoporosis dmp'
        else versqdmp.dmpprog
    end AS procedure_source_value,
    0 AS procedure_source_concept_id,
    case
        versqdmp.dmpprog
        when '1' then 45765969 --Agreeing on diabetes care plan 
        when '4' then 45765969 --Agreeing on diabetes care plan 
        when '5' then 37396658 -- Asthma action care planning
        when '6' then 44809305 -- Management of chronic obstructive pulmonary disease
        when '8' then 44810259 -- Agreeing on mental health care plan 
        else 4123847 -- Agreement of care plan; we could not find a target concept for all care plans 
    end AS procedure_concept_id,
    versqdmp.dmptage AS quantity, -- The exact number of days  
    NULL AS procedure_end_datetime,
    32810 AS procedure_type_concept_id,
    --Claim
    NULL AS modifier_concept_id,
    NULL AS provider_id,
    NULL AS visit_occurrence_id,
    NULL AS visit_detail_id,
    NULL AS modifier_source_value
FROM
    versicherte.versqdmp
WHERE
    versqdmp.dmptage != 0
    and versqdmp.dmptage IS NOT NULL;