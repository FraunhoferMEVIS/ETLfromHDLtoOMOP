with tmp as (
   SELECT
      DISTINCT ON (zahnleist.gebnr) zahnleist.gebnr,
      rel.concept_id_2 AS procedure_target_concept_id,
      concept.concept_id AS procedure_source_concept_id
   FROM
      ambulante_faelle.zahnleist zahnleist
      INNER JOIN {target_schema}.concept concept ON zahnleist.gebnr = concept.concept_code
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
      modifier_concept_id,
      quantity,
      provider_id,
      visit_detail_id,
      modifier_source_value
   )
SELECT
   zahnleist.fallidzahn AS visit_occurrence_id,
   CASE
      WHEN zahnleist.leistdat is NULL THEN CASE
         WHEN zahnfall.leistq IS NULL THEN make_date(zahnfall.berjahr :: integer, 01, 01)
         ELSE make_date(
            LEFT(zahnfall.leistq :: VARCHAR, 4) :: integer,
            (RIGHT(zahnfall.leistq :: VARCHAR, 1) :: integer -1) * 3 + 1,
            01
         )
      END
      ELSE TO_DATE(COALESCE(zahnleist.leistdat) :: VARCHAR, 'YYYYMMDD')
   END as procedure_date,
   COALESCE(tmp.procedure_target_concept_id, 0) AS procedure_concept_id,
   COALESCE(tmp.procedure_source_concept_id, 0) AS procedure_source_concept_id,
   zahnleist.gebnr AS procedure_source_value,
   nextval('{target_schema}.procedure_occurrence_id'),
   zahnfall.arbnr AS person_id,
   NULL AS procedure_datetime,
   NULL AS procedure_end_date,
   NULL AS procedure_end_datetime,
   32816 AS procedure_type_concept_id,
   --Dental Claim 
   NULL AS modifier_concept_id,
   zahnleist.gebnrzahl AS quantity,
   NULL AS provider_id,
   NULL AS visit_detail_id,
   zahnleist.gebpos AS modifier_source_value
FROM
   ambulante_faelle.zahnleist zahnleist
   LEFT JOIN ambulante_faelle.zahnfall zahnfall ON zahnfall.fallidzahn = zahnleist.fallidzahn
   LEFT JOIN tmp ON zahnleist.gebnr = tmp.gebnr;