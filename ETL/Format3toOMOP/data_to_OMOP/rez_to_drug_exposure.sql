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
   DISTINCT ON (rez.reznr) rez.reznr AS drug_exposure_id,
   rez.lenrvopseudo AS provider_id,
   rez.arbnr AS person_id,
   case
      RIGHT(rez.abgabedat :: VARCHAR, 2)
      when '00' then TO_DATE((rez.abgabedat + 1) :: VARCHAR, 'YYYYMMDD')
      else TO_DATE(rez.abgabedat :: VARCHAR, 'YYYYMMDD')
   END AS drug_exposure_start_date,
   --Map from PZN to RxNorm (no mapping available yet)
   0 as drug_concept_id,
   COALESCE(ezd.pznezd, rez.pznrez) AS drug_source_value,
   rez.menge AS quantity,
   NULL AS drug_exposure_start_datetime,
   case
      RIGHT(rez.abgabedat :: VARCHAR, 2)
      when '00' then TO_DATE((rez.abgabedat + 1) :: VARCHAR, 'YYYYMMDD')
      else TO_DATE(rez.abgabedat :: VARCHAR, 'YYYYMMDD')
   END AS drug_exposure_end_date,
   NULL AS drug_exposure_end_datetime,
   NULL AS verbatim_end_date,
   -- If 1=> dental claim o.w. claim  
   case
      rez.begruendung
      when 1 then 32816 --dental claim 
      else 32810 --claim 
   END AS drug_type_concept_id,
   NULL AS stop_reason,
   NULL AS refills,
   NULL AS days_supply,
   NULL AS sig,
   NULL AS route_concept_id,
   NULL AS lot_number,
   NULL AS visit_occurrence_id,
   NULL AS visit_detail_id,
   0 AS drug_source_concept_id,
   NULL AS route_source_value,
   NULL AS dose_unit_source_value
FROM
   arzneimittel.rez 
   LEFT JOIN arzneimittel.ezd ezd ON rez.reznr=ezd.reznr ;