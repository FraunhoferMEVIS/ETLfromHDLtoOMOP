/*
 Keep information about prescriping care site
 */
INSERT INTO
   {target_schema}.care_site (
      care_site_id,
      care_site_source_value,
      care_site_name,
      place_of_service_concept_id,
      location_id,
      place_of_service_source_value
   )
SELECT
   DISTINCT ON (rez.bsnrvopseudo) -- [VALUE   COMMENT] pseudonym of care site of prescirping physican  
   rez.bsnrvopseudo AS care_site_id,
   -- [VALUE   COMMENT] pseudonym of care site of prescirping physican  
   rez.bsnrvopseudo AS care_site_source_value,
   NULL AS care_site_name,
   NULL AS place_of_service_concept_id,
   -- [VALUE   COMMENT] Regionalkennzeichen der verordnenden Betriebsstätte "regional indicator of care site" 
   rez.bsnrvoregknz AS location_id,
   NULL AS place_of_service_source_value
FROM
   arzneimittel.rez rez
WHERE
   rez.bsnrvopseudo IS NOT NULL ON CONFLICT (care_site_id) DO NOTHING;