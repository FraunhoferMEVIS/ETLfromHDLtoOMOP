DROP TABLE IF EXISTS tmp_khproz CASCADE;

CREATE TEMP TABLE tmp_khproz AS
SELECT
    khproz.fallidkh,
    khproz.vsid,
    khproz.psid,
    khproz.proz,
    khproz.prozdat,
    khproz.prozlokal,
    mv_ops.procedure_source_concept_id,
    mv_ops.procedure_target_concept_id,
    mv_ops.domain_id
FROM
    stationaere_faelle.khproz khproz
    LEFT JOIN {target_schema}.ops_standard_domain_lookup mv_ops ON khproz.proz = mv_ops.source_code;

INSERT INTO
    {target_schema}.procedure_occurrence (
        procedure_occurrence_id,
        visit_occurrence_id,
        person_id,
        procedure_concept_id,
        procedure_source_concept_id,
        procedure_source_value,
        procedure_date,
        provider_id,
        procedure_type_concept_id,
        procedure_datetime,
        procedure_end_date,
        procedure_end_datetime,
        modifier_concept_id,
        quantity,
        visit_detail_id,
        modifier_source_value
    )
SELECT
    nextval('{target_schema}.procedure_occurrence_id'),
    vo.visit_occurrence_id AS visit_occurrence_id,
    tmp_khproz.psid AS person_id,
    COALESCE(tmp_khproz.procedure_target_concept_id, 0) AS procedure_concept_id,
    COALESCE(tmp_khproz.procedure_source_concept_id, 0) AS procedure_source_concept_id,
    CONCAT(tmp_khproz.proz, ',', tmp_khproz.prozlokal) AS procedure_source_value,
    TO_DATE(tmp_khproz.prozdat :: VARCHAR, 'YYYYMMDD') AS procedure_date,
    khfall.einweispseudo AS provider_id,
    32810 AS procedure_type_concept_id,
    NULL AS procedure_datetime,
    NULL AS procedure_end_date,
    NULL AS procedure_end_datetime,
    NULL AS modifier_concept_id,
    NULL AS quantity,
    NULL AS visit_detail_id,
    NULL AS modifier_source_value
FROM
    tmp_khproz
    LEFT JOIN (
        SELECT DISTINCT ON (khfall.fallidkh, khfall.vsid)
            khfall.fallidkh,
            khfall.vsid,
            khfall.einweispseudo
        FROM stationaere_faelle.khfall
        WHERE khfall.einweispseudo IS NOT NULL
    ) khfall ON tmp_khproz.fallidkh = khfall.fallidkh AND tmp_khproz.vsid = khfall.vsid
    LEFT JOIN (
        SELECT DISTINCT ON (fallidkh_temp, vsid_temp, visit_occurrence_id)
            fallidkh_temp,
            vsid_temp,
            visit_occurrence_id
        FROM {target_schema}.visit_occurrence
    ) vo ON tmp_khproz.fallidkh = vo.fallidkh_temp AND tmp_khproz.vsid = vo.vsid_temp
WHERE
    tmp_khproz.domain_id = 'Procedure'
    OR tmp_khproz.domain_id IS NULL;

