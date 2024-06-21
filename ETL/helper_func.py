import logging
import os
import psycopg2
from psycopg2 import ProgrammingError, IntegrityError, OperationalError


def get_environment_values(variable):
    return os.environ[variable] if variable in os.environ else None


def read_sql_file(file, folder):
    table_ = os.path.join(folder, file)
    if not os.path.exists(table_):
        logging.error('File: ' + table_ + ' does not exists! SQL is skipped.')
    else:
        fd = open(table_, 'r')
        sqlFile = fd.read()
        fd.close()
        logging.info('Read SQL: ' + table_)
        return sqlFile  #as string


def execute_query(query, dbname, user, host, port, password, logger):
    if query:
        with psycopg2.connect(dbname=dbname,
                              user=user,
                              host=host,
                              port=port,
                              password=password) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(query)
            except IntegrityError as e:
                logger.error(e)
                logger.error('Error executing: ' + query)
            except ProgrammingError as e:
                logger.error(
                    e
                )  # in case indices where already set catch DuplicateTable error
                logger.error('Error executing: ' + query)
            except OperationalError as e:
                logger.error(e)


def split_query(query):
    splitted = query.split(';')
    return [s + ';' for s in splitted if s]


def write_from_csv(dbname, user, host, port, password, table, sql, logger):
    if not os.path.exists(table):
        logger.error('File: ' + table + ' does not exists! Table is skipped.')
    else:
        with psycopg2.connect(dbname=dbname,
                              user=user,
                              host=host,
                              port=port,
                              password=password) as conn:
            cur = conn.cursor()
            with open(table, 'r') as f:
                cur.copy_expert(sql=sql, file=f)
                conn.commit()
                logger.info(table + ' inserted')
