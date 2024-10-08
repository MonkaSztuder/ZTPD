-- 1. Utwórz w swoim schemacie tabelę DOKUMENTY o poniższej strukturze:
-- ID NUMBER(12) PRIMARY KEY
-- DOKUMENT CLOB

CREATE TABLE DOKUMENTY(
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);
/
desc DOKUMENTY;

-- 2. Wstaw do tabeli DOKUMENTY dokument utworzony przez konkatenację 10000 kopii
-- tekstu 'Oto tekst. ' nadając mu ID = 1 (Wskazówka: wykorzystaj anonimowy blok kodu
-- PL/SQL).

DECLARE
    v_clob CLOB;
BEGIN
    FOR i IN 1..10000 LOOP
        v_clob:= v_clob || 'Oto tekst. ';
    END LOOP;
    INSERT INTO DOKUMENTY VALUES(1, v_clob);
    COMMIT;
END;
/

-- 3. Wykonaj poniższe zapytania:
-- a) odczyt całej zawartości tabeli DOKUMENTY
SELECT * from DOKUMENTY;
-- b) odczyt treści dokumentu po zamianie na wielkie litery
SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
-- c) odczyt rozmiaru dokumentu funkcją LENGTH
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
-- d) odczyt rozmiaru dokumentu odpowiednią funkcją z pakietu DBMS_LOB
SELECT DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
-- e) odczyt 1000 znaków dokumentu począwszy od znaku na pozycji 5 funkcją SUBSTR
SELECT SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
-- f) odczyt 1000 znaków dokumentu począwszy od znaku na pozycji 5 odpowiednią funkcją z pakietu DBMS_LOB
SELECT DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;

-- 4. Wstaw do tabeli drugi dokument jako pusty obiekt CLOB nadając mu ID = 2.
INSERT INTO DOKUMENTY VALUES(2, EMPTY_CLOB());

/

-- 5. Wstaw do tabeli trzeci dokument jako NULL nadając mu ID = 3. Zatwierdź transakcję.
INSERT INTO DOKUMENTY VALUES(3, NULL);
COMMIT;
/

-- 6. Sprawdź jaki będzie efekt zapytań z punktu 3 dla wszystkich trzech dokumentów.
SELECT * from DOKUMENTY;
SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
SELECT DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;
/
-- 7. Napisz program w formie anonimowego bloku PL/SQL, który do dokumentu o identyfikatorze 2 przekopiuje tekstową zawartość pliku dokument.txt znajdującego się w katalogu systemu plików serwera udostępnionym przez obiekt DIRECTORY o nazwie TPD_DIR do pustego w tej chwili obiektu CLOB w tabeli DOKUMENTY. Wykorzystaj poniższy schemat postępowania:
    -- 1) Zadeklaruj w programie zmienną typu BFILE i zwiąż ją z plikiem tekstowym w katalogu na serwerze.
    -- 2) Odczytaj z tabeli DOKUMENTY pusty obiekt CLOB do zmiennej (nie zapomnij o klauzuli zakładającej blokadę na wierszu zawierającym obiekt CLOB, który będzie modyfikowany).
    -- 3) Przekopiuj zawartość z BFILE do CLOB procedurą LOADCLOBFROMFILE z pakietu DBMS_LOB (nie zapominając o otwarciu i zamknięciu pliku BFILE!).
    -- 4) Zatwierdź transakcję.
    -- 5) Wyświetl na konsoli status operacji kopiowania.
DECLARE 
    vbflie BFILE;
    vclob CLOB;
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT DOKUMENT INTO  vclob FROM DOKUMENTY WHERE ID = 2 FOR UPDATE;
    vbflie := BFILENAME('TPD_DIR', 'dokument.txt');
    DBMS_LOB.FILEOPEN(vbflie, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADCLOBFROMFILE(vclob, vbflie, DBMS_LOB.GETLENGTH(vbflie), doffset, soffset,873, langctx, warn);
    DBMS_LOB.FILECLOSE(vbflie);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;
/
-- 8. Do dokumentu o identyfikatorze 3 przekopiuj tekstową zawartość pliku dokument.txt
-- znajdującego się w katalogu systemu plików serwera (za pośrednictwem obiektu BFILE), tym
-- razem nie korzystając z PL/SQL, a ze zwykłego polecenia UPDATE z poziomu SQL.

UPDATE DOKUMENTY SET DOKUMENT = TO_CLOB(BFILENAME('TPD_DIR','dokument.txt')) WHERE ID = 3;
/

-- 9. Odczytaj zawartość tabeli DOKUMENTY.
select * from DOKUMENTY;
/
-- 10. Odczytaj rozmiar wszystkich dokumentów z tabeli DOKUMENTY.
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
/
-- 11. Usuń tabelę DOKUMENTY.
DROP TABLE DOKUMENTY;
/
-- 12. Zaimplementuj w PL/SQL procedurę CLOB_CENSOR, która w podanym jako pierwszy
-- parametr dużym obiekcie CLOB zastąpi wszystkie wystąpienia tekstu podanego jako drugi
-- parametr (typu VARCHAR2) kropkami, tak aby każdej zastępowanej literze odpowiadała
-- jedna kropka.
-- Wskazówka: Nie korzystaj z funkcji REPLACE (tylko z funkcji INSTR i procedury WRITE
-- z pakietu DBMS_LOB), tak aby procedura była zgodna z wcześniejszymi wersjami Oracle,
-- w których funkcja REPLACE była ograniczona do tekstów, których długość nie przekraczała
-- limitu dla VARCHAR2.
/
CREATE OR REPLACE PROCEDURE CLOB_CENSOR(
    pclob IN OUT CLOB,
    ptext IN VARCHAR2
)
IS
    vpos INTEGER;
    censor VARCHAR2(250);
BEGIN
    censor := '';
    FOR i IN 1..LENGTH(ptext) LOOP
        censor := censor || '.';
    END LOOP;
    vpos := INSTR(pclob, ptext);
    LOOP
        EXIT WHEN vpos = 0;
        DBMS_LOB.WRITE(pclob, LENGTH(ptext), vpos, censor);
        vpos := INSTR(pclob, ptext, vpos + LENGTH(ptext));
    END LOOP;
END CLOB_CENSOR;
/

-- 13. Utwórz w swoim schemacie kopię tabeli BIOGRAPHIES ze schematu ZTPD i przetestuj
-- swoją procedurę zastępując nazwisko „Cimrman” kropkami w biografii Jary Cimrmana.
CREATE TABLE BIOGRAPHIES_COPY AS SELECT * FROM ZTPD.BIOGRAPHIES;
/
SELECT * FROM BIOGRAPHIES_COPY;
/
DECLARE
    vclob CLOB;
BEGIN
    SELECT BIO INTO vclob FROM BIOGRAPHIES_COPY WHERE ID = 1 FOR UPDATE;
    CLOB_CENSOR(vclob, 'Cimrman');
    COMMIT;
END;
/
SELECT * FROM BIOGRAPHIES_COPY;
/
-- 14. Usuń kopię tabeli BIOGRAPHIES ze swojego schematu
DROP TABLE BIOGRAPHIES_COPY;