INSERT INTO
    {target_schema}.observation (
        visit_occurrence_id,
        observation_date,
        observation_source_value,
        person_id,
        observation_concept_id,
        value_as_string,
        value_as_concept_id,
        observation_id,
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
    TO_DATE(tmp_khproz.prozdat :: VARCHAR, 'YYYYMMDD') AS observation_date,
    CONCAT(tmp_khproz.proz, ',', tmp_khproz.prozlokal) AS observation_source_value,
    tmp_khproz.psid AS person_id,
    COALESCE(tmp_khproz.procedure_target_concept_id, 0) AS observation_concept_id,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    nextval('{target_schema}.observation_id'),
    khfall.einweispseudo AS provider_id,
    NULL AS observation_datetime,
    32810 AS observation_type_concept_id,
    NULL AS value_as_number,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    NULL AS visit_detail_id,
    COALESCE(tmp_khproz.procedure_source_concept_id, 0) AS observation_source_concept_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    tmp_khproz
    LEFT JOIN (
        SELECT DISTINCT ON (khfall.fallidkh, khfall.vsid)
            khfall.fallidkh,
            khfall.vsid,
            khfall.einweispseudo
        FROM stationaere_faelle.khfall
        WHERE khfall.einweispseudo IS NOT NULL
    ) khfall ON tmp_khproz.fallidkh = khfall.fallidkh AND tmp_khproz.vsid = khfall.vsid
    LEFT JOIN (
        SELECT DISTINCT ON (fallidkh_temp, vsid_temp, visit_occurrence_id)
            fallidkh_temp,
            vsid_temp,
            visit_occurrence_id
        FROM {target_schema}.visit_occurrence
    ) vo ON tmp_khproz.fallidkh = vo.fallidkh_temp AND tmp_khproz.vsid = vo.vsid_temp
WHERE
    tmp_khproz.domain_id = 'Observation';

INSERT INTO
    {target_schema}.measurement (
        measurement_id,
        person_id,
        measurement_concept_id,
        measurement_date,
        measurement_datetime,
        measurement_time,
        measurement_type_concept_id,
        operator_concept_id,
        value_as_number,
        value_as_concept_id,
        unit_concept_id,
        range_low,
        range_high,
        provider_id,
        visit_occurrence_id,
        visit_detail_id,
        measurement_source_value,
        measurement_source_concept_id,
        unit_source_value,
        unit_source_concept_id,
        value_source_value,
        measurement_event_id,
        meas_event_field_concept_id
    )
SELECT
    nextval('{target_schema}.measurement_id'),
    tmp_khproz.psid AS person_id,
    COALESCE(tmp_khproz.procedure_target_concept_id, 0) AS measurement_concept_id,
    TO_DATE(tmp_khproz.prozdat :: VARCHAR, 'YYYYMMDD') AS measurement_date,
    NULL AS measurement_datetime,
    NULL AS measurement_time,
    32810 AS measurement_type_concept_id,
    NULL AS operator_concept_id,
    NULL AS value_as_number,
    NULL AS value_as_concept_id,
    NULL AS unit_concept_id,
    NULL AS range_low,
    NULL AS range_high,
    khfall.einweispseudo AS provider_id,
    vo.visit_occurrence_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    CONCAT(tmp_khproz.proz, ',', tmp_khproz.prozlokal) AS measurement_source_value,
    COALESCE(tmp_khproz.procedure_source_concept_id, 0) AS measurement_source_concept_id,
    NULL AS unit_source_value,
    NULL AS unit_source_concept_id,
    NULL AS value_source_value,
    NULL AS measurement_event_id,
    NULL AS meas_event_field_concept_id
FROM
    tmp_khproz
    LEFT JOIN (
        SELECT DISTINCT ON (khfall.fallidkh, khfall.vsid)
            khfall.fallidkh,
            khfall.vsid,
            khfall.einweispseudo
        FROM stationaere_faelle.khfall
        WHERE khfall.einweispseudo IS NOT NULL
    ) khfall ON tmp_khproz.fallidkh = khfall.fallidkh AND tmp_khproz.vsid = khfall.vsid
    LEFT JOIN (
        SELECT DISTINCT ON (fallidkh_temp, vsid_temp, visit_occurrence_id)
            fallidkh_temp,
            vsid_temp,
            visit_occurrence_id
        FROM {target_schema}.visit_occurrence
    ) vo ON tmp_khproz.fallidkh = vo.fallidkh_temp AND tmp_khproz.vsid = vo.vsid_temp
WHERE
    tmp_khproz.domain_id = 'Measurement';

INSERT INTO
    {target_schema}.drug_exposure (
        drug_exposure_id,
        provider_id,
        person_id,
        drug_exposure_start_date,
        drug_concept_id,
        drug_source_value,
        quantity,
        drug_exposure_start_datetime,
        drug_exposure_end_date,
        drug_exposure_end_datetime,
        verbatim_end_date,
        drug_type_concept_id,
        stop_reason,
        refills,
        days_supply,
        sig,
        route_concept_id,
        lot_number,
        visit_occurrence_id,
        visit_detail_id,
        drug_source_concept_id,
        route_source_value,
        dose_unit_source_value
    )
SELECT
    nextval('{target_schema}.drug_exposure_id'),
    khfall.einweispseudo AS provider_id,
    tmp_khproz.psid AS person_id,
    TO_DATE(tmp_khproz.prozdat :: VARCHAR, 'YYYYMMDD') AS drug_exposure_start_date,
    COALESCE(tmp_khproz.procedure_target_concept_id, 0) as drug_concept_id,
    CONCAT(tmp_khproz.proz, ',', tmp_khproz.prozlokal) AS drug_source_value,
    NULL AS quantity,
    NULL AS drug_exposure_start_datetime,
    TO_DATE(tmp_khproz.prozdat :: VARCHAR, 'YYYYMMDD') AS drug_exposure_end_date,
    NULL AS drug_exposure_end_datetime,
    NULL AS verbatim_end_date,
    32810 AS drug_type_concept_id,
    NULL AS stop_reason,
    NULL AS refills,
    NULL AS days_supply,
    NULL AS sig,
    NULL AS route_concept_id,
    NULL AS lot_number,
    vo.visit_occurrence_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    COALESCE(tmp_khproz.procedure_source_concept_id, 0) AS drug_source_concept_id,
    NULL AS route_source_value,
    NULL AS dose_unit_source_value
FROM
    tmp_khproz
    LEFT JOIN (
        SELECT DISTINCT ON (khfall.fallidkh, khfall.vsid)
            khfall.fallidkh,
            khfall.vsid,
            khfall.einweispseudo
        FROM stationaere_faelle.khfall
        WHERE khfall.einweispseudo IS NOT NULL
    ) khfall ON tmp_khproz.fallidkh = khfall.fallidkh AND tmp_khproz.vsid = khfall.vsid
    LEFT JOIN (
        SELECT DISTINCT ON (fallidkh_temp, vsid_temp, visit_occurrence_id)
            fallidkh_temp,
            vsid_temp,
            visit_occurrence_id
        FROM {target_schema}.visit_occurrence
    ) vo ON tmp_khproz.fallidkh = vo.fallidkh_temp AND tmp_khproz.vsid = vo.vsid_temp
WHERE
    tmp_khproz.domain_id = 'Drug';

DROP TABLE IF EXISTS tmp_khproz CASCADE;