/*Copyright (c) Fraunhofer MEVIS, Germany. All rights reserved.
**InsertLicense** code
-----------------------------------------------------------------------------
file: schema_format3.py
author: Melissa Finster
date: 05/2023
description: Creating the postgres schema for HDL Format 3 
-----------------------------------------------------------------------------
*/

/*
German Health Data Lab Format 3
4 schema 
- {versicherte} (insuree)
- Ambulante Faelle (ambulatory cases)
- Stationaere Faelle (inpatient cases)
- {arzneimittel} (drugs) */

-- Create Schema
DROP SCHEMA IF EXISTS {versicherte} CASCADE;
DROP SCHEMA IF EXISTS {ambulante_faelle} CASCADE;
DROP SCHEMA IF EXISTS {arzneimittel} CASCADE;
DROP SCHEMA IF EXISTS {stationaere_faelle} CASCADE;
CREATE SCHEMA {versicherte};
CREATE SCHEMA {ambulante_faelle};
CREATE SCHEMA {arzneimittel};
CREATE SCHEMA {stationaere_faelle};

-- Create Tables
CREATE TABLE {versicherte}.VERSQDMP (
    "berjahr"        NUMERIC(4) NOT NULL, 
    "kassenik"       NUMERIC(9) NOT NULL, 
    "arbnr"          NUMERIC(9) NOT NULL, 
    "versq"          NUMERIC(5) NOT NULL, 
    "dmpprog"        VARCHAR(2) NOT NULL, 
    "dmptage"        NUMERIC(2) NOT NULL
  );


CREATE TABLE {versicherte}.VERS (
    -- "lfdnr"          VARCHAR(2) NOT NULL, 
    "berjahr"        NUMERIC(4) NOT NULL, 
    "kassenik"       NUMERIC(9) NOT NULL, 
    "lfdnr"          NUMERIC(2),
    "arbnr"          NUMERIC(9) NOT NULL,
    "gebjahr"        NUMERIC(4) NOT NULL,
    "plz"            VARCHAR(5) NOT NULL,
    "vitalstatus"    NUMERIC(1) NOT NULL,
    "sterbedat"      NUMERIC(8) 
  );

  CREATE TABLE {versicherte}.VERSQ (
    "berjahr"                   NUMERIC(4) NOT NULL, 
    "kassenik"                  NUMERIC(9) NOT NULL, 
    "arbnr"                     NUMERIC(9) NOT NULL, 
    "versq"                     NUMERIC(5) NOT NULL, 
    "geschlecht"                NUMERIC(1) NOT NULL, 
    "verstage"                  NUMERIC(2) NOT NULL,
    "verstageausl"              NUMERIC(2) NOT NULL, 
    "versstatus"                NUMERIC(5) NOT NULL, 
    "verstagekg"                NUMERIC(2) NOT NULL, 
    "verstagekosterstwahlt"     NUMERIC(2) NOT NULL
  );


  CREATE TABLE {ambulante_faelle}.AMBFALL (
    "berjahr"            NUMERIC(4) NOT NULL, 
    "kassenik"           NUMERIC(9) NOT NULL, 
    "arbnr"              NUMERIC(9) NOT NULL, 
    "abrq"               NUMERIC(5) NOT NULL, 
    "fallidamb"          NUMERIC(11) NOT NULL, 
    "svnr"               VARCHAR(25),
    "svtyp"              NUMERIC(1) , 
    "bsnrpseudo"         NUMERIC(12), 
    "bsnrkv"             NUMERIC(2), 
    "bsnruebpseudo"      NUMERIC(12),
    "bsnruebkv"          NUMERIC(2) , 
    "lanruebpseudo"      NUMERIC(12), 
    "lanruebfg"          NUMERIC(2), 
    "lanruebpruef"       VARCHAR(1),
    "inansprartamb"      VARCHAR(1) NOT NULL, 
    "unfall"             NUMERIC(1) NOT NULL, 
    "behandartamb"       NUMERIC(1) , 
    "entbindungsdat"     NUMERIC(8) ,
    "punktzahl"          NUMERIC(12,2) , 
    "fallkoamb"          NUMERIC(12,2), 
    "dialysesachko"      NUMERIC(12,2),
    "beginndatamb"       NUMERIC(8) , 
    "endedatamb"         NUMERIC(8) 

  );

  CREATE TABLE {ambulante_faelle}.AMBDIAG(
    "berjahr"            NUMERIC(4) NOT NULL, 
    "kassenik"           NUMERIC(9) NOT NULL, 
    "fallidamb"          NUMERIC(11) NOT NULL, 
    "icdamb"             VARCHAR(12) NOT NULL , 
    "diagsich"           VARCHAR(1) , 
    "diaglokal"          VARCHAR(1),
    "diagdat"            NUMERIC(8) 
    
  );

  CREATE TABLE {ambulante_faelle}.AMBLEIST (
    "berjahr"         NUMERIC(4) NOT NULL, 
    "kassenik"         NUMERIC(9) NOT NULL, 
    "fallidamb"        NUMERIC(11) NOT NULL, 
    "nbsnrpseudo"      NUMERIC(12), 
    "nbsnrkv"          NUMERIC(2), 
    "lanrpseudo"       NUMERIC(12),
    "lanrfg"           NUMERIC(2) , 
    "lanrpruef"        VARCHAR(1), 
    "gonr"             VARCHAR(25) NOT NULL,  
    "gonrdat"          NUMERIC(8) NOT NULL, 
    "multiplikator"    NUMERIC(6) , 
    "abrbegr"          VARCHAR(70), 
    "sachkobez"        VARCHAR(70), 
    "ambleistzeit"     VARCHAR(4),
    "tsvgart"          NUMERIC(1) , 
    "tsvgdat"          NUMERIC(8)  , 
    "tsvgarzt"         VARCHAR(6) , 
    "tsvgbsnrpseudo"   NUMERIC(12) ,
    "tsvgbsnrkv"       NUMERIC(2) ,
    "zweitmein"        VARCHAR(2), 
    "gonrbewert"       NUMERIC(5,2)
  );

    CREATE TABLE {ambulante_faelle}.AMBOPS (
    "berjahr"           NUMERIC(4) NOT NULL, 
    "kassenik"          NUMERIC(9) NOT NULL, 
    "fallidamb"         NUMERIC(11) NOT NULL, 
    "ops"               VARCHAR(12) NOT NULL , 
    "opslokal"          VARCHAR(1) , 
    "opsdat"            NUMERIC(8) 
    
  );


  CREATE TABLE {ambulante_faelle}.ZAHNFALL (
     "berjahr"           NUMERIC(4) NOT NULL, 
    "kassenik"           NUMERIC(9) NOT NULL, 
    "arbnr"              NUMERIC(9) NOT NULL, 
    "leistq"             NUMERIC(5), 
    "fallidzahn"         NUMERIC(11)NOT NULL, 
    "zanrpseudo"         NUMERIC(12),
    "zanrabrpseudo"      NUMERIC(12) NOT NULL, 
    "zakzv"              NUMERIC(2), 
    "behandartzahn"      VARCHAR(2) NOT NULL,  
    "beginndatzahn"      NUMERIC(8),
    "endedatzahn"        NUMERIC(8) , 
    "fallkozahn"         NUMERIC(12,2)NOT NULL,
    "eigenlabor"         NUMERIC(12,2), 
    "fremdlabor"         NUMERIC(12,2),
    "inansprartzahn"     VARCHAR(1) 
  );

