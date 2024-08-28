import logging
import os, sys
import psycopg2
sys.path.append(os.environ['DATA_FOLDER_ETL'])
from helper_func import *




target_schema=get_environment_values('target_schema')
source_schema=get_environment_values('source_schema')
dataOMOP1= get_environment_values('DATA_FOLDER_OMOP1')
user = get_environment_values("DB_USER")
password = get_environment_values("DB_PASSWORD")
dbname = get_environment_values("DB_NAME")
port = get_environment_values("DB_PORT")
host= get_environment_values("DB_HOST")
logname= get_environment_values("logname")
years=(get_environment_values("years"))
tables=list(years.replace(" ", "").split(","))

folder_load=os.path.join(dataOMOP1,"data_to_OMOP")
folder_constraint=os.path.join(dataOMOP1,"OMOPCDM54")

start_script_time = time.time()
##Initialize logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(logname, 'a'),
        logging.StreamHandler()
    ]
    )
logger = logging.getLogger()

for table_ in tables :
    table='V'+str(table_)
    table_occurrence= 'V'+str(int(table_) +1)

    #Check if data is already in the database
    conn= psycopg2.connect(dbname=dbname, user=user, host=host, port=port, password=password)
    cursor = conn.cursor()
    cursor.execute("""SELECT is_inserted FROM {target_schema}.inserted_tables WHERE
                    tables= '{table}' and target_format='{target_schema}' and orginal_fromat='{source_schema}';
                        """.format(source_schema=source_schema,target_schema=target_schema,table=table))
    is_inserted = cursor.fetchall()
    logger.info('is inserted: '+ str(is_inserted)+ ' table: '+  str(table))
    conn.close()

    ## run ETL
    if not is_inserted:
        logger.info("Tables not inserted. Starting ETL")

        files=['sa999_to_location.sql','sa151sa999_to_person.sql']
        for file in files:
            query=read_sql_file(file,folder_load)
            execute_query(query.format(source_schema=source_schema, target_schema=target_schema, table=table),dbname, user, host, port, password, logger)

        ## table observation
        observation_sa151_sa152=read_sql_file('sa151sa152_to_observation.sql',folder_load)
        columns=[('SA151','versichertentagekg'),('sa152','erwerbsminderungs_vt'),('sa152','versichertentageausland'),('sa152','versichertentage13ii'),('sa152','versichertentage53iv')]
        for prefix_, column_ in columns:
            execute_query(observation_sa151_sa152.format(source_schema=source_schema,target_schema=target_schema,table=table, prefix=prefix_, column=column_),dbname, user, host, port, password, logger)


        ## table cost
        sa751_cost=read_sql_file('sa751_to_cost.sql',folder_load)
        columns=['sa751_aerzte','sa751_zahnaerzte','sa751_krankenhaeuser','sa751_apotheken','sa751_sonstigela','sa751_sachkostendialyse','sa751_krankengeld']
        for column_ in columns:
            execute_query(sa751_cost.format(source_schema=source_schema, target_schema=target_schema,table=table,column=column_),dbname, user, host, port, password, logger)


        query_add_source_idx="""ALTER TABLE {target_schema}.visit_occurrence DROP COLUMN IF EXISTS source_idx_inpatient, DROP COLUMN IF EXISTS source_idx_outpatient;
        ALTER TABLE {target_schema}.visit_occurrence ADD source_idx_inpatient varchar, ADD source_idx_outpatient varchar ;"""
        execute_query(query_add_source_idx.format( target_schema=target_schema),dbname, user, host, port, password, logger)

        ## all other tables
        files=['sa551_to_visit_occurrence.sql','sa651_to_visit_occurrence.sql','sa551_to_condition_occurrence.sql','sa651_to_condition_occurrence.sql', 'sa153_to_procedure_occurrence.sql']
        for file in files:
            query=read_sql_file(file,folder_load)
            execute_query(query.format(source_schema=source_schema, target_schema=target_schema,table=table_occurrence),dbname, user, host, port, password, logger)

        files=['sa651_to_observation.sql','sa151_to_observation_period.sql','sa151_to_death.sql','sa451_to_drug_exposure.sql','sa151_sa951_to_payer_plan_period.sql']
        for file in files:
            query=read_sql_file(file,folder_load)
            execute_query(query.format(source_schema=source_schema, target_schema=target_schema,table=table),dbname, user, host, port, password, logger)


        query_drop_source_idx="""ALTER TABLE {target_schema}.visit_occurrence DROP COLUMN source_idx_inpatient, DROP COLUMN source_idx_outpatient;"""
        execute_query(query_drop_source_idx.format( target_schema=target_schema),dbname, user, host, port, password, logger)

        query=""" INSERT INTO {target_schema}.inserted_tables (tables,target_format,orginal_fromat,is_inserted) 
                VALUES('{table}','{target_schema}','{source_schema}',1);"""
        execute_query(query.format(source_schema=source_schema, target_schema=target_schema,table=table),dbname, user, host, port, password, logger)



end_script_time = time.time()
total_script_time = end_script_time - start_script_time
logger.info(f"Total ETL script execution time: {total_script_time:.4f} seconds")
start_script_time = time.time()


logger.info('Run constraints')
files_constraints=['OMOPCDM_postgresql_5.4_indices.sql','OMOPCDM_postgresql_5.4_constraints.sql']
for file in files_constraints:
    queries = read_ddl_sql_file(file, folder_constraint, target_schema)
    for query in split_query(queries):
        execute_query(query.format(target_schema=target_schema), dbname, user,
                      host, port, password, logger)

end_script_time = time.time()
total_script_time = end_script_time - start_script_time
logger.info(f"Total execution time constraints and indices: {total_script_time:.4f} seconds")
