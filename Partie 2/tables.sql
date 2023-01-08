DROP TABLE "AVIS";
DROP TABLE "APPARTIENT_A";
DROP TABLE "APPARTIENT_A_ARCHIVE";
DROP TABLE "POSSEDE";
DROP TABLE "PREVOIT_ACHAT";
DROP TABLE "LISTE";
DROP TABLE "LISTE_ARCHIVEE";
DROP TABLE "UTILISATEUR";
DROP TABLE "OBJET";

CREATE TABLE "UTILISATEUR" (
  "id_user" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
  "login" VARCHAR(64) UNIQUE NOT NULL,
  "nom" VARCHAR(128) NOT NULL,
  "prenom" VARCHAR(128) NOT NULL,
  "adresse" VARCHAR(512),
  "email" VARCHAR(128) NOT NULL,
  "motdepasse" VARCHAR(256) NOT NULL,
  "date_naiss" DATE,
  "date_inscript" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT PK_UTILISATEUR PRIMARY KEY ("id_user"),
  CONSTRAINT CK_UTILISATEUR_DATES CHECK ("date_inscript" > "date_naiss"),
  CONSTRAINT CK_UTILISATEUR_MOTDEPASSE CHECK ( REGEXP_LIKE("motdepasse", '^([[:alnum:]]|_)+$') ),
  CONSTRAINT CK_UTILISATEUR_LOGIN CHECK ( SUBSTR("prenom",1,1) =  SUBSTR("login",1,1) AND LOWER(SUBSTR("nom",1,7)) = SUBSTR( SUBSTR("login",1, LENGTH("login")- 2), 2, 7) AND REGEXP_LIKE( SUBSTR("login",LENGTH("login")- 1,2), '^[0-9]{2}$') ),
  CONSTRAINT CK_UTILISATEUR_MAIL CHECK ( REGEXP_LIKE("email", '^[[:alnum:]\.]+@([[:alnum:]-]+\.)+[[:alnum:]-]{2,4}$') )
);

CREATE TABLE "OBJET" (
  "id_objet" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
  "nom_objet" VARCHAR(128) UNIQUE NOT NULL,
  "description_objet" VARCHAR(1024),
  "categorie_obj" VARCHAR(64) NOT NULL,
  CONSTRAINT PK_OBJET PRIMARY KEY ("id_objet"),
  CONSTRAINT CK_OBJET_CATEGORIE CHECK ( "categorie_obj" IN ('Livres', 'Films', 'Jeux Vidéo') )
);

CREATE TABLE "LISTE" (
  "id_liste" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
  "nom_liste" VARCHAR(256) NOT NULL,
  "descriptif_liste" VARCHAR(512),
  "id_user" NUMBER NOT NULL,
  "categorie_liste" VARCHAR(64),
  CONSTRAINT PK_LISTE PRIMARY KEY ("id_liste"),
  CONSTRAINT CK_LISTE_CATEGORIE CHECK ( "categorie_liste" IN ('Livres', 'Films', 'Jeux Vidéo') )
);

CREATE TABLE "AVIS" (
  "id_objet" NUMBER,
  "id_user" NUMBER,
  "note" NUMBER,
  "commentaire" VARCHAR(1024),
  "date_avis" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT PK_AVIS PRIMARY KEY ("id_objet", "id_user"),
  CONSTRAINT CK_AVIS_NOTE CHECK ( "note" BETWEEN 1 AND 20 ) 
);

CREATE TABLE "APPARTIENT_A" (
  "id_objet" NUMBER,
  "id_liste" NUMBER,
  "descriptif_objet_liste" VARCHAR(1024),
  CONSTRAINT PK_APPARTIENT_A PRIMARY KEY ("id_objet", "id_liste")
);

CREATE TABLE "APPARTIENT_A_ARCHIVE" (
  "id_objet" NUMBER,
  "id_liste_ar" NUMBER,
  "descriptif_objet_liste_ar" VARCHAR(1024),
  CONSTRAINT PK_APPARTIENT_A_ARCHIVE PRIMARY KEY ("id_objet", "id_liste_ar")
);

