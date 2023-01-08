SET SERVEROUTPUT ON
SET LINESIZE 1000
SET PAGESIZE 20

@tables
@insertion

@procedures
@declencheurs

DECLARE
    ret_f1 NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Fonction 1');
    DBMS_OUTPUT.PUT_LINE('==========');
    DBMS_OUTPUT.PUT_LINE('Objet n°29');
    ret_f1 := score_objet(29);
    DBMS_OUTPUT.PUT_LINE(ret_f1);
    DBMS_OUTPUT.PUT_LINE('Objet n°1 (pas assez collections)');
    ret_f1 := score_objet(1);
    DBMS_OUTPUT.PUT_LINE(ret_f1);
    DBMS_OUTPUT.PUT_LINE('Objet n°69 (n''existe pas)');
    ret_f1 := score_objet(69);
    DBMS_OUTPUT.PUT_LINE(ret_f1);

    DBMS_OUTPUT.PUT_LINE(CHR(10));

    DBMS_OUTPUT.PUT_LINE('Procédure 1');
    DBMS_OUTPUT.PUT_LINE('===========');
    DBMS_OUTPUT.PUT_LINE('Favoris pour l''utilisateur 7');
    favoris(7);

    DBMS_OUTPUT.PUT_LINE(CHR(10));

    DBMS_OUTPUT.PUT_LINE('Procédure 2');
    DBMS_OUTPUT.PUT_LINE('===========');
    DBMS_OUTPUT.PUT_LINE('id_user = 7; x = 5; y = 2; z = 2');
    suggestion(7,5,2,2);
    DBMS_OUTPUT.PUT_LINE('id_user = 11; x = 2; y = 2; z = 3');
    suggestion(11,2,2,3);

    DBMS_OUTPUT.PUT_LINE(CHR(10));

    DBMS_OUTPUT.PUT_LINE('Déclencheur 1');
    DBMS_OUTPUT.PUT_LINE('=============');
    DBMS_OUTPUT.PUT_LINE('Insertion de nouveaux objets...');
    INSERT INTO objet ("id_objet", "nom_objet", "categorie_obj") VALUES (51, 'Test #1', 'Films');
    INSERT INTO objet ("id_objet", "nom_objet", "categorie_obj") VALUES (52, 'Test #2', 'Jeux Vidéo');
    INSERT INTO objet ("id_objet", "nom_objet", "categorie_obj") VALUES (53, 'Test #3', 'Films');
    DBMS_OUTPUT.PUT_LINE('Exécuter la requête suivante pour constater du fonctionnement :');
    DBMS_OUTPUT.PUT_LINE('SELECT "nom_objet", "nom_liste", "id_liste" FROM objet NATURAL JOIN appartient_a NATURAL JOIN liste WHERE "id_user" = 21 ORDER BY "id_liste";');

    DBMS_OUTPUT.PUT_LINE(CHR(10));

    DBMS_OUTPUT.PUT_LINE('Déclencheur 2');
    DBMS_OUTPUT.PUT_LINE('=============');
    DBMS_OUTPUT.PUT_LINE('Suppression d''une liste...');
    DELETE FROM liste WHERE "id_liste" = 67;
    DBMS_OUTPUT.PUT_LINE('Exécuter la requête suivante pour constater du fonctionnement :');
    DBMS_OUTPUT.PUT_LINE('SELECT "id_liste_ar", "nom_liste_ar", "id_user", "id_objet" FROM liste_archivee NATURAL JOIN appartient_a_archive;');
END;
/