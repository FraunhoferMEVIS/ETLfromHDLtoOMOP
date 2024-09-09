/*
 Keep information of prescriping physican 
 Check if physican entry already exists, ow. create
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
      npi,
      care_site_id,
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
   DISTINCT ON (rez.lenrvopseudo) --   "pesudonym of the prescriping physican" 
   rez.lenrvopseudo AS provider_id,
   NULL AS provider_name,
   NULL AS npi,
   --  pseudonym of care site of prescirping physican  
   rez.bsnrvopseudo AS care_site_id,
   NULL AS dea,
   --   Specality of the prescribing physician ("Fachgruppe des verordnenden Leistungserbringers " )
   COALESCE(pg.concept_id_2, 0) AS specialty_concept_id,
   NULL AS year_of_birth,
   NULL AS gender_concept_id,
   rez.lenrvopseudo AS provider_source_value,
   rez.lenrvofg AS specialty_source_value,
   COALESCE(pg.concept_id_1, 0) AS specialty_source_concept_id,
   NULL AS gender_source_value,
   NULL AS gender_source_concept_id
FROM
   arzneimittel.rez rez
   LEFT JOIN pg ON rez.lenrvofg = pg.concept_code
WHERE
   rez.lenrvopseudo IS NOT NULL ON CONFLICT (provider_id) DO NOTHING;

;