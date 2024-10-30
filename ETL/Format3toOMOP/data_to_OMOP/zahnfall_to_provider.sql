/*
 Full join on pseudonym physician  identifier number
 */
INSERT INTO
    {target_schema}.provider (
        provider_id,
        provider_name,
        npi,
        dea,
        specialty_source_value,
        specialty_concept_id,
        specialty_source_concept_id,
        care_site_id,
        year_of_birth,
        gender_concept_id,
        provider_source_value,
        gender_source_value,
        gender_source_concept_id
    )
SELECT
    DISTINCT ON (zahnfall.zanrabrpseudo) -- Only "dentist" no seperation into specalisation of dentists 
    zahnfall.zanrabrpseudo AS provider_id,
    NULL AS provider_name,
    NULL AS npi,
    NULL AS dea,
    zahnfall.zakzv AS specialty_source_value,
    38003675 AS specialty_concept_id,
    0 AS specialty_source_concept_id,
    NULL AS care_site_id,
    NULL AS year_of_birth,
    NULL AS gender_concept_id,
    zahnfall.zanrabrpseudo AS provider_source_value,
    NULL AS gender_source_value,
    NULL AS gender_source_concept_id
FROM
    ambulante_faelle.zahnfall 
    WHERE 
        zahnfall.zanrabrpseudo IS NOT NULL
    ON CONFLICT (provider_id) DO NOTHING;


/*
 Full join on pseudonym physician  identifier number
 */
INSERT INTO
    {target_schema}.provider (
        provider_id,
        provider_name,
        npi,
        dea,
        specialty_source_value,
        specialty_concept_id,
        specialty_source_concept_id,
        care_site_id,
        year_of_birth,
        gender_concept_id,
        provider_source_value,
        gender_source_value,
        gender_source_concept_id
    )
SELECT
    DISTINCT ON (zahnfall.zanrpseudo) -- Only "dentist" no seperation into specalisation of dentists 
    zahnfall.zanrpseudo AS provider_id,
    NULL AS provider_name,
    NULL AS npi,
    NULL AS dea,
    zahnfall.zakzv AS specialty_source_value,
    38003675 AS specialty_concept_id,
    0 AS specialty_source_concept_id,
    NULL AS care_site_id,
    NULL AS year_of_birth,
    NULL AS gender_concept_id,
    zahnfall.zanrpseudo AS provider_source_value,
    NULL AS gender_source_value,
    NULL AS gender_source_concept_id
FROM
    ambulante_faelle.zahnfall 
    WHERE 
        zahnfall.zanrpseudo IS NOT NULL 
    ON CONFLICT (provider_id) DO NOTHING;

