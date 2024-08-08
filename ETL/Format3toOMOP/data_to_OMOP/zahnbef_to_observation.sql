INSERT INTO
    {target_schema}.observation (
        visit_occurrence_id,
        observation_source_value,
        person_id,
        observation_concept_id,
        value_as_string,
        value_as_concept_id,
        observation_id,
        observation_date,
        provider_id,
        observation_datetime,
        observation_type_concept_id,
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
    vo.visit_occurrence_id AS visit_occurrence_id,
    zahnbef.befnr AS observation_source_value,
    zahnfall.arbnr AS person_id,
    0 AS observation_concept_id,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    nextval('{target_schema}.observation_id'),
    CASE
        WHEN COALESCE(zahnfall.beginndatzahn, zahnfall.endedatzahn) is NULL THEN CASE
            WHEN zahnfall.leistq IS NULL THEN make_date(zahnfall.berjahr :: integer, 01, 01)
            ELSE make_date(
                LEFT(zahnfall.leistq :: VARCHAR, 4) :: integer,
                (RIGHT(zahnfall.leistq :: VARCHAR, 1) :: integer -1) * 3 + 1,
                01
            )
        END
        ELSE TO_DATE(
            COALESCE(zahnfall.beginndatzahn, zahnfall.endedatzahn) :: VARCHAR,
            'YYYYMMDD'
        )
    END AS observation_date,
    NULL AS provider_id,
    NULL AS observation_datetime,
    32816 AS observation_type_concept_id,
    --Dental claim 
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
    ambulante_faelle.zahnbef zahnbef
    INNER JOIN ambulante_faelle.zahnfall zahnfall ON zahnbef.fallidzahn = zahnfall.fallidzahn
    LEFT JOIN {target_schema}.visit_occurrence vo ON zahnbef.fallidzahn = vo.fallid_temp;