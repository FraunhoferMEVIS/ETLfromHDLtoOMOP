INSERT INTO
    {target_schema}.observation (
        observation_type_concept_id,
        -- 32810 Claim 
        observation_id,
        person_id,
        observation_concept_id,
        observation_date,
        observation_datetime,
        value_as_number,
        value_as_string,
        value_as_concept_id,
        qualifier_concept_id,
        unit_concept_id,
        provider_id,
        visit_occurrence_id,
        visit_detail_id,
        observation_source_value,
        observation_source_concept_id,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        observation_event_id,
        obs_event_field_concept_id
    )
SELECT
    32810 AS observation_type_concept_id,
    --Claim
    nextval('{target_schema}.observation_id'),
    khfall.psid AS person_id,
    -- Reason of admission  Digits 1 and 2:  01 Krankenhausbehandlung, vollstationär 02 Krankenhausbehandlung vollstationär mit vorausgegangener vorstationärer Behandlung 03 Krankenhausbehandlung, teilstationär 04 Vorstationäre Behandlung ohne anschließende vollstationäre Behandlung 05 Stationäre Entbindung 06 Geburt 07 Wiederaufnahme wegen Komplikationen (Fallpauschale) nach KFPV 2003 08 Stationäre Aufnahme zur Organentnahme 09 - frei - 10 Stationsäquivalente Behandlung 11 Übergangspflege  Digits 3 and 4  01 Normalfall 02 Arbeitsunfall / Berufskrankheit (§ 11 Abs. 5 SGB V) 03 Verkehrsunfall / Sportunfall / Sonstiger Unfall (z. B. § 116 SGB X) 04 Hinweis auf Einwirkung von äußerer Gewalt 05 - frei - 06 Kriegsbeschädigten-Leiden / BVG-Leiden 07 Notfall 
    -- Only last two digits:  XX01 Normalfall -> 0 XX02 Arbeitsunfall / Berufskrankheit (§ 11 Abs. 5 SGB V) -> 437748 Industrial accident XX03 Verkehrsunfall / Sportunfall / Sonstiger Unfall (z. B. § 116 SGB X) 440279 Accident XX04 Hinweis auf Einwirkung von äußerer Gewalt 35811215 Victim of physically violent crime XX06 Kriegsbeschädigten-Leiden / BVG-Leiden ??? -> 4302228 Operations of war XX07 Notfall -> 4093606 Emergency 
    CASE
        RIGHT(khfall.aufngrund :: VARCHAR, 2)
        WHEN '02' then 42689803 -- Injury whilst engaged in work activity
        WHEN '03' then 432532 --Accident
        WHEN '04' then 35811215 --Victim of physically violent crime
        WHEN '06' then 4170645 -- War injury
        WHEN '07' then 4093606 -- Emergency
    END AS observation_concept_id,
    TO_DATE(khfall.aufndat :: VARCHAR, 'YYYYMMDD') AS observation_date,
    NULL AS observation_datetime,
    --  Reason of admission  Digits 1 and 2:  01 Krankenhausbehandlung, vollstationär 02 Krankenhausbehandlung vollstationär mit vorausgegangener vorstationärer Behandlung 03 Krankenhausbehandlung, teilstationär 04 Vorstationäre Behandlung ohne anschließende vollstationäre Behandlung 05 Stationäre Entbindung 06 Geburt 07 Wiederaufnahme wegen Komplikationen (Fallpauschale) nach KFPV 2003 08 Stationäre Aufnahme zur Organentnahme 09 - frei - 10 Stationsäquivalente Behandlung 11 Übergangspflege  Digits 3 and 4  01 Normalfall 02 Arbeitsunfall / Berufskrankheit (§ 11 Abs. 5 SGB V) 03 Verkehrsunfall / Sportunfall / Sonstiger Unfall (z. B. § 116 SGB X) 04 Hinweis auf Einwirkung von äußerer Gewalt 05 - frei - 06 Kriegsbeschädigten-Leiden / BVG-Leiden 07 Notfall 
    NULL AS value_as_number,
    NULL AS value_as_string,
    NULL AS value_as_concept_id,
    NULL AS qualifier_concept_id,
    NULL AS unit_concept_id,
    khfall.einweispseudo AS provider_id,
    vo.visit_occurrence_id AS visit_occurrence_id,
    NULL AS visit_detail_id,
    khfall.aufngrund AS observation_source_value,
    NULL AS observation_source_concept_id,
    NULL AS unit_source_value,
    NULL AS qualifier_source_value,
    NULL AS value_source_value,
    NULL AS observation_event_id,
    NULL AS obs_event_field_concept_id
FROM
    stationaere_faelle.khfall
    LEFT JOIN (
        SELECT DISTINCT ON (fallidkh_temp, vsid_temp, visit_occurrence_id)
            fallidkh_temp,
            vsid_temp,
            visit_occurrence_id
        FROM {target_schema}.visit_occurrence
    ) vo ON khfall.fallidkh = vo.fallidkh_temp and khfall.vsid = vo.vsid_temp 
WHERE
    RIGHT(khfall.aufngrund :: VARCHAR, 2) IN ('02', '03', '04', '06', '07');