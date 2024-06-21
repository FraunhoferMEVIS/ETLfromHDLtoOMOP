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
query = read_sql_file('OMOPCDM_postgresql_54_ddl.sql', folder_ddl)
execute_query(
    query.format(source_schema=source_schema, target_schema=target_schema),
    dbname, user, host, port, password, logger)

create_load_tables = [
    'create_sequels.sql', 'OMOPCDM_postgresql_54_primary_keys.sql',
    'custom_concept_EBM.sql', 'custom_concept_versichertentage.sql',
    'custom_concept_professionalgroups.sql'
]
for sql in create_load_tables:
    query = read_sql_file(sql, folder_ddl)
    if query:
        execute_query(
            query.format(source_schema=source_schema,
                         target_schema=target_schema), dbname, user, host,
            port, password, logger)

##Load concepts
logger.info('Load concepts')
concepts = {
    'DRUG_STRENGTH': 'DRUG_STRENGTH',
    'CONCEPT': 'CONCEPT',
    'CONCEPT_RELATIONSHIP': 'CONCEPT_RELATIONSHIP',
    'CONCEPT_ANCESTOR': 'CONCEPT_ANCESTOR',
    'CONCEPT_SYNONYM': 'CONCEPT_SYNONYM',
    'VOCABULARY': 'VOCABULARY',
    'RELATIONSHIP': 'RELATIONSHIP',
    'CONCEPT_CLASS': 'CONCEPT_CLASS',
    'DOMAIN': 'DOMAIN',
    'professionalgroups_to_concept': 'CONCEPT',
    'professionalgroups_to_relationship_concept': 'CONCEPT_RELATIONSHIP',
    'EBM_concept': 'CONCEPT',
    'EBM_concept_relationship': 'CONCEPT_RELATIONSHIP'
}
copy_sql = """ COPY {target_schema}.{concept} FROM stdin WITH CSV  DELIMITER as E'\t' HEADER QUOTE E'\b' """

for table, concept in concepts.items():
    table_ = os.path.join(voc_folder, table + '.csv')
    write_from_csv(
        dbname, user, host, port, password, table_,
        copy_sql.format(target_schema=target_schema, concept=concept), logger)

#Create materialized view
query = read_sql_file('materialized_views.sql', folder_ddl)
if query:
    execute_query(
        query.format(source_schema=source_schema, target_schema=target_schema),
        dbname, user, host, port, password, logger)
