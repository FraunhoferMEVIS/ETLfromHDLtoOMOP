/*
 Join khfall and khfa for visit occurence
 */
INSERT INTO
    {target_schema}.visit_occurrence (
        visit_type_concept_id,
        -- 32810 Claim
        visit_occurrence_id,
        person_id,
        provider_id,
        care_site_id,
        visit_concept_id,
        visit_source_concept_id,
        -- Hospital
        visit_start_date,
        visit_start_datetime,
        visit_end_date,
        visit_end_datetime,
        visit_source_value,
        admitted_from_concept_id,
        admitted_from_source_value,
        discharged_to_concept_id,
        discharged_to_source_value,
        preceding_visit_occurrence_id,
        fallidkh_temp,
        vsid_temp
    )
SELECT
    32810 AS visit_type_concept_id,
    --claim
    nextval('{target_schema}.visit_occurrence_id'),
    khfall.psid AS person_id,
    -- pseudonym of admisison physican  
    khfall.einweispseudo AS provider_id,
    -- pseudonym of hospital  
    khfall.khpseudo AS care_site_id,
    Case
        when RIGHT(khfall.aufngrund :: VARCHAR, 2) IN ('03', '04', '10') then 8756 --outpatient hospital
        else 8717 -- inpatient hospital 
    END AS visit_concept_id,
    4318944 AS visit_source_concept_id,
    TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD') AS visit_start_date,
    NULL as visit_start_datetime,
    CASE 
        WHEN khfa.entlassdat IS NULL  THEN TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD')
        ELSE TO_DATE(khfa.entlassdat :: VARCHAR, 'YYYYMMDD')
    END AS visit_end_date,
    CASE 
        WHEN khfa.entlassdat IS NULL 
        THEN NULL
        ELSE to_timestamp(
        CONCAT(
            khfa.entlassdat :: VARCHAR,
            khfa.entlasszeit :: VARCHAR
        ),
        'YYYYMMDDHH24MI'
    )END AS visit_end_datetime,
    khfall.aufngrund AS visit_source_value,
    case
        when khfall.veranlassstellepseudo != '' then 8870 --	Emergency Room - Hospital 
        when khfall.veranlasskhpseudo :: VARCHAR != '' then 38004515 -- admitted from other hospital 
        else 0
    END AS admitted_from_concept_id,
    COALESCE(
        khfall.veranlassstellepseudo,
        khfall.veranlasskhpseudo :: VARCHAR
    ) AS admitted_from_source_value,
    Case
        when LEFT(khfall.entlassgrund :: VARCHAR, 2) = '11' then 8546 -- hospice 
        when LEFT(khfall.entlassgrund :: VARCHAR, 2) IN ('23', '16', '10', '24') then 8676 --nursing facility
        when LEFT(khfall.entlassgrund :: VARCHAR, 2) IN('18', '17', '08', '12', '06') then 8717 -- inpatient hospital 
        when LEFT(khfall.entlassgrund :: VARCHAR, 2) IN('14', '15') then 8756 --outpatient hospital
        when LEFT(khfall.entlassgrund :: VARCHAR, 2) = '13' then 8976 --Psychiatric Residential Treatment Center
        when LEFT(khfall.entlassgrund :: VARCHAR, 2) = '26' then 9201 --inpatient visit
        when LEFT(khfall.entlassgrund :: VARCHAR, 2) = '09' then 38004285 --Rehabilitation Hospital
        else 0 -- discharged,death, transferred but not clear to which facility
    end as discharged_to_concept_id,
    khfall.entlassgrund AS discharged_to_source_value,
    NULL AS preceding_visit_occurrence_id,
    khfall.fallidkh as fallidkh_temp,
    khfall.vsid as vsid_temp
FROM
    stationaere_faelle.khfall khfall
    LEFT JOIN ( SELECT DISTINCT ON(khfa.fallidkh,khfa.vsid, khfa.entlassdat,khfa.entlasszeit )
     khfa.fallidkh,khfa.vsid, khfa.entlassdat,khfa.entlasszeit 
      FROM stationaere_faelle.khfa ) khfa ON khfall.fallidkh = khfa.fallidkh  and khfall.vsid = khfa.vsid
;