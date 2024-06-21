INSERT INTO
  {target_schema}.procedure_occurrence (
    visit_occurrence_id,
    procedure_date,
    procedure_concept_id,
    -- OPS to standard
    procedure_source_concept_id,
    procedure_source_value,
    procedure_occurrence_id,
    person_id,
    -- link by ambfall.fallidamb
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
  zahnfall.fallidzahn AS visit_occurrence_id,
  CASE
    WHEN COALESCE(zahnfall.beginndatzahn, zahnfall.endedatzahn) is NULL THEN CASE
      WHEN zahnfall.leistq IS NULL THEN make_date(zahnfall.berjahr :: integer, 01, 01)
      ELSE make_date(
        LEFT(zahnfall.leistq :: VARCHAR, 4) :: integer,
        (
          RIGHT(zahnfall.leistq :: VARCHAR, 1) :: integer -1
        ) * 3 + 1,
        01
      )
    END
    ELSE TO_DATE(
      COALESCE(zahnfall.beginndatzahn, zahnfall.endedatzahn) :: VARCHAR,
      'YYYYMMDD'
    )
  END AS observation_date,
  -- KC = Conservative surgical services KB = Services for jaw fracture and temporomandibular joint disorders KF=> 4060198 Orthodontic procedure  PA = Benefits for paradonthosis ZE = Dental prosthesis services  
  CASE
    zahnfall.behandartzahn
    WHEN 'KC' then 4208099
    WHEN 'KB' then 4142524
    WHEN 'KF' then 4323584
    WHEN 'PA' then 4136086
    WHEN 'ZE' then 4265926
    ELSE 0
  END AS procedure_concept_id,
  0 AS procedure_source_concept_id,
  -- Source: No coding system was used in source! 
  CASE
    zahnfall.behandartzahn
    WHEN 'KC' then 'KC: Conservative surgical services'
    WHEN 'KB' then 'KB: Jaw fracture, TMJ disorder'
    WHEN 'KF' then 'KF: Orthodontic services'
    WHEN 'PA' then 'PA: Benefits for paradonthosis'
    WHEN 'ZE' then 'ZE: Dental prosthesis services'
    ELSE zahnfall.behandartzahn
  END AS procedure_source_value,
  nextval('{target_schema}.procedure_occurrence_id'),
  zahnfall.arbnr AS person_id,
  NULL AS procedure_datetime,
  NULL AS procedure_end_date,
  NULL AS procedure_end_datetime,
  32816 AS procedure_type_concept_id,
  --Dental claim
  NULL AS modifier_concept_id,
  NULL AS quantity,
  NULL AS provider_id,
  NULL AS visit_detail_id,
  NULL AS modifier_source_value
FROM
  ambulante_faelle.zahnfall
WHERE
  zahnfall.behandartzahn IS NOT NULL;