CREATE TABLE {ambulante_faelle}.ZAHNLEIST (
   "berjahr"              NUMERIC(4) NOT NULL, 
    "kassenik"            NUMERIC(9) NOT NULL, 
    "fallidzahn"          NUMERIC(11) NOT NULL,
    "leistdat"            NUMERIC(8) ,
    "zahn"                VARCHAR(5) ,
    "gebnr"               VARCHAR(25) NOT NULL,
    "gebpos"    	        VARCHAR(5),
    "gebnrzahl"           NUMERIC(4) NOT NULL
  );

    CREATE TABLE {ambulante_faelle}.ZAHNBEF (
    "berjahr"           NUMERIC(4) NOT NULL, 
    "kassenik"          NUMERIC(9) NOT NULL, 
    "fallidzahn"        NUMERIC(11) NOT NULL, 
    "befnr"             VARCHAR(5) NOT NULL, 
    "zahn"              VARCHAR(95) NOT NULL, 
    "refart"            VARCHAR(1) ,
    "befnrzahl"         NUMERIC(4) NOT NULL
    
  );

CREATE TABLE {stationaere_faelle}.KHFALL (
     "berjahr"              NUMERIC(4) NOT NULL, 
    "kassenik"              NUMERIC(9) NOT NULL, 
    "arbnr"                 NUMERIC(9) NOT NULL, 
    "fallidkh"              NUMERIC(11)NOT NULL, 
    "khpseudo"              NUMERIC(12)NOT NULL, 
    "khklass"               NUMERIC(2)NOT NULL, 
    "khregkz"               NUMERIC(2) NOT NULL, 
    "khpruef"               NUMERIC(1), 
    "aufndat"               VARCHAR(8) NOT NULL, 
    "aufngrund"             VARCHAR(4)NOT NULL, 
    "entlassgrund"          VARCHAR(3) NOT NULL, 
    "aufnfa"                VARCHAR(4)NOT NULL, 
    "einweispseudo"         NUMERIC(12), 
    "einweisfg"             NUMERIC(2),
    "einweispruef"          NUMERIC(1) ,
    "veranlasskhpseudo"     NUMERIC(12)  , 
    "veranlasskhklass"      NUMERIC(2) ,
    "veranlasskhregknz"     NUMERIC(2) ,
    "veranlasskhpruef"      NUMERIC(1),
    "beatstd"               VARCHAR(4), 
    "veranlassstellepseudo" VARCHAR(30)
  );


