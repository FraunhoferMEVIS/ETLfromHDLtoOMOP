import logging
import os, sys
import psycopg2

sys.path.append(os.environ['DATA_FOLDER_ETL'])
from helper_func import *

target_schema = get_environment_values('target_schema')
source_schema = get_environment_values('source_schema')
dataOMOP3 = get_environment_values('DATA_FOLDER_OMOP3')
user = get_environment_values("DB_USER")
password = get_environment_values("DB_PASSWORD")
dbname = get_environment_values("DB_NAME")
port = get_environment_values("DB_PORT")
host = get_environment_values("DB_HOST")
voc_folder = get_environment_values("VOC_FOLDER")
logname = get_environment_values("logname")
folder_ddl = os.path.join(dataOMOP3, "OMOPCDM54")

replacements_format3={
"care_site_id integer"  : "care_site_id bigint",
"condition_occurrence_id integer"  : "condition_occurrence_id bigint" ,
"cost_event_id integer"  : "cost_event_id bigint" ,
"cost_id integer"  : "cost_id bigint" ,
"drug_exposure_id integer"  : "drug_exposure_id bigint" ,
"episode_id integer"  : "episode_id bigint" ,
"episode_parent_id integer"  : "episode_parent_id bigint" ,
"event_id integer" : "event_id bigint" ,
"note_event_id integer"  : "note_event_id bigint" ,
"observation_event_id integer"  : "observation_event_id bigint" ,
"observation_id integer"  : "observation_id bigint" ,
"observation_period_id integer" : "observation_period_id bigint",
"payer_plan_period_id integer"  : "payer_plan_period_id bigint" ,
"person_id integer"  : "person_id bigint" ,
"procedure_occurrence_id integer"  : "procedure_occurrence_id bigint" ,
"provider_id integer"  : "provider_id bigint" ,
"visit_occurrence_id integer"  : "visit_occurrence_id bigint" ,
"concept_name varchar(255)":" concept_name varchar(2000)"
}


##Settings logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(logname, 'w'),
              logging.StreamHandler()])
logger = logging.getLogger()

##Create schema
logger.info('Create Schema ' + target_schema)
create_schema = """DROP SCHEMA IF EXISTS {target_schema} CASCADE;
CREATE SCHEMA {target_schema};
CREATE TABLE {target_schema}.inserted_tables ( tables VARCHAR(150), target_format VARCHAR(150),orginal_fromat VARCHAR(150),is_inserted integer);"""

execute_query(create_schema.format(target_schema=target_schema), dbname, user,
              host, port, password, logger)

##Create tables and set keys
query = read_ddl_sql_file('OMOPCDM_postgresql_5.4_ddl.sql', folder_ddl, target_schema, replacement=replacements_format3)
execute_query(
    query.format(source_schema=source_schema, target_schema=target_schema),
    dbname, user, host, port, password, logger)

create_load_tables = ['create_sequels.sql','OMOPCDM_postgresql_5.4_primary_keys.sql']
for sql in create_load_tables:
    query = read_ddl_sql_file(sql, folder_ddl, target_schema)
    execute_query(
        query.format(source_schema=source_schema, target_schema=target_schema),
        dbname, user, host, port, password, logger)

##Load concepts
logger.info('Load concepts')
concepts = {
    'versichertentage_VOCABULARY': 'VOCABULARY',
    'versichertentage_CONCEPT': 'CONCEPT',
    'EBM_concept_relationship': 'CONCEPT_RELATIONSHIP',
    'EBM_concept': 'CONCEPT',
    'EBM_vocabulary': 'VOCABULARY',
    'EBM_concept_class': 'CONCEPT_CLASS',
    'DRUG_STRENGTH': 'DRUG_STRENGTH',
    'CONCEPT': 'CONCEPT',
    'CONCEPT_RELATIONSHIP': 'CONCEPT_RELATIONSHIP',
    'CONCEPT_ANCESTOR': 'CONCEPT_ANCESTOR',
    'CONCEPT_SYNONYM': 'CONCEPT_SYNONYM',
    'VOCABULARY': 'VOCABULARY',
    'RELATIONSHIP': 'RELATIONSHIP',
    'CONCEPT_CLASS': 'CONCEPT_CLASS',
    'DOMAIN': 'DOMAIN',
    'professionalgroups_CONCEPT': 'CONCEPT',
    'professionalgroups_CONCEPT_RELATIONSHIP': 'CONCEPT_RELATIONSHIP',
    'professionalgroups_VOCABULARY': 'VOCABULARY'
}


for table, concept in concepts.items():
    table_ = os.path.join(voc_folder, table + '.csv')
    write_from_csv(dbname, user, host, port, password, table_, target_schema, concept, logger,)

# Create materialized view
query = read_sql_file('materialized_views.sql', folder_ddl)
if query:
    execute_query(
        query.format(source_schema=source_schema, target_schema=target_schema),
        dbname, user, host, port, password, logger)
