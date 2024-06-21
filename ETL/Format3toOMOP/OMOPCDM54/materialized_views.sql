CREATE MATERIALIZED VIEW IF NOT EXISTS {target_schema}.icd_standard_domain_lookup AS
SELECT
    concept1.concept_code AS source_code,
    concept1.concept_id AS condition_source_concept_id,
    rel.concept_id_2 AS condition_target_concept_id,
    concept2.domain_id AS domain_id
FROM
    (
        (
            (
                {target_schema}.concept concept1
                JOIN {target_schema}.concept_relationship rel ON ((concept1.concept_id = rel.concept_id_1))
            )
            JOIN {target_schema}.concept concept2 ON ((rel.concept_id_2 = concept2.concept_id))
        )
        JOIN {target_schema}.domain c3 ON (
            (
                (concept2.domain_id) :: TEXT = (c3.domain_id) :: TEXT
            )
        )
    )
WHERE
    (
        (1 = 1)
        AND rel.invalid_reason IS NULL
        AND concept1.invalid_reason IS NULL
        AND (
            (concept1.vocabulary_id) :: TEXT = 'ICD10GM' :: TEXT
        )
        AND ((rel.relationship_id) :: TEXT = 'Maps to' :: TEXT)
    );

CREATE MATERIALIZED VIEW IF NOT EXISTS {target_schema}.ops_standard_domain_lookup AS
SELECT
    concept1.concept_code AS source_code,
    concept1.concept_id AS procedure_source_concept_id,
    rel.concept_id_2 AS procedure_target_concept_id,
    concept2.domain_id AS domain_id
FROM
    (
        (
            {target_schema}.concept concept1
            JOIN {target_schema}.concept_relationship rel ON ((concept1.concept_id = rel.concept_id_1))
        )
        JOIN {target_schema}.concept concept2 ON ((rel.concept_id_2 = concept2.concept_id))
    )
    JOIN {target_schema}.domain c3 ON (
        (
            (concept2.domain_id) :: TEXT = (c3.domain_id) :: TEXT
        )
    )
WHERE
    (
        (1 = 1)
        AND rel.invalid_reason IS NULL
        AND concept1.invalid_reason IS NULL
        AND ((concept1.vocabulary_id) :: TEXT = 'OPS' :: TEXT)
        AND (
            (rel.relationship_id) :: TEXT = 'Maps to' :: TEXT
        )
    );