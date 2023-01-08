-- Contraintes dynamiques
CREATE OR REPLACE TRIGGER ins_app_a
BEFORE INSERT ON appartient_a
FOR EACH ROW
DECLARE
    id_nv utilisateur."id_user"%TYPE;
    cat_liste liste."categorie_liste"%TYPE;
    cat_objet objet."categorie_obj"%TYPE;
    user_lst liste."id_user"%TYPE;
    found_bool NUMBER;
BEGIN
    -- Vérification que l'utilisateur n'est pas l'user "Nouveauté"
    SELECT "id_user" INTO user_lst
    FROM liste
    WHERE "id_liste" = :new."id_liste";

    SELECT "id_user" INTO id_nv 
    FROM utilisateur 
    WHERE "nom" = 'Nouveauté';

    IF user_lst <> id_nv THEN
        -- Vérification que l'objet et la liste sont de même type
        SELECT "categorie_liste" INTO cat_liste
        FROM liste
        WHERE "id_liste" = :new."id_liste";

        SELECT "categorie_obj" INTO cat_objet
        FROM objet
        WHERE "id_objet" = :new."id_objet";

        IF cat_liste <> cat_objet THEN
            RAISE_APPLICATION_ERROR(-20001, 'Objet et liste de type différent');
        END IF;

        -- Vérification que l'utilisateur possède bien l'objet
        SELECT COUNT(*) INTO found_bool
        FROM possede
        WHERE "id_user" = user_lst 
        AND "id_objet" = :new."id_objet";

        IF found_bool = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Objet non possédé');
        END IF;
    END IF;
END;
/

SHOW ERROR

CREATE OR REPLACE TRIGGER possede_avis
BEFORE INSERT ON avis
FOR EACH ROW
DECLARE
    CURSOR objet_possede_cur IS
        SELECT "id_objet"
        FROM possede
        WHERE "id_objet" = :new."id_objet"
        AND "id_user" = :new."id_user";
    id_objet_v NUMBER;
BEGIN
    OPEN objet_possede_cur;
    FETCH objet_possede_cur INTO id_objet_v;

    -- Vérification que l'utilisateur possède bien l'objet avant d'émettre un avis
    IF objet_possede_cur%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Objet non possédé');
    END IF;
END;
/

SHOW ERROR

-- 1
CREATE OR REPLACE TRIGGER liste_du_mois
AFTER INSERT ON objet
FOR EACH ROW
DECLARE
    id_liste_ins NUMBER;
    id_user_ins NUMBER;
    CURSOR user_nouveaute_cur IS 
        SELECT "id_user"
        FROM utilisateur
        WHERE "nom" = 'Nouveauté';
    CURSOR liste_nouveaute_cur(id_u NUMBER) IS
        SELECT "id_liste"
        FROM liste
        WHERE "id_user" = id_u
        AND "nom_liste" = 'Nouveauté du '||TRUNC(SYSDATE, 'MONTH')
        AND "categorie_liste" = :new."categorie_obj";
BEGIN
    OPEN user_nouveaute_cur;
    FETCH user_nouveaute_cur INTO id_user_ins; -- id user nouveauté

    OPEN liste_nouveaute_cur(id_user_ins);
    FETCH liste_nouveaute_cur INTO id_liste_ins; -- liste du mois pour le type d'objet

    -- Si la liste du mois n'existe pas pour ce type d'objet alors on la crée
    IF liste_nouveaute_cur%NOTFOUND THEN
        SELECT MAX("id_liste")+1 INTO id_liste_ins FROM liste;
        INSERT INTO liste ("id_liste", "nom_liste", "id_user", "categorie_liste") VALUES (id_liste_ins, 'Nouveauté du '||TRUNC(SYSDATE, 'MONTH'), id_user_ins, :new."categorie_obj");
    END IF;

    -- Insertion dans la liste appropriée
    INSERT INTO possede ("id_objet", "id_user") VALUES (:new."id_objet", id_user_ins);
    INSERT INTO appartient_a ("id_liste", "id_objet") VALUES (id_liste_ins, :new."id_objet");

    CLOSE user_nouveaute_cur;
    CLOSE liste_nouveaute_cur;
END;
/

SHOW ERRORS

-- 2
CREATE OR REPLACE TRIGGER archivage_liste
AFTER DELETE ON liste
FOR EACH ROW
-- Copie de la liste supprimée dans les archives
BEGIN
    INSERT INTO liste_archivee ("id_liste_ar", "nom_liste_ar", "id_user", "categorie_liste_ar") 
    VALUES (:old."id_liste", :old."nom_liste", :old."id_user", :old."categorie_liste");
END;
/

SHOW ERROR

CREATE OR REPLACE TRIGGER archivage_appartient_a
AFTER INSERT ON liste_archivee
FOR EACH ROW
-- Copie de tous les objets de la liste archivées dans les archives
DECLARE
    CURSOR objets_liste IS
        SELECT * 
        FROM appartient_a
        WHERE "id_liste" = :new."id_liste_ar";
BEGIN
    FOR objet_liste IN objets_liste
    LOOP
        INSERT INTO appartient_a_archive ("id_objet", "id_liste_ar", "descriptif_objet_liste_ar")
        VALUES (objet_liste."id_objet", :new."id_liste_ar", objet_liste."descriptif_objet_liste");
    END LOOP;

    DELETE FROM appartient_a WHERE "id_liste" = :new."id_liste_ar";
END;
/

SHOW ERROR