CREATE TABLE {stationaere_faelle}.KHFA(
   "berjahr"                  NUMERIC(4) NOT NULL, 
    "kassenik"                NUMERIC(9) NOT NULL, 
    "fallidkh"                NUMERIC(11) NOT NULL,
    "fa"                      VARCHAR(4) NOT NULL,
    "entlassdat"              VARCHAR(8) NOT NULL,
    "entlasszeit"             VARCHAR(4) NOT NULL
  );


CREATE TABLE {stationaere_faelle}.KHDIAG (
   "berjahr"              NUMERIC(4) NOT NULL, 
    "kassenik"            NUMERIC(9) NOT NULL, 
    "fallidkh"            NUMERIC(11) NOT NULL,
    "diagart"             VARCHAR(1) NOT NULL,
    "icdkh"               VARCHAR(9) NOT NULL,
    "icdlokal"            VARCHAR(1) ,
    "sekicd"    	        VARCHAR(9),
    "sekicdlokal"         VARCHAR(1) 
  );



CREATE TABLE {stationaere_faelle}.KHPROZ (
   "berjahr"                NUMERIC(4) NOT NULL, 
    "kassenik"              NUMERIC(9) NOT NULL, 
    "fallidkh"              NUMERIC(11) NOT NULL,
    "proz"                  VARCHAR(11) NOT NULL,
    "prozdat"               VARCHAR(8) NOT NULL,
    "prozlokal"             VARCHAR(1) 
  );


CREATE TABLE {stationaere_faelle}.KHENTG (
   "berjahr"                   NUMERIC(4) NOT NULL, 
    "kassenik"                 NUMERIC(9) NOT NULL, 
    "fallidkh"                 NUMERIC(11) NOT NULL,
    "entgart"                  VARCHAR(8) NOT NULL,
    "entgbetrag"               NUMERIC(8,2) NOT NULL,
    "abrvondat"                VARCHAR(8) NOT NULL,
    "abrbisdat"                VARCHAR(8)NOT NULL,
    "entgzahl"                 NUMERIC(3) NOT NULL,
    "tageobe"                  NUMERIC(3) 
  );



  CREATE TABLE {arzneimittel}.REZ (
    "berjahr"               NUMERIC(4) NOT NULL, 
    "kassenik"              NUMERIC(9) NOT NULL, 
    "arbnr"                 NUMERIC(9) NOT NULL, 
    "reznr"                 NUMERIC(9)NOT NULL, 
    "pznrez"                VARCHAR(10)NOT NULL, 
    "vodat"                 NUMERIC(8)NOT NULL,
    "bsnrvopseudo"          NUMERIC(12) , 
    "bsnrvovb"              NUMERIC(2), 
    "bsnrvoregknz"          NUMERIC(2)  ,
    "lenrvopseudo"          NUMERIC(12),
    "lenrvofg"              NUMERIC(2) , 
    "lenrvopruef"           NUMERIC(1), 
    "lenrvopseudoarztnr"    NUMERIC(1), 
    "abgabedat"             NUMERIC(8)NOT NULL,
    "begruendung"           NUMERIC(1) NOT NULL, 
    "vertragskz"            VARCHAR(25)  , 
    "apopseudo"             NUMERIC(12) NOT NULL, 
    "apoklass"              NUMERIC(2) NOT NULL,
    "aporegknz"             NUMERIC(2)NOT NULL , 
    "apopruef"              NUMERIC(1), 
    "apositz"               NUMERIC(1)NOT NULL,
    "apotyp"                VARCHAR(1), 
    "menge"                 NUMERIC(6)NOT NULL, 
    "noctu"                 VARCHAR(1), 
    "autidem"               VARCHAR(1),
    "wirkstoffvo"           VARCHAR(1) , 
    "ambetrag"              NUMERIC(9,2) NOT NULL , 
    "abschlaege"            NUMERIC(9,2) NOT NULL, 
    "zuzahlkz"              VARCHAR(1) NOT NULL,
    "zuzahlges"             NUMERIC(9,2) NOT NULL, 
    "zuzahl"                NUMERIC(9,2), 
    "mehrkosten"            NUMERIC(9,2),
    "eigenbet"              NUMERIC(9,2)
  );
CREATE TABLE {arzneimittel}.EZD (
   "berjahr"                NUMERIC(4) NOT NULL, 
    "kassenik"              NUMERIC(9) NOT NULL, 
    "reznr"                 NUMERIC(19) NOT NULL,
    "pznezd"                VARCHAR(8) NOT NULL,
    --"zaehler"               NUMERIC(2) NOT NULL,
    "zaehler"               NUMERIC(2),
    -- "einheit"               VARCHAR(2) NOT NULL,
    "einheit"               VARCHAR(2) ,
    "faktor"    	          NUMERIC(5)NOT NULL,
    "faktorkennzeichen"     VARCHAR(2) NOT NULL
  );
