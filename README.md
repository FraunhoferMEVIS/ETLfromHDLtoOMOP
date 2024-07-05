# FDZ Data format 1 and 3 to OMOP CDM 

## Database set up of FDZ Data formats 

Step 1. Create FDZ Database and Schema. Ensure that structure, table names, and column names are retained as described in the data dictionary of the Germand HDL (https://github.com/FDZ-Gesundheit/datensatzbeschreibung_fdz_gesundheit). 

Step 2. Load example data of FDZ Format 1 and FDZ Format 3.

## Add OMOP CDM DDL

Step 3. Download the DDL files (OMOPCDM_postgresql_5.4_constraints.sql, OMOPCDM_postgresql_5.4_ddl.sql, OMOPCDM_postgresql_5.4_indices.sql, OMOPCDM_postgresql_5.4_primary_keys.sql) from https://github.com/OHDSI/CommonDataModel/tree/main/ddl/5.4/postgresql. Add the scripts to folders ETLfromHDLtoOMOP/ETL/Format1toOMOP/OMOPCDM54/ and ETLfromHDLtoOMOP/ETL/Format3toOMOP/OMOPCDM54/. 

## Add Vocabulary

Step 4. Download Vocabulary for CDM version 5 and ICD10GM from Athena https://athena.ohdsi.org/search-terms/start by clicking the button "Download", keep the preselected vocabulary for CODE (CDM V5) and add 	ICD10GM. After downloading copy it into folder SQL-data\scripts\voc and follow the readme of the ATHENA download.

Step 5. Inlcude EBM mapping of TU Dresden (https://github.com/elisahenke/OMOP-CDM-German-vocabularies/tree/main/EBM)  into folder SQL-data\scripts\voc. 

## Customize Settings

Step 6. Adapt environment variables in postgres_conn.env 

Step 7. If desired, change FDZ Format names in docker-compose.yml

## Run ETL

Step 8. Build Docker 

```bash
docker-compose build
```

Step 9. Run Docker 

```bash
docker-compose up 
```