CREATE TABLE "LISTE_ARCHIVEE" (
  "id_liste_ar" NUMBER,
  "nom_liste_ar" VARCHAR(256) NOT NULL,
  "categorie_liste_ar" VARCHAR(64),
  "date_archivage" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "id_user" NUMBER NOT NULL,
  CONSTRAINT PK_LISTE_ARCHIVEE PRIMARY KEY ("id_liste_ar"),
  CONSTRAINT CK_LISTE_CATEGORIE_AR CHECK ( "categorie_liste_ar" IN ('Livres', 'Films', 'Jeux Vidéo') )
);

CREATE TABLE "POSSEDE" (
  "id_objet" NUMBER,
  "id_user" NUMBER,
  CONSTRAINT PK_POSSEDE PRIMARY KEY ("id_objet", "id_user")
);

CREATE TABLE "PREVOIT_ACHAT" (
  "id_objet" NUMBER,
  "id_user" NUMBER,
  CONSTRAINT PK_POSSEDE_ACHAT PRIMARY KEY ("id_objet", "id_user")
);

ALTER TABLE "APPARTIENT_A" ADD CONSTRAINT FK_APPARTIENT_A_id_liste FOREIGN KEY ("id_liste") REFERENCES "LISTE" ("id_liste"); -- ON DELETE CASCADE;
ALTER TABLE "APPARTIENT_A" ADD CONSTRAINT FK_APPARTIENT_A_id_objet FOREIGN KEY ("id_objet") REFERENCES "OBJET" ("id_objet") ON DELETE CASCADE;
ALTER TABLE "APPARTIENT_A_ARCHIVE" ADD CONSTRAINT FK_APPARTIENT_A_ARCHIVE_id_liste_ar FOREIGN KEY ("id_liste_ar") REFERENCES "LISTE_ARCHIVEE" ("id_liste_ar") ON DELETE CASCADE;
ALTER TABLE "APPARTIENT_A_ARCHIVE" ADD CONSTRAINT FK_APPARTIENT_A_ARCHIVE_id_objet FOREIGN KEY ("id_objet") REFERENCES "OBJET" ("id_objet") ON DELETE CASCADE;
ALTER TABLE "AVIS" ADD CONSTRAINT FK_AVIS_id_user FOREIGN KEY ("id_user") REFERENCES "UTILISATEUR" ("id_user") ON DELETE CASCADE;
ALTER TABLE "AVIS" ADD CONSTRAINT FK_AVIS_id_objet FOREIGN KEY ("id_objet") REFERENCES "OBJET" ("id_objet") ON DELETE CASCADE;
ALTER TABLE "LISTE" ADD CONSTRAINT FK_LISTE_id_user FOREIGN KEY ("id_user") REFERENCES "UTILISATEUR" ("id_user") ON DELETE CASCADE;
ALTER TABLE "LISTE_ARCHIVEE" ADD CONSTRAINT FK_LISTE_ARCHIVEE_id_user FOREIGN KEY ("id_user") REFERENCES "UTILISATEUR" ("id_user") ON DELETE CASCADE;
ALTER TABLE "POSSEDE" ADD CONSTRAINT FK_POSSEDE_id_user FOREIGN KEY ("id_user") REFERENCES "UTILISATEUR" ("id_user") ON DELETE CASCADE;
ALTER TABLE "POSSEDE" ADD CONSTRAINT FK_POSSEDE_id_objet FOREIGN KEY ("id_objet") REFERENCES "OBJET" ("id_objet") ON DELETE CASCADE;
ALTER TABLE "PREVOIT_ACHAT" ADD CONSTRAINT FK_PREVOIT_ACHAT_id_user FOREIGN KEY ("id_user") REFERENCES "UTILISATEUR" ("id_user") ON DELETE CASCADE;
ALTER TABLE "PREVOIT_ACHAT" ADD CONSTRAINT FK_PREVOIT_ACHAT_id_objet FOREIGN KEY ("id_objet") REFERENCES "OBJET" ("id_objet") ON DELETE CASCADE;