INSERT INTO
	{target_schema}.VOCABULARY (
		vocabulary_id,
		vocabulary_name,
		vocabulary_reference,
		vocabulary_version,
		vocabulary_concept_id
	)
VALUES
	(
		'Professional groups',
		'Forschungsdatenzentrum (DE) Format1 Insured days',
		' ',
		--will be added when data description is online
		'2023-05-03',
		0
	);

COPY {target_schema}.CONCEPT(
	concept_id,
	concept_name,
	domain_id,
	vocabulary_id,
	concept_class_id,
	standard_concept,
	concept_code,
	valid_start_date,
	valid_end_date,
	invalid_reason
)
FROM
	'professionalgroups_to_concept.csv' DELIMITER ';' CSV HEADER;

COPY {target_schema}.CONCEPT_RELATIONSHIP(
	concept_id_1,
	concept_id_2,
	relationship_id,
	valid_start_date,
	valid_end_date,
	invalid_reason
)
FROM
	'professionalgroups_to_relationship_concept.csv' DELIMITER ';' CSV HEADER;