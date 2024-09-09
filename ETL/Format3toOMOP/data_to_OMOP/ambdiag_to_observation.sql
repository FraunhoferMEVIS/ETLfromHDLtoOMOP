/*
 Capture excluded diagnosis as observation
 */
INSERT INTO
    {target_schema}.observation (
        visit_occurrence_id,
        observation_date,
        observation_source_value,
        person_id,
        observation_concept_id,
        value_as_string,
        value_as_concept_id,
        observation_id,
        provider_id,
        observation_datetime,
        observation_type_concept_id,
        -- 32810 Claim 
        value_as_number,
        qualifier_concept_id,
        unit_concept_id,
        visit_detail_id,
        observation_source_concept_id,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    vo.visit_occurrence_id AS visit_occurrence_id,
    CASE
        WHEN ambdiag.diagdat IS NULL THEN 
            CASE
                WHEN COALESCE(ambfall.beginndatamb, ambfall.endedatamb) is NULL THEN make_date(
                    LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
                    (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
                    01
                ) -- first day of the quater abrq in format JJJJQ
                ELSE TO_DATE(
                    COALESCE(ambfall.beginndatamb, ambfall.endedatamb) :: VARCHAR,
                    'YYYYMMDD'
                )
            END
        ELSE TO_DATE(ambdiag.diagdat :: VARCHAR, 'YYYYMMDD')
    END AS observation_date,
    CONCAT(
        ambdiag.icdamb_code,
        ',',
        ambdiag.diagsich,
        ': Excluded Diagnosis'
    ) AS observation_source_value,
    ambdiag.psid AS person_id,
    -- Disorder excluded
    4199812 AS observation_concept_id,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    nextval('{target_schema}.observation_id'),
    NULL AS provider_id,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    --Claim
    NULL AS value_as_number,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS visit_detail_id,
    NULL AS observation_source_concept_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    ambulante_faelle.ambdiag ambdiag
    LEFT JOIN (
        SELECT DISTINCT ON (fallidamb, vsid, abrq, beginndatamb, endedatamb)
            fallidamb,
            vsid,
            abrq,
            beginndatamb,
            endedatamb
        FROM ambulante_faelle.ambfall
    ) ambfall ON ambdiag.fallidamb = ambfall.fallidamb AND ambdiag.vsid = ambfall.vsid AND ambdiag.diagdat IS NULL
    LEFT JOIN (
        SELECT DISTINCT ON (fallidamb_temp, vsid_temp, visit_occurrence_id)
            fallidamb_temp,
            vsid_temp,
            visit_occurrence_id
        FROM {target_schema}.visit_occurrence
    ) vo ON ambdiag.fallidamb = vo.fallidamb_temp AND ambdiag.vsid = vo.vsid_temp

WHERE
    ambdiag.diagsich = 'A';