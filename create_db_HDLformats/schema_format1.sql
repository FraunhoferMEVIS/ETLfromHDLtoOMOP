/* Copyright (c) Fraunhofer MEVIS, Germany. All rights reserved.
**InsertLicense** code
-----------------------------------------------------------------------------
file: schema_format1.py
author: Melissa Finster
date: 05/2023
description: Creating the postgres schema for HDL Format 1 
-----------------------------------------------------------------------------
*/

/*
German Health Data Lab Format 1 
Create schema {source_schema} with year{year}*/

-- Satzart SA151: Versichertenstammdaten des Ausgleichsjahrs 
-- (Insured Master Data of the Compensation Year)

--Create schema

DROP SCHEMA IF EXISTS {source_schema} CASCADE;
CREATE SCHEMA {source_schema};

-- Create Tables 
CREATE TABLE {source_schema}.v{year}sa151 (
        "sa151_satzart"             NUMERIC(3,0) NOT NULL, 
        "sa151_ausgleichsjahr"      NUMERIC(4,0) NOT NULL, 
        "sa151_berichtsjahr"        NUMERIC(4,0) NOT NULL, 
        "sa151_vsid"               NUMERIC(9,0) NOT NULL, 
        "sa151_psid"                CHAR(19),
        "sa151_kv_nr_kennzeichen"   NUMERIC(1,0) NOT NULL, 
        "sa151_geburtsjahr"         NUMERIC(4,0) NOT NULL, 
        "sa151_geschlecht"          NUMERIC(1,0) NOT NULL, 
        "sa151_versichertentage"    NUMERIC(3,0) NOT NULL, 
        "sa151_verstorben"          NUMERIC(1,0) NOT NULL, 
        "sa151_versichertentagekg"  NUMERIC(3,0) NOT NULL
  );

-- Satzart SA152: Versichertenstammdaten des Vorjahres des Ausgleichjahres 
-- (Insured Master Data of the Previous Year of the Compensation Year)
CREATE TABLE {source_schema}.v{year}sa152 (
        "sa152_satzart"                 NUMERIC(3,0) NOT NULL,
        "sa152_ausgleichsjahr"          NUMERIC(4,0) NOT NULL,
        "sa152_berichtsjahr"            NUMERIC(4,0) NOT NULL,
        "sa152_vsid"                   NUMERIC(9,0) NOT NULL,
        "sa152_psid"                    CHAR(19),
        "sa152_kv_nr_kennzeichen"       NUMERIC(1,0) NOT NULL,
        "sa152_erwerbsminderungs_vt"    NUMERIC(3,0) NOT NULL,
        "sa152_versichertentageausland" NUMERIC(3,0) NOT NULL,
        "sa152_versichertentage13ii"    NUMERIC(3,0) NOT NULL,
        "sa152_versichertentage53iv"    NUMERIC(3,0) NOT NULL
  );

-- Satzart SA153: Extrakorporale Blutreinigung 
-- (Extracorporeal Blood Purification)
CREATE TABLE {source_schema}.v{year}sa153 (
        "sa153_satzart"             NUMERIC(3,0) NOT NULL,
        "sa153_ausgleichsjahr"      NUMERIC(4,0) NOT NULL,
        "sa153_berichtsjahr"        NUMERIC(4,0) NOT NULL,
        "sa153_vsid"               NUMERIC(9,0) NOT NULL,
        "sa153_psid"                CHAR(19),
        "sa153_kv_nr_kennzeichen"   NUMERIC(1,0) NOT NULL,
        "sa153_extrablutreinigung"  NUMERIC(1,0) NOT NULL
  );

-- Satzart SA451: Ambulante Arzneimittel 
-- (Outpatient Medications)
CREATE TABLE {source_schema}.v{year}sa451 (
        "sa451_satzart"               NUMERIC(3,0) NOT NULL,
        "sa451_ausgleichsjahr"        NUMERIC(4,0) NOT NULL,
        "sa451_berichtsjahr"          NUMERIC(4,0) NOT NULL,
        "sa451_vsid"                 NUMERIC(9,0) NOT NULL,
        "sa451_psid"                  CHAR(19),
        "sa451_verordnungsdatum"      NUMERIC(8,0) NOT NULL,
        "sa451_pharmazentralnummer"   NUMERIC(8,0) NOT NULL,
        "sa451_anzahleinheitenfaktor" NUMERIC(9,0) NOT NULL
  );

