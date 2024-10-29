/*
 To capture (only!) treating  physican 
 Note: 
 - Since provider might appear in several tables we  apply a full join to report every provider, but none twice
 - select distinct on einweispseudo
 */
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
      care_site_id,
      npi,
      dea,
      specialty_concept_id,
      year_of_birth,
      gender_concept_id,
      provider_source_value,
      specialty_source_value,
      specialty_source_concept_id,
      gender_source_value,
      gender_source_concept_id
   )
SELECT
   DISTINCT ON (khfall.einweispseudo) -- pseudonym of admisison physican  
   khfall.einweispseudo AS provider_id,
   NULL AS provider_name,
   --pseudonym of hospital  
   khfall.khpseudo AS care_site_id,
   NULL AS npi,
   NULL AS dea,
   COALESCE(pg.concept_id_2, 0) AS specialty_concept_id,
   NULL AS year_of_birth,
   NULL AS gender_concept_id,
   khfall.einweispseudo AS provider_source_value,
   khfall.einweisfg AS specialty_source_value,
   COALESCE(pg.concept_id_1, 0) AS specialty_source_concept_id,
   NULL AS gender_source_value,
   NULL AS gender_source_concept_id
FROM
   stationaere_faelle.khfall khfall
   LEFT JOIN pg ON khfall.einweisfg = pg.concept_code
WHERE
   khfall.einweispseudo is not NULL 
   AND khfall.einweispseudo !=''
ON CONFLICT (provider_id) DO NOTHING -- it is an unique identifier by definition, but falsly not unique in example data set 
;