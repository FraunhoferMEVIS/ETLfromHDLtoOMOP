/*
 Versichertenstammdaten 151 (Masta data) to death:
 - if dead, year of death
 */
INSERT INTO
    {target_schema}.death (
        person_id,
        death_date,
        death_datetime,
        death_type_concept_id,
        cause_concept_id,
        cause_source_value,
        cause_source_concept_id
    )
SELECT
    per.person_id AS person_id,
    make_date(sa151.sa151_berichtsjahr :: int, 12, 31) AS death_date,
    NULL AS death_datetime,
    32810 AS death_type_concept_id,
    --Claim
    NULL AS cause_concept_id,
    NULL AS cause_source_value,
    NULL AS cause_source_concept_id
FROM
    {source_schema}.{table}sa151 sa151
    INNER JOIN {target_schema}.person per ON sa151.sa151_psid = per.person_source_value
WHERE
    sa151.sa151_verstorben = 1 
    AND NOT EXISTS (
        SELECT 1 FROM {target_schema}.death d WHERE d.person_id = per.person_id
    );
