import logging
import time
import os
import psycopg2
import chardet
from functools import wraps
from psycopg2 import ProgrammingError, IntegrityError, OperationalError, InternalError


def get_environment_values(variable):
    return os.environ[variable] if variable in os.environ else None


def measure_performance(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        execution_time = end_time - start_time
        logger = kwargs.get(
            "logger", logging.getLogger(__name__)
        )  # Change: Default Logger
        if logger:
            logger.info(f"{func.__name__} executed in {execution_time:.4f} seconds")
        else:
            print(f"{func.__name__} executed in {execution_time:.4f} seconds")
        return result

    return wrapper


def read_sql_file(file, folder):
    table_ = os.path.join(folder, file)
    if not os.path.exists(table_):
        logging.error("File: " + table_ + " does not exists! SQL is skipped.")
    else:
        fd = open(table_, "r")
        sqlFile = fd.read()
        fd.close()
        logging.info("Read SQL: " + table_)
        return sqlFile  # as string


def read_ddl_sql_file(file, folder, target_schema, replacement=None):
    table_ = os.path.join(folder, file)
    if not os.path.exists(table_):
        logging.error("File: " + table_ + " does not exist! SQL is skipped.")
    else:
        with open(table_, "r") as fd:
            sqlFile = fd.read()
        sqlFile = sqlFile.replace("@cdmDatabaseSchema", target_schema)
        if replacement is not None:
            for old_value, new_value in replacement.items():
                sqlFile = sqlFile.replace(old_value, new_value)

        logging.info("Read SQL: " + table_)
        return sqlFile


@measure_performance
def execute_query(query, dbname, user, host, port, password, logger):
    if query:
        with psycopg2.connect(
            dbname=dbname, user=user, host=host, port=port, password=password
        ) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(query)
            except IntegrityError as e:
                logger.error(e)
                logger.error("Error executing: " + query)
            except ProgrammingError as e:
                logger.error(
                    e
                )  # in case indices where already set catch DuplicateTable error
                logger.error("Error executing: " + query)
            except OperationalError as e:
                logger.error(e)
                logger.error("Error executing: " + query)
            except InternalError as e:
                logger.error(e)
                logger.error("Error executing: " + query)


def split_query(query):
    splitted = query.split(";")
    queries = []
    for splitted_query in splitted:
        if splitted_query.strip().startswith("--"):
            continue
        if splitted_query.strip():
            queries.append(splitted_query.strip() + ";")
    return queries


def detect_encoding(file_path):
    with open(file_path, "rb") as file:
        result = chardet.detect(file.read())
    return result["encoding"]


@measure_performance
def write_from_csv(
    dbname,
    user,
    host,
    port,
    password,
    file_path,
    target_schema,
    concept,
    logger,
    encoding=None,
):
    if not os.path.exists(file_path):
        logger.error("File: " + file_path + " does not exist! Table is skipped.")
        return

    if encoding is None:
        encoding = detect_encoding(file_path)

    with psycopg2.connect(
        dbname=dbname, user=user, host=host, port=port, password=password
    ) as conn:
        cur = conn.cursor()
        try:
            logger.info(file_path + " read")
            with open(file_path, "r", encoding=encoding) as f:
                copy_sql = f"""
                COPY {target_schema}.{concept} 
                FROM stdin 
                WITH CSV DELIMITER as E'\\t' HEADER QUOTE E'\\b'
                """
                cur.copy_expert(sql=copy_sql, file=f)
                conn.commit()
                logger.info(file_path + " inserted")
        except Exception as e:
            conn.rollback()
            logger.error(f"An error occurred: {e}")
