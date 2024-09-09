/*
 Stationäre Diagnoses 
 Inpatient diagnosis to visit occurrence  
 - visit duration 
 - visit concept (inpatient, outpatient, ...)
 */
WITH dismiss_day as(
    SELECT
        DISTINCT ON (
            sa551.sa551_psid,
            sa551.sa551_entlassungsmonat,
            sa551.sa551_fallzaehler
        ) 
        sa551_psid,
        sa551.sa551_artbehandlung, 
        CONCAT(sa551.sa551_entlassungsmonat,sa551.sa551_fallzaehler,'_',sa551_psid) as idx_sa551,
        TO_DATE(concat(sa551_entlassungsmonat, 01), 'YYYYMMDD') as admissiondate,
        ROW_NUMBER () OVER (
            PARTITION BY sa551.sa551_psid,
            sa551.sa551_entlassungsmonat
            ORDER BY
                sa551.sa551_fallzaehler
        ) :: integer as day
    FROM
        {source_schema}.{table}sa551 sa551
)
INSERT INTO
    {target_schema}.visit_occurrence (
        person_id,
        visit_start_date,
        visit_start_datetime,
        visit_end_date,
        visit_end_datetime,
        visit_concept_id,
        visit_source_value,
        visit_source_concept_id,
        visit_type_concept_id,
        -- 32810 Claim
        provider_id,
        care_site_id,
        admitted_from_concept_id,
        admitted_from_source_value,
        discharged_to_concept_id,
        discharged_to_source_value,
        preceding_visit_occurrence_id,
        source_idx_inpatient,
        source_idx_outpatient
    )
SELECT
    per.person_id AS person_id,
    -- generated visit_occurrence_id,
    dd.admissiondate + dd.day -1 AS visit_start_date,
    NULL AS visit_start_datetime,
    dd.admissiondate + interval '1 month' - interval '1 day' AS visit_end_date,
    NULL AS visit_end_datetime,
    case
        dd.sa551_artbehandlung
        when 1 then 9201 --Inpatient
        when 2 then 38004207 --Ambulatory Clinic / Center
        when 3 then 8756 --Outpatient Hospital
        else 0
    end AS visit_concept_id,
    dd.sa551_artbehandlung AS visit_source_value,
    NULL AS visit_source_concept_id,
    32810 AS visit_type_concept_id,
    -- 32810 Claim
    NULL AS provider_id,
    NULL AS care_site_id,
    NULL AS admitted_from_concept_id,
    NULL AS admitted_from_source_value,
    NULL AS discharged_to_concept_id,
    NULL AS discharged_to_source_value,
    NULL AS preceding_visit_occurrence_id,
    dd.idx_sa551 AS source_idx_inpatient,
    NULL as source_idx_outpatient
FROM
    dismiss_day dd 
    INNER JOIN {target_schema}.person per ON dd.sa551_psid = per.person_source_value;