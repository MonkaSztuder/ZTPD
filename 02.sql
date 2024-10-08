--1. Utwórz w swoim schemacie kopię tabeli MOVIES ze schematu ZTPD.
desc ztpd.movies;
CREATE TABLE movies_copy AS SELECT * FROM ztpd.movies;
/

-- 2. Zapoznaj się ze schematem tabeli MOVIES, zwracając uwagę na kolumnę typu BLOB.
desc movies_copy;
/

-- 3. Sprawdź zapytaniem SQL do tabeli MOVIES, które filmy nie mają okładek.
SELECT * FROM movies_copy WHERE cover IS NULL;

-- 4. Dla filmów, które mają okładki odczytaj rozmiar obrazka w bajtach.
SELECT id,title, DBMS_LOB.GETLENGTH(cover) AS FILESIZE FROM movies_copy WHERE cover IS NOT NULL;   

-- 5. Sprawdź co się stanie gdy zostanie dokonana próba odczytu rozmiaru obrazków dla filmów, które nie posiadają okładek w tabeli MOVIES.
SELECT id,title, DBMS_LOB.GETLENGTH(cover) AS FILESIZE FROM movies_copy WHERE cover IS NULL;

-- 6. Brakujące okładki zostały umieszczone w jednym z katalogów systemu plików serwera
-- bazy danych w plikach eagles.jpg i escape.jpg. Został on udostępniony w bazie danych jako
-- obiekt DIRECTORY o nazwie TPD_DIR. Upewnij się zapytaniem do perspektywy
-- ALL_DIRECTORIES czy widzisz katalog TPD_DIR i odczytaj jaką ścieżkę w systemie
-- plików on reprezentuje

SELECT * FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'TPD_DIR';

-- 7. Zmodyfikuj okładkę filmu o identyfikatorze 66 w tabeli MOVIES na pusty obiekt BLOB
-- (lokalizator bez wartości), a jako typ MIME (w przeznaczonej do tego celu kolumnie tabeli)
-- podaj: image/jpeg. Zatwierdź transakcję

UPDATE movies_copy SET cover = EMPTY_BLOB(), mime_type = 'image/jpeg' WHERE id = 66;
COMMIT;
/
-- 8. Odczytaj z tabeli MOVIES rozmiar obrazków dla filmów o identyfikatorach 65 i 66.
SELECT id,title, DBMS_LOB.GETLENGTH(cover) AS FILESIZE FROM movies_copy WHERE id IN (65,66);

-- 9. Napisz program w formie anonimowego bloku PL/SQL, który dla filmu o identyfikatorze
-- 66 przekopiuje binarną zawartość obrazka z pliku escape.jpg znajdującego się w katalogu
-- systemu plików serwera (za pośrednictwem obiektu BFILE) do pustego w tej chwili obiektu
-- BLOB w tabeli MOVIES. Wykorzystaj poniższy schemat postępowania:
-- 1) Zadeklaruj w programie zmienną typu BFILE i zwiąż ją z plikiem okładki
-- w katalogu na serwerze.
-- 2) Odczytaj z tabeli MOVIES pusty obiekt BLOB do zmiennej (nie zapomnij
-- o klauzuli zakładającej blokadę na wierszu zawierającym obiekt BLOB,
-- który będzie modyfikowany).
-- 3) Przekopiuj zawartość binarną z BFILE do BLOB
-- (nie zapominając o otwarciu i zamknięciu pliku BFILE!).
-- 4) Zatwierdź transakcję.

DECLARE
    v_bfile BFILE:=BFILENAME('TPD_DIR', 'escape.jpg');
    v_blob BLOB;
BEGIN
    SELECT cover INTO v_blob FROM movies_copy WHERE id = 66 FOR UPDATE;
    DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
    DBMS_LOB.CLOSE(v_bfile);
    COMMIT;
END;
/

-- 10. Utwórz tabelę TEMP_COVERS o poniższej strukturze:
-- movie_id NUMBER(12)
-- image BFILE
-- mime_type VARCHAR2(50)

CREATE TABLE temp_covers(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

-- 11. Wstaw do tabeli TEMP_COVERS obrazek z pliku eagles.jpg z udostępnionego katalogu.
-- Nadaj mu identyfikator filmu, którego jest okładką (65). Jako typ MIME podaj: image/jpeg.
-- Zatwierdź transakcję.

INSERT INTO temp_covers VALUES(65, BFILENAME('TPD_DIR', 'eagles.jpg'), 'image/jpeg');
COMMIT;

-- 12. Odczytaj rozmiar w bajtach dla obrazka załadowanego jako BFILE
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS FILESIZE FROM temp_covers;

-- 13. Napisz program w formie anonimowego bloku PL/SQL, który dla filmu o identyfikatorze
-- 65 utworzy obiekt BLOB, przekopiuje do niego binarną zawartość okładki BFILE z tabeli
-- TEMP_COVERS i umieści BLOB w odpowiednim wierszu tabeli MOVIES. Wykorzystaj
-- poniższy schemat postępowania:
-- 1) Odczytaj lokalizator BFILE i informację o typie MIME obrazka z tabeli
-- TEMP_COVERS do zmiennych w programie.
-- 2) Utwórz tymczasowy obiekt LOB.
-- 3) Przekopiuj do niego zawartość binarną z BFILE
-- (nie zapominając o otwarciu i zamknięciu pliku!).
-- 4) Zapisz tymczasowy LOB do tabeli MOVIES poleceniem UPDATE, jednocześnie
-- ustawiając typ MIME na odczytany z tabeli TEMP_COVERS.
-- 5) Zwolnij tymczasowy LOB.
-- 6) Zatwierdź transakcję.

DECLARE 
    v_bfile BFILE;
    v_mime VARCHAR2(50);
    v_blob BLOB;
BEGIN
    SELECT image, mime_type INTO v_bfile, v_mime FROM temp_covers WHERE movie_id = 65;
    DBMS_LOB.CREATETEMPORARY(v_blob, TRUE);
    DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
    DBMS_LOB.CLOSE(v_bfile);
    UPDATE movies_copy SET cover = v_blob, mime_type = v_mime WHERE id = 65;
    DBMS_LOB.FREETEMPORARY(v_blob);
    COMMIT;
END;
/
-- 14. Odczytaj rozmiar w bajtach dla okładek filmów 65 i 66 z tabeli MOVIES.
SELECT id,title, DBMS_LOB.GETLENGTH(cover) AS FILESIZE FROM movies_copy WHERE id IN (65,66);

-- 15. Usuń tabelę MOVIES ze swojego schematu.
DROP TABLE MOVIES_COPY;
