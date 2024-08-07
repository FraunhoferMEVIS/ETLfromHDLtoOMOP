/*primary diagnosis*/
with tmp as (
   SELECT
      DISTINCT ON (ambleist.gonr) ambleist.gonr,
      rel.concept_id_2 AS procedure_target_concept_id,
      concept.concept_id AS procedure_source_concept_id
   FROM
      ambulante_faelle.ambleist ambleist --FROM {target_schema}.concept concept
      INNER JOIN {target_schema}.concept concept ON ambleist.gonr = concept.concept_code
      INNER JOIN {target_schema}.concept_relationship rel ON concept.concept_id = rel.concept_id_1
   WHERE
      concept.domain_id = 'Observation'
      AND concept.vocabulary_id = 'EBM'
      AND concept.invalid_reason IS NULL
      AND rel.relationship_id = 'Is a'
      AND rel.invalid_reason IS NULL
)
INSERT INTO
   {target_schema}.procedure_occurrence (
      visit_occurrence_id,
      procedure_date,
      procedure_concept_id,
      procedure_source_concept_id,
      procedure_source_value,
      procedure_occurrence_id,
      person_id,
      procedure_datetime,
      procedure_end_date,
      procedure_end_datetime,
      procedure_type_concept_id,
      -- 32810 Claim
      modifier_concept_id,
      quantity,
      provider_id,
      visit_detail_id,
      modifier_source_value
   )
SELECT
   vo.visit_occurrence_id AS visit_occurrence_id,
   TO_DATE(ambleist.gonrdat :: VARCHAR, 'YYYYMMDD') AS procedure_date,
   -- tarif number (it defines the "service" (like consultation, examination) and  justifies the costs) 
   COALESCE(tmp.procedure_target_concept_id, 0) AS procedure_concept_id,
   COALESCE(tmp.procedure_source_concept_id, 0) AS procedure_source_concept_id,
   -- tarif number (it defines the "service" (like consultation, examination) and  justifies the costs) 
   ambleist.gonr AS procedure_source_value,
   nextval('{target_schema}.procedure_occurrence_id'),
   ambfall.arbnr AS person_id,
   Case
      when ambleist.ambleistzeit != '' then to_timestamp(
         CONCAT(
            ambleist.gonrdat :: VARCHAR,
            ambleist.ambleistzeit :: VARCHAR
         ),
         'YYYYMMDDHH24MI'
      )
   END AS procedure_datetime,
   NULL AS procedure_end_date,
   NULL AS procedure_end_datetime,
   32810 AS procedure_type_concept_id,
   --32810 Claim
   NULL AS modifier_concept_id,
   NULL AS quantity,
   ambleist.lanrpseudo AS provider_id,
   NULL AS visit_detail_id,
   NULL AS modifier_source_value
FROM
   ambulante_faelle.ambleist ambleist
   INNER JOIN ambulante_faelle.ambfall ambfall ON ambfall.fallidamb = ambleist.fallidamb
   LEFT JOIN tmp ON ambleist.gonr = tmp.gonr
   LEFT JOIN {target_schema}.visit_occurrence vo ambfall.fallidamb = vo.fallid_temp -- and ambfall.vsid = vo.vsid_temp
      ;