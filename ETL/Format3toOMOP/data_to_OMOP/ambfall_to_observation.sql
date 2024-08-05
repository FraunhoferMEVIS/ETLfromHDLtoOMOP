/*
 Create observation in case it was an accident or registered as Versogungsleiden
 */
INSERT INTO
    {target_schema}.observation (
        observation_id,
        visit_occurrence_id,
        observation_date,
        person_id,
        observation_concept_id,
        value_as_string,
        observation_source_value,
        value_as_concept_id,
        provider_id,
        observation_datetime,
        observation_type_concept_id,
        -- 32810 Claim 
        value_as_number,
        qualifier_concept_id,
        unit_concept_id,
        visit_detail_id,
        observation_source_concept_id,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    nextval('{target_schema}.observation_id'),
    ambfall.fallidamb AS visit_occurrence_id,
    CASE
        WHEN COALESCE(ambfall.beginndatamb, ambfall.endedatamb) is NULL THEN make_date(
            LEFT(ambfall.abrq :: VARCHAR, 4) :: integer,
            (RIGHT(ambfall.abrq :: VARCHAR, 1) :: integer -1) * 3 + 1,
            01
        )
        ELSE TO_DATE(
            COALESCE(ambfall.beginndatamb, ambfall.endedatamb) :: VARCHAR,
            'YYYYMMDD'
        )
    END AS observation_date,
    ambfall.arbnr AS person_id,
    -- 0 = default 2 = Unfall/-folgen 3 = Versorgungsleiden (-> confirmed by an official service, Causes might be disease/diability caused by military service, vaccination, victim  of act of violence, .. ) 
    432532 AS observation_concept_id,
    --ambfall.unfall=2
    NULL AS value_as_string,
    -- 0 = default 2 = Unfall/-folgen 3 = Versorgungsleiden (-> confirmed by an official service, Causes might be disease/diability caused by military service, vaccination, victim  of act of violence, .. ) 
    CONCAT(ambfall.unfall, ': Accident') AS observation_source_value,
    NULL AS value_as_concept_id,
    NULL AS provider_id,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    --Claim
    NULL AS value_as_number,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS visit_detail_id,
    NULL AS observation_source_concept_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    ambulante_faelle.ambfall
WHERE
    ambfall.unfall = 2;

INSERT INTO
    {target_schema}.observation (
        observation_id,
        visit_occurrence_id,
        observation_date,
        -- link to zahnfall for zahnbef 
        person_id,
        -- link  to zahnfall for zahnbef 
        observation_concept_id,
        value_as_string,
        observation_source_value,
        value_as_concept_id,
        provider_id,
        observation_datetime,
        observation_type_concept_id,
        -- 32810 Claim 
        value_as_number,
        qualifier_concept_id,
        unit_concept_id,
        visit_detail_id,
        observation_source_concept_id,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    nextval('{target_schema}.observation_id'),
    ambfall.fallidamb AS visit_occurrence_id,
    TO_DATE(ambfall.entbindungsdat :: VARCHAR, 'YYYYMMDD') AS observation_date,
    ambfall.arbnr AS person_id,
    36308290 AS observation_concept_id,
    --childbirth
    NULL AS value_as_string,
    -- 0 = default 2 = Unfall/-folgen 3 = Versorgungsleiden (-> confirmed by an official service, Causes might be disease/diability caused by military service, vaccination, victim  of act of violence, .. ) 
    'childbirth' AS observation_source_value,
    NULL AS value_as_concept_id,
    NULL AS provider_id,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    --Claim
    NULL AS value_as_number,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS visit_detail_id,
    NULL AS observation_source_concept_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    ambulante_faelle.ambfall
WHERE
    ambfall.entbindungsdat IS NOT NULL;