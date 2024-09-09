import logging
import os
import psycopg2
from psycopg2 import ProgrammingError, IntegrityError, OperationalError,InternalError

def get_environment_values(variable):
    return os.environ[variable] if variable in os.environ else None

sqlFile=None

user = get_environment_values("DB_USER")
password = get_environment_values("DB_PASSWORD")
dbname = get_environment_values("DB_NAME")
port = get_environment_values("DB_PORT")
host = get_environment_values("DB_HOST")
logname = get_environment_values("logname")
folder=get_environment_values("FOLDER")
file=get_environment_values("file")
#Format1 specific
year=get_environment_values("year") or None
source_schema = get_environment_values('schema') or None
#Format 3 specific
schema_versicherte=get_environment_values("schema_versicherte") or None
schema_statonaer=get_environment_values("schema_statonaer") or None
schema_ambulant=get_environment_values("schema_ambulant") or None
schema_arzneimittel=get_environment_values("schema_arzneimittel") or None

_file = os.path.join(folder, file)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(logname, 'w'),
              logging.StreamHandler()])
logger = logging.getLogger()

try:
    with open(_file, 'r') as fd:
        sqlFile = fd.read()
except FileNotFoundError as e:
    logger.error('File: %s does not exist! SQL is skipped.', _file)
except Exception as e:
    logger.error('An error occurred: %s', e)

if sqlFile:
    try:
        with psycopg2.connect(dbname=dbname, user=user, host=host, port=port, password=password) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(sqlFile.format(source_schema=source_schema,year=year,versicherte=schema_versicherte,
                                              stationaere_faelle=schema_statonaer,ambulante_faelle=schema_ambulant,arzneimittel=schema_arzneimittel))
            except (IntegrityError, ProgrammingError, OperationalError, InternalError) as e:
                logger.error('%s', e)
                logger.error('Error executing: %s', sqlFile)
    except Exception as e:
        logger.error('An error occurred while connecting to the database: %s', e)
else:
    logger.warning('No SQL file content to execute.')

