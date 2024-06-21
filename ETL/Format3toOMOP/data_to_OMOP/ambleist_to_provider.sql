With pg as (
    SELECT
        cp.concept_code :: integer,
        rel.concept_id_1,
        rel.concept_id_2
    FROM
        {target_schema}.concept cp
        INNER JOIN {target_schema}.concept_relationship rel ON cp.concept_id = rel.concept_id_1
    WHERE
        cp.domain_id = 'Provider'
        AND cp.vocabulary_id = 'KGV-SV Fachgruppen'
        AND cp.invalid_reason IS NULL
        AND rel.relationship_id = 'Maps to'
        AND rel.invalid_reason IS NULL
)
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
    DISTINCT ON (ambleist.lanrpseudo) -- [MAPPING COMMENT] link to care_site with fallidamb 
    ambleist.lanrpseudo AS provider_id,
    NULL AS provider_name,
    NULL AS npi,
    NULL AS dea,
    ambleist.lanrfg AS specialty_source_value,
    COALESCE(pg.concept_id_2, 0) AS specialty_concept_id,
    COALESCE(pg.concept_id_1, 0) AS specialty_source_concept_id,
    ambfall.bsnrpseudo AS care_site_id,
    NULL AS year_of_birth,
    NULL AS gender_concept_id,
    ambleist.lanrpseudo AS provider_source_value,
    NULL AS gender_source_value,
    NULL AS gender_source_concept_id
FROM
    ambulante_faelle.ambleist ambleist
    LEFT JOIN ambulante_faelle.ambfall ambfall ON ambleist.fallidamb = ambfall.fallidamb
    LEFT JOIN pg ON ambleist.lanrfg = pg.concept_code
WHERE
    ambleist.lanrpseudo IS NOT NULL ON CONFLICT (provider_id) DO NOTHING;