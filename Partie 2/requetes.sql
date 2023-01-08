-- 1
SELECT "id_user"
FROM liste
GROUP BY "id_user"
HAVING COUNT(DISTINCT "categorie_liste") = 3;

-- 2
SELECT "id_objet"
FROM 
(
    SELECT "id_objet"
    FROM appartient_a 
    GROUP BY "id_objet"
    HAVING COUNT("id_objet") >= 20
) 
NATURAL JOIN avis
GROUP BY "id_objet" 
HAVING AVG("note") >= 14; 

-- 3
SELECT "id_user", MIN("note") AS note_min 
FROM avis
GROUP BY "id_user"
HAVING MIN("note") >= 8;

-- 4
WITH objet_commente_semaine_derniere AS 
( 
    SELECT "id_objet" FROM AVIS
    WHERE "date_avis" > SYSDATE - 7
)
SELECT "id_objet" 
FROM objet_commente_semaine_derniere
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM objet_commente_semaine_derniere GROUP BY "id_objet")
GROUP BY "id_objet";
/* SELECT "id_objet" 
FROM 
(
    SELECT "id_objet" FROM AVIS
    WHERE "date_avis" > SYSDATE - 7
    GROUP BY "id_objet"
    ORDER BY COUNT("id_objet") DESC
)
WHERE rownum = 1; */

-- 5
WITH user_3m_cons AS 
(
    SELECT a1."id_user" AS "id_user"
    FROM avis a1 
    INNER JOIN avis a2 ON a1."id_user" = a2."id_user"
    INNER JOIN avis a3 ON a1."id_user" = a3."id_user"
    WHERE MONTHS_BETWEEN (a1."date_avis", a2."date_avis") = 1 AND MONTHS_BETWEEN (a1."date_avis", a3."date_avis") = 2
), liste_user AS 
(
    SELECT "id_user", COUNT("id_liste") AS "taille_liste"
    FROM liste
    NATURAL JOIN appartient_a
    GROUP BY "id_liste", "id_user"
)
SELECT 
    user_3m_cons."id_user",
    COUNT(DISTINCT possede."id_objet") AS nb_objets_possede, 
    COUNT(DISTINCT prevoit_achat."id_objet") AS nb_objets_souhaite,
    MIN("taille_liste") AS taille_min_collection, 
    MAX("taille_liste") AS taille_max_collection,
    AVG("taille_liste") AS taille_moy_collection
FROM user_3m_cons
NATURAL JOIN possede ON user_3m_cons."id_user" = possede."id_user"
LEFT JOIN prevoit_achat ON user_3m_cons."id_user" = prevoit_achat."id_user"
INNER JOIN liste_user ON user_3m_cons."id_user" = liste_user."id_user"
GROUP BY user_3m_cons."id_user";