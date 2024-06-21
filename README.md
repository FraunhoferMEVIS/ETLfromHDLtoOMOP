# FDZ Data format 1 and 3 to OMOP CDM 

## Database set up of FDZ Data formats 

Step 1. Create FDZ Database and Schema. Ensure that structure, table names, and column names are retained as described in the data dictionary of the Germand HDL. 

Step 2. Load example of FDZ format 1 and FDZ format 3,  provided by the FDZ into the database.

## Add Vocabulary

Step 3. Download Vocabulary for CDM version 5 and ICD10GM from Athena https://athena.ohdsi.org/search-terms/start by clicking the button "Download", keep the preselected vocabulary for CODE (CDM V5) and add 	ICD10GM. After downloading copy it into folder SQL-data\scripts\voc and follow the readme of the ATHENA download.

Step 4. If available, inlcude EBM mapping of TU Dresden and copy it into folder SQL-data\scripts\voc 


## Customize Settings

Step 4. Adapt environment variables in postgres_conn.env 

Step 5. If desired, change FDZ Format names in docker-compose.yml

## Run ETL

Step 6. Build Docker 

```bash
docker-compose build
```

Step 7. Run Docker 

```bash
docker-compose up 
```

