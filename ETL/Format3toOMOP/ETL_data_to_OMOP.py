import logging
import os, sys
import time
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
logname = get_environment_values("logname")
table = (get_environment_values("years"))
folder_load = os.path.join(dataOMOP3, "data_to_OMOP")
folder_constraint = os.path.join(dataOMOP3, "OMOPCDM54")

##Initialize logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(logname, 'a'),
              logging.StreamHandler()])
logger = logging.getLogger()

start_script_time = time.time()
#Check if data is already in the database
conn = psycopg2.connect(dbname=dbname,
                        user=user,
                        host=host,
                        port=port,
                        password=password)
cursor = conn.cursor()
cursor.execute(
    """SELECT is_inserted FROM {target_schema}.inserted_tables  WHERE
                tables= '{table}' and target_format='{target_schema}' and orginal_fromat='{source_schema}';
                            """.format(source_schema=source_schema,
                                       target_schema=target_schema,
                                       table=table))
is_inserted = cursor.fetchall()
logger.info('is inserted: ' + str(is_inserted))
conn.close()

# create temporary columns in visit_occurrence such that several joints can be avoided, since we need to create new identfier visit_occurrence_id
execute_query(
    """
ALTER TABLE {target_schema}.visit_occurrence 
ADD COLUMN fallidkh_temp BIGINT,
ADD COLUMN fallidzahn_temp BIGINT,
ADD COLUMN fallidamb_temp BIGINT,
ADD COLUMN vsid_temp BIGINT;""".format(target_schema=target_schema), dbname,
    user, host, port, password, logger)


#run ETL
if not is_inserted:
    logger.info("Tables not inserted. Starting ETL")

    files = [
        'vers_to_location.sql', 'vers_versq_to_person.sql',
        'vers_to_death.sql', 'versq_to_observation_period.sql',
        'khfall_to_visit_occurrence.sql','ambfall_to_visit_occurrence.sql',
        'zahnfall_to_visit_occurrence.sql',
        'ambfall_to_payer_plan_period.sql', 'ambfall_to_care_site.sql',
        'versqdmp_to_procedure_occurrence.sql', 'rez_to_provider.sql',
        'rez_to_drug_exposure.sql', 'rez_to_cost.sql',
        'khfall_to_procedure_occurrence.sql', 'rez_to_care_site.sql',
        'khfall_to_care_site.sql', 'khdia_to_condition_occurrence.sql',
        'khentg_to_cost.sql', 'khfall_to_observation.sql',
        'khfall_to_provider.sql', 'khproz_to_procedure_occurrence.sql',
        'ambdiag_to_condition_occurrence.sql', 'ambdiag_to_observation.sql',
        'ambfall_to_cost.sql', 'ambfall_to_observation.sql',
        'ambfall_to_procedure_occurrence.sql',
        'ambleist_to_cost.sql',
        'ambleist_to_procedure_occurrence.sql', 'ambleist_to_provider.sql',
        'ambops_to_procedure_occurrence.sql', 'zahnbef_to_observation.sql',
        'zahnfall_to_cost.sql', 'zahnfall_to_procedure_occurrence.sql',
        'zahnfall_to_provider.sql',
        'zahnleist_to_procedure_occurrence.sql',
        'rez_to_location.sql','khfall_to_location.sql','ambfall_to_location .sql'
    ]


    for file in files:
        query = read_sql_file(file, folder_load)
        execute_query(query.format(target_schema=target_schema), dbname, user,
                      host, port, password, logger)

    file_versq_to_observation = 'versq_to_observation.sql'
    columns = {
        'verstageausl': 'versichertentageausland',
        'verstagekg': 'versichertentagekg',
        'verstagekosterstwahlt': 'versichertentage_wahltarif'
    }
    for column_name, value in columns.items():
        query = read_sql_file(file_versq_to_observation, folder_load)
        execute_query(
            query.format(target_schema=target_schema,
                         column_name=column_name,
                         value=value), dbname, user, host, port, password,
            logger)

    query = """ INSERT INTO {target_schema}.inserted_tables (tables,target_format,orginal_fromat,is_inserted) 
            VALUES('{table}','{target_schema}','{source_schema}',1);"""
    execute_query(
        query.format(source_schema=source_schema,
                     target_schema=target_schema,
                     table=table), dbname, user, host, port, password, logger)
    logger.info(
        'Meta information inserted into <sourceschema>.inserted_tables')

execute_query(
    """
ALTER TABLE {target_schema}.visit_occurrence 
DROP  COLUMN fallidkh_temp,
DROP  COLUMN fallidzahn_temp,
DROP  COLUMN fallidamb_temp,
DROP  COLUMN vsid_temp;""".format(target_schema=target_schema), dbname, user,
    host, port, password, logger)

end_script_time = time.time()
total_script_time = end_script_time - start_script_time
logger.info(f"Total ETL script execution time: {total_script_time:.4f} seconds")
start_script_time = time.time()

logger.info('Run constraints')
files_constraints = [
    'OMOPCDM_postgresql_5.4_indices.sql',
    'OMOPCDM_postgresql_5.4_constraints.sql'
]
for file in files_constraints:
    queries = read_ddl_sql_file(file, folder_constraint, target_schema)
    for query in split_query(queries):
        execute_query(query.format(target_schema=target_schema), dbname, user,
                      host, port, password, logger)

end_script_time = time.time()
total_script_time = end_script_time - start_script_time
logger.info(f"Total execution time constraints and indices: {total_script_time:.4f} seconds")