-- Satzart SA551: Stationäre Diagnosen 
-- (Inpatient Diagnoses)
CREATE TABLE {source_schema}.v{year}sa551 (
        "sa551_satzart"           NUMERIC(3,0) NOT NULL,
        "sa551_ausgleichsjahr"    NUMERIC(4,0) NOT NULL,
        "sa551_berichtsjahr"      NUMERIC(4,0) NOT NULL,
        "sa551_vsid"             NUMERIC(9,0) NOT NULL,
        "sa551_psid"              CHAR(19),
        "sa551_entlassungsmonat"  NUMERIC(6,0) NOT NULL,
        "sa551_fallzaehler"       NUMERIC(2,0) NOT NULL,
        "sa551_diagnose"          CHAR(7) NOT NULL,
        "sa551_icd_code"          VARCHAR(7),
        "sa551_icd_zusatz"        CHAR(1),
        "sa551_lokalisation"      NUMERIC(1,0) NOT NULL,
        "sa551_artdiagnose"       NUMERIC(1,0) NOT NULL,
        "sa551_artbehandlung"     NUMERIC(1,0) NOT NULL
  );

-- Satzart SA651: Ambulante Diagnosen 
-- (Outpatient Diagnoses)
CREATE TABLE {source_schema}.v{year}sa651 (
        "sa651_satzart"           NUMERIC(3,0) NOT NULL,
        "sa651_ausgleichsjahr"    NUMERIC(4,0) NOT NULL,
        "sa651_berichtsjahr"      NUMERIC(4,0) NOT NULL,
        "sa651_vsid"             NUMERIC(9,0) NOT NULL,
        "sa651_psid"              CHAR(19),
        "sa651_leistungsquartal"  NUMERIC(1,0) NOT NULL,
        "sa651_diagnose"          CHAR(7) NOT NULL,
        "sa651_icd_code"          VARCHAR(7),
        "sa651_icd_zusatz"        CHAR(1),
        "sa651_qualifizierung"    CHAR(1) NOT NULL,
        "sa651_lokalisation"      NUMERIC(1,0) NOT NULL,
        "sa651_abrechnungsweg"    NUMERIC(1,0) NOT NULL
  );

-- Satzart SA751: Leistungsausgaben 
-- (Service Expenditures)
CREATE TABLE {source_schema}.v{year}sa751 (
        "sa751_satzart"           NUMERIC(3,0) NOT NULL,
        "sa751_ausgleichsjahr"    NUMERIC(4,0) NOT NULL,
        "sa751_berichtsjahr"      NUMERIC(4,0) NOT NULL,
        "sa751_vsid"             NUMERIC(9,0) NOT NULL,
        "sa751_psid"              CHAR(19),
        "sa751_aerzte"            NUMERIC(14,0) NOT NULL,
        "sa751_zahnaerzte"        NUMERIC(14,0) NOT NULL,
        "sa751_apotheken"         NUMERIC(14,0) NOT NULL,
        "sa751_krankenhaeuser"    NUMERIC(14,0) NOT NULL,
        "sa751_sonstigela"        NUMERIC(14,0) NOT NULL,
        "sa751_sachkostendialyse" NUMERIC(14,0) NOT NULL,
        "sa751_krankengeld"       NUMERIC(14,0) NOT NULL
  );

-- Satzart SA951: Krankenkassenzugehörigkeit 
-- (Health Insurance Affiliation)
CREATE TABLE {source_schema}.v{year}sa951 (
        "sa951_ausgleichsjahr"  NUMERIC(4,0) NOT NULL,
        "sa951_vsid"           NUMERIC(9,0) NOT NULL,
        "sa951_psid"            CHAR(19),
        "sa951_betriebsnummer"  NUMERIC(8,0) NOT NULL
  );
