-- A. Utwórz tabelę o nazwie FIGURY z dwoma kolumnami:
--ID - number(1) - klucz podstawowy
--KSZTALT - MDSYS.SDO_GEOMETRY.

CREATE TABLE FIGURY(
    ID NUMBER(1) PRIMARY KEY,
    KSZTALT MDSYS.SDO_GEOMETRY
);

-- B. Wstaw do tabeli FIGURY trzy kształty przedstawione na rysunku poniżej. Układ odniesienia
-- pozostaw pusty – będzie to kartezjański układ odniesienia.
INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    1,
    MDSYS.SDO_GEOMETRY(2003, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,4),
    SDO_ORDINATE_ARRAY(3,5, 5,3, 7,5))
    );
	
INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    2,
    MDSYS.SDO_GEOMETRY(2003, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(1,1, 5,5))
    );
	
INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    3,
    MDSYS.SDO_GEOMETRY(2002, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
    SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1))
    );

-- C. Wstaw do tabeli FIGURY własny kształt o nieprawidłowej definicji (przykłady: otwarty wielokąt,
-- wielokąt zdefiniowany w oparciu o punkty podane w nieprawidłowej kolejności, koło
-- zdefiniowane przez punkty leżące na prostej, kształt, którego definicja elementów określona w
-- SDO_ELEM_INFO jest niezgodna z typem geometrii SDO_GEOM itp.)

INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    4,
    MDSYS.SDO_GEOMETRY(2003, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(1,1))
    );

SELECT ID, MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT,0.005) VALID 
FROM FIGURY;

-- D. Zweryfikuj poprawność wstawionych geometrii za pomocą funkcji
-- SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT (na slajdach znajdziesz przykład użycia
-- tej funkcji)

DELETE FROM FIGURY
WHERE MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT,0.01) <> 'TRUE';

-- F. Zatwierdź transakcję.
COMITT;