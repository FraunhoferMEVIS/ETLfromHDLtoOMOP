# German Health Data Lab (HDL) Format 1 and 3 to OMOP CDM 

In the scripts, the HDL formats 1 and 3 (input formats) are transformed into the OMOP CDM output format. To do this, information is extracted from the tables of the original data formats (HDL), transformed, and loaded into the new data format (OMOP CDM). It is assumed that the data is stored in a PostgreSQL database and that certain terminology mappings are provided by the user or requested from an external, publicly available service. Links to the external repositories are provided. The ETL script can be started in a Docker container, which is provided as well. 

The software is provided on "AS IS" basis, i.e. it comes without any warranty, express or implied including (without limitations) any warranty of merchantability and warranty of fitness for a particular purpose.

Due to the completion of the project, we are not pursuing extensions or adaptations. **If you are interested in a joint project or collaboration, we look forward to hearing from you.** Please contact melissa.finster@mevis.fraunhofer.de 

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

Please note the [data dictionary](https://github.com/FDZ-Gesundheit/datensatzbeschreibung_fdz_gesundheit) of the German HDL. 

Step 2. Load example data from HDL Format 1 and HDL Format 3, if available, or own data. Note: Example data is not provided by us.

## Add OMOP CDM DDL

Step 3. Download the DDL files (OMOPCDM_postgresql_5.4_constraints.sql, OMOPCDM_postgresql_5.4_ddl.sql, OMOPCDM_postgresql_5.4_indices.sql, OMOPCDM_postgresql_5.4_primary_keys.sql) from the [OHDSI DDL postgreSQL repository](https://github.com/OHDSI/CommonDataModel/tree/main/ddl/5.4/postgresql). Add the scripts to folders ETLfromHDLtoOMOP/ETL/Format1toOMOP/OMOPCDM54/ and ETLfromHDLtoOMOP/ETL/Format3toOMOP/OMOPCDM54/. 

## Add Vocabulary

Step 4. Download Vocabulary for CDM version 5 and ICD10GM from [Athena](https://athena.ohdsi.org/search-terms/start) by clicking the button "Download", keep the preselected vocabulary for CODE (CDM V5) and add ICD10GM and OPS. After downloading copy it into folder \voc and follow the readme of the ATHENA download.

Step 5. Inlcude [EBM mapping](https://github.com/elisahenke/OMOP-CDM-German-vocabularies/tree/main/EBM) of TU Dresden into folder \voc. 

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

## Citation

We are pleased if you use our ETL code. Please make sure you cite the paper (which is currently under revision) that accompanies the code.
"ETL: From the German Health Data Lab Data Formats to the OMOP Common Data Model" (Melissa Finster & Maxim Moinat & Elham Taghizadeh) DOI: 10.1371/journal.pone.0311511
