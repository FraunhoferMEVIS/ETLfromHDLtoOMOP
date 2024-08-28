import logging
import os, sys
import time

sys.path.append(os.environ['DATA_FOLDER_ETL'])
from helper_func import *

target_schema = get_environment_values('target_schema')
source_schema = get_environment_values('source_schema')
dataOMOP1 = get_environment_values('DATA_FOLDER_OMOP1')
user = get_environment_values("DB_USER")
password = get_environment_values("DB_PASSWORD")
dbname = get_environment_values("DB_NAME")
port = get_environment_values("DB_PORT")
host = get_environment_values("DB_HOST")
voc_folder = get_environment_values("VOC_FOLDER")
logname = get_environment_values("logname")
folder_ddl = os.path.join(dataOMOP1, "OMOPCDM54")


replacements_format1 = {
        "person_id integer NOT NULL": "person_id serial",
        "observation_period_id integer NOT NULL": "observation_period_id serial",
        "visit_occurrence_id integer NOT NULL": "visit_occurrence_id serial",
        "condition_occurrence_id integer NOT NULL": "condition_occurrence_id serial",
        "drug_exposure_id integer NOT NULL": "drug_exposure_id serial",
        "procedure_occurrence_id integer NOT NULL": "procedure_occurrence_id serial",
        "measurement_id integer NOT NULL": "measurement_id serial",
        "observation_id integer NOT NULL": "observation_id serial",
        "cost_id integer NOT NULL": "cost_id serial",
        "cost_event_id integer NOT NULL": "cost_event_id serial",
        "drug_era_id integer NOT NULL": "drug_era_id serial",
        "concept_name varchar(255)":" concept_name varchar(2000)"
    }

##Settings logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(logname, 'w'),
              logging.StreamHandler()])
logger = logging.getLogger()

start_script_time = time.time()
##Create schema
logger.info('Create Schema ' + target_schema)
create_schema = """DROP SCHEMA IF EXISTS {target_schema} CASCADE;
CREATE SCHEMA {target_schema};
CREATE TABLE {target_schema}.inserted_tables
 ( tables VARCHAR(150), target_format VARCHAR(150),orginal_fromat VARCHAR(150),is_inserted integer);"""

execute_query(create_schema.format(target_schema=target_schema), dbname, user,
              host, port, password, logger)

##Create tables and set keys
query = read_ddl_sql_file('OMOPCDM_postgresql_5.4_ddl.sql', folder_ddl,target_schema, replacement=replacements_format1 )
execute_query(
    query.format(source_schema=source_schema, target_schema=target_schema),
    dbname, user, host, port, password, logger)

query = read_ddl_sql_file('OMOPCDM_postgresql_5.4_primary_keys.sql', folder_ddl, target_schema)
execute_query(query.format(source_schema=source_schema, target_schema=target_schema),
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

#Create materialized view
query = read_sql_file('materialized_views.sql', folder_ddl)
if query:
    execute_query(
        query.format(source_schema=source_schema, target_schema=target_schema),
        dbname, user, host, port, password, logger)

end_script_time = time.time()
total_script_time = end_script_time - start_script_time
logger.info(f"Total script execution time create OMOP and load vocabulary: {total_script_time:.4f} seconds")