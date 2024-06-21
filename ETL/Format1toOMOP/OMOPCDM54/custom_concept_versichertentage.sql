INSERT INTO
	{target_schema}.CONCEPT (
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
VALUES
	(
		2000000001,
		'reduced-earning-capacity pension',
		'Observation',
		'Insured days',
		'Observable Entity',
		NULL,
		'erwerbsminderungs_vt',
		to_date(20080101 :: text, 'YYYYMMDD'),
		to_date(20991231 :: text, 'YYYYMMDD'),
		NULL
	),
	(
		2000000002,
		'habitual residence abroad',
		'Observation',
		'Insured days',
		'Observable Entity',
		NULL,
		'versichertentageausland',
		to_date(20080101 :: text, 'YYYYMMDD'),
		to_date(20991231 :: text, 'YYYYMMDD'),
		NULL
	),
	(
		2000000003,
		'Paragaph 13 Section 2 Sozialgesetzbuch V  according § 30 section 1 Nr. 9 RSAV',
		'Observation',
		'Insured days',
		'Observable Entity',
		NULL,
		'versichertentage13ii',
		to_date(20080101 :: text, 'YYYYMMDD'),
		to_date(20991231 :: text, 'YYYYMMDD'),
		NULL
	),
	(
		2000000004,
		'Paragaph 53 Section 4 Sozialgesetzbuch V',
		'Observation',
		'Insured days',
		'Observable Entity',
		NULL,
		'versichertentage53iv',
		to_date(20080101 :: text, 'YYYYMMDD'),
		to_date(20991231 :: text, 'YYYYMMDD'),
		NULL
	),
	(
		2000000005,
		'Paragaph 44 and 45 Sozialgesetzbuch V according to Section 1 Number 11 Risikostruktur-Ausgleichsverordnung',
		'Observation',
		'Insured days',
		'Observable Entity',
		NULL,
		'versichertentagekg',
		to_date(20080101 :: text, 'YYYYMMDD'),
		to_date(20991231 :: text, 'YYYYMMDD'),
		NULL
	),
	(
		2000000006,
		'Selective insurance contract',
		'Observation',
		'Insured days',
		'Observable Entity',
		NULL,
		'versichertentage_wahltarif',
		to_date(20080101 :: text, 'YYYYMMDD'),
		to_date(20991231 :: text, 'YYYYMMDD'),
		NULL
	);

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
		'Insured days',
		'Forschungsdatenzentrum (DE) Insured days',
		' ',
		--will be added when data description is online
		'2023-03-21',
		0
	);