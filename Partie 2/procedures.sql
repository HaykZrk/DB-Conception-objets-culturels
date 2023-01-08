-- 1
CREATE OR REPLACE FUNCTION score_objet (id NUMBER)
RETURN FLOAT
IS
    moyenne FLOAT;
    nb_avis INTEGER;
BEGIN
    -- Sélection du nombre de critique de l'objet
    SELECT COUNT("id_objet") INTO nb_avis 
    FROM avis 
    WHERE "id_objet" = id;

    -- Retour de la moyenne
    IF nb_avis >= 20 THEN
        SELECT AVG("note") INTO moyenne
        FROM avis
        WHERE "id_objet" = id;
        RETURN moyenne;
    ELSE
        RETURN 0;
    END IF;
END;
/

SHOW ERROR

-- 2
CREATE OR REPLACE PROCEDURE favoris (id NUMBER)
IS    
    nombre_livre_v NUMBER;
    nombre_film_v NUMBER;
    nombre_jeuvideo_v NUMBER;
    -- Curseur du top 10 de l'utilisateur, en fonction de la catégorie
    CURSOR favoris_cur(cat VARCHAR) IS
        SELECT rownum, "nom_objet", "note" 
        FROM
        (
            SELECT "nom_objet", "note"
            FROM avis NATURAL JOIN objet
            WHERE "id_user" = id AND "categorie_obj" = cat
            ORDER BY "note" DESC, "date_avis" DESC
        )
        WHERE rownum <= 10;
BEGIN
    -- Compte des avis de l'utilisateur pour chaque catégorie
    SELECT COUNT(*) INTO nombre_livre_v 
    FROM avis NATURAL JOIN objet
    WHERE "id_user" = id AND "categorie_obj" = 'Livres';
    
    SELECT COUNT(*) INTO nombre_film_v 
    FROM avis NATURAL JOIN objet
    WHERE "id_user" = id AND "categorie_obj" = 'Films';
    
    SELECT COUNT(*) INTO nombre_jeuvideo_v 
    FROM avis NATURAL JOIN objet
    WHERE "id_user" = id AND "categorie_obj" = 'Jeux Vidéo';

    -- Si le nombre d'avis est supérieur à 10, afficher le top 10 de la catégorie
    IF nombre_film_v >= 10 THEN
        DBMS_OUTPUT.PUT_LINE('Top 10 films :');
        FOR film IN favoris_cur('Films')
        LOOP
            DBMS_OUTPUT.PUT_LINE(film.rownum||'. '||film."nom_objet"||' ('||film."note"||'/20)');
        END LOOP;
    END IF;

    IF nombre_livre_v >= 10 THEN
        DBMS_OUTPUT.PUT_LINE('Top 10 livres :');
        FOR livre IN favoris_cur('Livres')
        LOOP
            DBMS_OUTPUT.PUT_LINE(livre.rownum||'. '||livre."nom_objet"||' ('||livre."note"||'/20)');
        END LOOP;
    END IF;

    IF nombre_jeuvideo_v >= 10 THEN
        DBMS_OUTPUT.PUT_LINE('Top 10 jeux vidéo :');
        FOR jeuvideo IN favoris_cur('Jeux Vidéo')
        LOOP
            DBMS_OUTPUT.PUT_LINE(jeuvideo.rownum||'. '||jeuvideo."nom_objet"||' ('||jeuvideo."note"||'/20)');
        END LOOP;
    END IF;
END;
/

SHOW ERROR

-- 3
CREATE OR REPLACE PROCEDURE suggestion (id NUMBER, x NUMBER, y NUMBER, z NUMBER)
IS
    CURSOR suggestion_cur IS
        WITH users_similaires AS 
        (
            -- Utilisateurs ayant au moins z notes en communs avec id
            SELECT a1."id_user"
            FROM avis a1
            INNER JOIN avis a2 ON a1."id_objet" = a2."id_objet" AND a1."note" = a2."note"
            WHERE a2."id_user" = id AND a1."id_user" <> a2."id_user"
            GROUP BY a1."id_user"
            HAVING COUNT(a1."id_user") >= z
        ), objets_users_sim AS
        (
            -- objets en commun entre y de ces users, et non possédés par id
            SELECT "id_objet"
            FROM possede
            NATURAL JOIN users_similaires
            WHERE "id_objet" NOT IN 
            (
                SELECT "id_objet" FROM possede WHERE "id_user" = id
            )
            GROUP BY "id_objet"
            HAVING COUNT("id_objet") >= y
        )
        SELECT "id_objet", "nom_objet", "moyenne"
        FROM 
        (
            -- Jointure des tables, triés dans l'ordre décroissant de la moyenne
            SELECT "id_objet", TRUNC(AVG("note"),1) AS "moyenne"
            FROM objets_users_sim
            NATURAL JOIN avis
            GROUP BY "id_objet"
            ORDER BY AVG("note") DESC
        )
        NATURAL JOIN objet
        WHERE rownum <= x;
BEGIN
    FOR suggestion_l IN suggestion_cur
    LOOP
        DBMS_OUTPUT.PUT_LINE(suggestion_l."nom_objet"||' ('||
            suggestion_l."id_objet"||'), '||suggestion_l."moyenne"||
            '/20 en moyenne');
    END LOOP;
END;
/

SHOW ERROR