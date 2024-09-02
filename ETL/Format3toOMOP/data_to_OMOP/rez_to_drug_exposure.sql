SET
   CLIENT_ENCODING TO 'utf8';

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
      -- 32810 Claim
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
   rez.lenrvopseudo AS provider_id,
   rez.psid AS person_id,
   case
      RIGHT(rez.abgabedat :: VARCHAR, 2)
      when '00' then TO_DATE((rez.abgabedat + 1) :: VARCHAR, 'YYYYMMDD')
      else TO_DATE(rez.abgabedat :: VARCHAR, 'YYYYMMDD')
   END AS drug_exposure_start_date,
   --Map from PZN to RxNorm (no mapping available yet)
   0 as drug_concept_id,
   --COALESCE(ezd.pznezd, rez.pznrez) AS drug_source_value, --pznezd: actual drug, pznrez: described drug --currently we cannot use pznezd since reznr is not unique and without a PZN mapping we cannot know which picked up drug substitutes which prescribed drug 
   rez.pznrez AS drug_source_value,
   rez.menge AS quantity,
   NULL AS drug_exposure_start_datetime,
   case
      RIGHT(rez.abgabedat :: VARCHAR, 2)
      when '00' then TO_DATE((rez.abgabedat + 1) :: VARCHAR, 'YYYYMMDD') +  INTERVAL '29' day 
      else TO_DATE(rez.abgabedat :: VARCHAR, 'YYYYMMDD') +  INTERVAL '29' day 
   END AS drug_exposure_end_date,
   -- Assumption: drug_exposure_end_date + 29 days (OMOP recommendation)
   NULL AS drug_exposure_end_datetime,
   NULL AS verbatim_end_date,
   -- If 1=> dental claim o.w. claim  
   32810 AS drug_type_concept_id,
   NULL AS stop_reason,
   NULL AS refills,
   NULL AS days_supply,
   rez.reznr AS sig, -- to not lose the source identifiert. However reznr is not unique, and therefore can not be used as drug_exposure_id
   NULL AS route_concept_id,
   NULL AS lot_number,
   NULL AS visit_occurrence_id,
   NULL AS visit_detail_id,
   0 AS drug_source_concept_id,
   NULL AS route_source_value,
   NULL AS dose_unit_source_value
FROM
   arzneimittel.rez ;
   --LEFT JOIN arzneimittel.ezd ezd ON rez.reznr=ezd.reznr ;