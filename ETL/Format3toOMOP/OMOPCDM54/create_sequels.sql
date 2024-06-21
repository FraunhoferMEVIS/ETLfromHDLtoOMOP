CREATE SEQUENCE {target_schema}.observation_period_id START 3000000 OWNED BY {target_schema}.OBSERVATION_PERIOD.observation_period_id;

CREATE SEQUENCE {target_schema}.condition_occurrence_id START 3000000 OWNED BY {target_schema}.CONDITION_OCCURRENCE.condition_occurrence_id;

CREATE SEQUENCE {target_schema}.procedure_occurrence_id START 3000000 OWNED BY {target_schema}.PROCEDURE_OCCURRENCE.procedure_occurrence_id;

CREATE SEQUENCE {target_schema}.observation_id START 3000000 OWNED BY {target_schema}.OBSERVATION.observation_id;

CREATE SEQUENCE {target_schema}.payer_plan_period_id START 3000000 OWNED BY {target_schema}.PAYER_PLAN_PERIOD.payer_plan_period_id;

CREATE SEQUENCE {target_schema}.cost_id START 3000000 OWNED BY {target_schema}.COST.cost_id;

CREATE SEQUENCE {target_schema}.measurement_id START 3000000 OWNED BY {target_schema}.measurement.measurement_id;

CREATE SEQUENCE {target_schema}.drug_exposure_id START 3000000 OWNED BY {target_schema}.drug_exposure.drug_exposure_id;