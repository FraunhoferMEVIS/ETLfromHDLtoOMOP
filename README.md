# German Health Data Lab (HDL) Format 1 and 3 to OMOP CDM 

## Database set up HDL Data Format Database

Step 1. Create HDL Database and Schema:
Step 1.1. Go to folder \create_db_HDLformats
Step 1.2. Adapt environment variables in create_db_HDLformats\postgres_conn.env 
Step 1.3. If desired, change HDL schema names in create_db_HDLformats\docker-compose.yml
Step 1.4.  Build Docker 
```bash
docker-compose build
```
Step 1.5.  Run Docker 
```bash
docker-compose up 
```

Note: The data dictionary of the Germand HDL can be found here: https://github.com/FDZ-Gesundheit/datensatzbeschreibung_fdz_gesundheit. 

Step 2. Load example data of HDL Format 1 and HDL Format 3.

## Add OMOP CDM DDL

Step 3. Download the DDL files (OMOPCDM_postgresql_5.4_constraints.sql, OMOPCDM_postgresql_5.4_ddl.sql, OMOPCDM_postgresql_5.4_indices.sql, OMOPCDM_postgresql_5.4_primary_keys.sql) from https://github.com/OHDSI/CommonDataModel/tree/main/ddl/5.4/postgresql. Add the scripts to folders ETLfromHDLtoOMOP/ETL/Format1toOMOP/OMOPCDM54/ and ETLfromHDLtoOMOP/ETL/Format3toOMOP/OMOPCDM54/. 

## Add Vocabulary

Step 4. Download Vocabulary for CDM version 5 and ICD10GM from Athena https://athena.ohdsi.org/search-terms/start by clicking the button "Download", keep the preselected vocabulary for CODE (CDM V5) and add 	ICD10GM. After downloading copy it into folder \voc and follow the readme of the ATHENA download.

Step 5. Inlcude EBM mapping of TU Dresden (https://github.com/elisahenke/OMOP-CDM-German-vocabularies/tree/main/EBM)  into folder \voc. 

## Customize Settings

Step 6. Go back to parent folder.

Step 7. Adapt environment variables in postgres_conn.env 

Step 8. If desired, change HDL Format names in docker-compose.yml

## Run ETL

Step 9. Build Docker 

```bash
docker-compose build
```

Step 10. Run Docker 

```bash
docker-compose up 
```
