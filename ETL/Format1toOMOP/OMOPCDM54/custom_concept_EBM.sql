SET
	CLIENT_ENCODING TO 'utf8';

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
		'EBM',
		'German Uniform Assessment',
		' ',
		--will be added when data description is online
		'2000001037',
		0
	);

INSERT INTO
	{target_schema}.CONCEPT_CLASS(
		concept_class_id,
		concept_class_name,
		concept_class_concept_id
	)
VALUES
	(
		'EBM Hierarchy',
		'EBM Hierarchy',
		2000001038
	),
	('EBM code', 'EBM code', 2000001039);