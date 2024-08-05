/*
 Ambulante Arzneimittel
 outpatient drugs
 */
/*
 Ambulante Arzneimittel (ambulatory drugs) to drug_exposure:
 - verordnungsdatum as start_date
 - PZN to drug_concept_id (no mapping yet)
 - anzahleneiniheitsfaktor to quantity
 */
INSERT INTO
    {target_schema}.drug_exposure (
        --generated drug_exposure_id,
        visit_detail_id,
        person_id,
        drug_exposure_start_date,
        drug_exposure_end_date,
        drug_concept_id,
        drug_source_concept_id,
        drug_source_value,
        drug_type_concept_id,
        -- 32810 Claim
        quantity,
        dose_unit_source_value,
        visit_occurrence_id,
        drug_exposure_start_datetime,
        drug_exposure_end_datetime,
        verbatim_end_date,
        stop_reason,
        refills,
        days_supply,
        sig,
        route_concept_id,
        lot_number,
        provider_id,
        route_source_value
    )
SELECT
    -- drug_exposure_id generated 
    NULL AS visit_detail_id,
    per.person_id AS person_id,
    to_date(sa451.sa451_verordnungsdatum :: VARCHAR, 'YYYYMMDD') AS drug_exposure_start_date,
    -- Assumption: drug_exposure_end_date + 29 days (OMOP recommendation)
    to_date(sa451.sa451_verordnungsdatum :: VARCHAR, 'YYYYMMDD') + INTERVAL '29' day AS drug_exposure_end_date,
    0 AS drug_concept_id,
    -- mapping not available
    0 AS drug_source_concept_id,
    sa451.sa451_pharmazentralnummer AS drug_source_value,
    32810 AS drug_type_concept_id,
    --Claim
    sa451.sa451_anzahleinheitenfaktor AS quantity,
    NULL AS dose_unit_source_value,
    NULL AS visit_occurrence_id,
    NULL AS drug_exposure_start_datetime,
    NULL AS drug_exposure_end_datetime,
    NULL AS verbatim_end_date,
    NULL AS stop_reason,
    NULL AS refills,
    NULL AS days_supply,
    NULL AS sig,
    NULL AS route_concept_id,
    NULL AS lot_number,
    NULL AS provider_id,
    NULL AS route_source_value
FROM
    {source_schema}.{table}sa451 sa451
    INNER JOIN {target_schema}.person per ON sa451.sa451_psid = per.person_source_value;