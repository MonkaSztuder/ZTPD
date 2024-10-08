-- 1.Zdefiniuj typ obiektowy reprezentujący SAMOCHODY. Każdy samochód powinien mieć markę, model, liczbę kilometrów oraz datę produkcji i cenę. Stwórz tablicę obiektową i wprowadź kilka przykładowych obiektów, obejrzyj zawartość tablicy
CREATE TYPE Samochod AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2)
);
/
CREATE TABLE Samochody OF Samochod;

INSERT INTO Samochody VALUES ('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000);
INSERT INTO Samochody VALUES ('FORD', 'MONDEO', 80000, TO_DATE('10-05-1997', 'DD-MM-YYYY'), 45000);
INSERT INTO Samochody VALUES ('MAZDA', '323', 12000, TO_DATE('22-09-2000', 'DD-MM-YYYY'), 52000);

select * from samochody;
/
-- 2.Stwórz tablicę WLASCICIELE zawierającą imiona i nazwiska właścicieli oraz atrybut obiektowy SAMOCHOD. Wprowadź do tabeli przykładowe dane i wyświetl jej zawartość.
CREATE TABLE WLASCICIELE (
    IMIE VARCHAR2(100),
    NAZWISKO VARCHAR2(100),
    AUTO Samochod
)

/
desc WLASCICIELE
/
INSERT INTO WLASCICIELE VALUES ('Jan', 'Kowalski', NEW Samochod('FIAT', 'SEICENTO', 30000, TO_DATE('02-12-0010', 'DD-MM-YYYY'), 19500));
INSERT INTO WLASCICIELE VALUES ('Adam', 'Nowak', NEW Samochod('OPEL', 'ASTRA', 34000, TO_DATE('01-06-0009', 'DD-MM-YYYY'), 33700));
/
SELECT * FROM WLASCICIELE;
/
SELECT imie, nazwisko, w.auto.marka, w.auto.model, w.auto.KILOMETRY, w.auto.DATA_PRODUKCJI, w.auto.CENA
    FROM wlasciciele w;
    /

-- 3.Wartość samochodu maleje o 10% z każdym rokiem. Dodaj do typu obiektowego SAMOCHOD metodę wyliczającą aktualną wartość samochodu na podstawie wieku.
ALTER TYPE Samochod ADD MEMBER FUNCTION AktualnaWartosc RETURN NUMBER CASCADE INCLUDING TABLE DATA; 

CREATE OR REPLACE TYPE BODY Samochod AS
    MEMBER FUNCTION AktualnaWartosc RETURN NUMBER IS
    BEGIN
        RETURN POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI)) * CENA;
    END AktualnaWartosc;
END;
/

select s.marka,s.cena,s.AktualnaWartosc() from samochody s;

-- 4.Dodaj do typu SAMOCHOD metodę odwzorowującą, która pozwoli na porównywanie samochodów na podstawie ich wieku i zużycia. Przyjmij, że 10000 km odpowiada jednemu rokowi wieku samochodu.
 ALTER TYPE Samochod ADD MAP MEMBER FUNCTION Wiek RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY Samochod AS 
    MEMBER FUNCTION AktualnaWartosc RETURN NUMBER IS
    BEGIN
        RETURN POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI)) * CENA;
    END;

    MAP MEMBER FUNCTION Wiek RETURN NUMBER IS
    BEGIN
        RETURN ROUND(KILOMETRY/10000)+(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI));
    END Wiek;
END;
 /
 
SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

 /

-- 5. Stwórz typ WLASCICIEL zawierający imię i nazwisko właściciela samochodu, dodaj do typu SAMOCHOD referencje do właściciela. Wypełnij tabelę przykładowymi danymi.

CREATE OR REPLACE TYPE wlasciciel AS OBJECT(
    IMIE varchar2(20),
    NAZWISKO varchar2(20)
);
/
ALTER TYPE samochod ADD ATTRIBUTE posiadacz REF wlasciciel CASCADE;
/
CREATE TABLE wlascicieleREF OF wlasciciel;
/
INSERT INTO wlascicieleREF VALUES (New wlasciciel('Jan', 'Kowalski'));
INSERT INTO wlascicieleREF VALUES (New wlasciciel('Adam', 'Nowak'));
/
select * from wlascicieleREF;
/
UPDATE samochody s SET s.posiadacz = (SELECT REF(w) FROM wlascicieleREF w WHERE w.imie = 'Jan' and w.nazwisko = 'Kowalski');
UPDATE samochody s SET s.posiadacz = (SELECT REF(w) FROM wlascicieleREF w WHERE w.imie = 'Adam' and w.nazwisko = 'Nowak') WHERE s.marka = 'MAZDA';
/
select s.marka,s.posiadacz.imie from samochody s;
/
-- 6. Zbuduj kolekcję (tablicę o zmiennym rozmiarze) zawierającą informacje o przedmiotach (łańcuchy znaków). Wstaw do kolekcji przykładowe przedmioty, rozszerz kolekcję, wyświetl zawartość kolekcji, usuń elementy z końca kolekcji
DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
 moje_przedmioty(1) := 'MATEMATYKA';
 moje_przedmioty.EXTEND(9);
 FOR i IN 2..10 LOOP
    moje_przedmioty(i) := 'PRZEDMIOT_' || i;
 END LOOP;
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
    DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 moje_przedmioty.TRIM(2);
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
    DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.EXTEND();
 moje_przedmioty(9) := 9;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.DELETE();
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;
/
-- 7.Zdefiniuj kolekcję (w oparciu o tablicę o zmiennym rozmiarze) zawierającą listę tytułów książek. Wykonaj na kolekcji kilka czynności (rozszerz, usuń jakiś element, wstaw nową książkę).
DECLARE 
TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    ksiazki(1) := 'Ksiazka1';
    ksiazki.EXTEND(9);
    FOR i IN 2..10 LOOP
        ksiazki(i) := 'Ksiazka_' || i;
    END LOOP;
    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;
    ksiazki.TRIM(2);
    FOR i IN ksiazki.FIRST()..ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(ksiazki(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || ksiazki.COUNT());
    ksiazki.EXTEND();
    ksiazki(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || ksiazki.COUNT());
    ksiazki.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || ksiazki.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || ksiazki.COUNT());
END;
/
-- 8. Zbuduj kolekcję (tablicę zagnieżdżoną) zawierającą informacje o wykładowcach. Przetestuj działanie kolekcji podobnie jak w przykładzie 6.
DECLARE
 TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
 moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
 moi_wykladowcy.EXTEND(2);
 moi_wykladowcy(1) := 'MORZY';
 moi_wykladowcy(2) := 'WOJCIECHOWSKI';
 moi_wykladowcy.EXTEND(8);
 FOR i IN 3..10 LOOP
 moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
 END LOOP;
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.TRIM(2);
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.DELETE(5,7);
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 moi_wykladowcy(5) := 'ZAKRZEWICZ';
 moi_wykladowcy(6) := 'KROLIKOWSKI';
 moi_wykladowcy(7) := 'KOSZLAJDA';
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;
/
-- 9.Zbuduj kolekcję (w oparciu o tablicę zagnieżdżoną) zawierającą listę miesięcy. Wstaw do kolekcji właściwe dane, usuń parę miesięcy, wyświetl zawartość kolekcji.
DECLARE
 TYPE t_miesiace IS TABLE OF VARCHAR2(20);
 miesiace t_miesiace := t_miesiace();
BEGIN
miesiace.EXTEND(12);
miesiace(1) := 'STYCZEN';
miesiace(2) := 'LUTY';
miesiace(3) := 'MARZEC';
miesiace(4) := 'KWIECIEN';
miesiace(5) := 'MAJ';
miesiace(6) := 'CZERWIEC';
miesiace(7) := 'LIPIEC';
miesiace(8) := 'SIERPIEN';
miesiace(9) := 'WRZESIEN';
miesiace(10) := 'PAZDZIERNIK';
miesiace(11) := 'LISTOPAD';
miesiace(12) := 'GRUDZIEN';
FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(miesiace(i));
END LOOP;
DBMS_OUTPUT.PUT_LINE('-----------------');
miesiace.DELETE(10,12);
FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(miesiace(i));
END LOOP;
DBMS_OUTPUT.PUT_LINE('-----------------');
miesiace.TRIM(4);
FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
DBMS_OUTPUT.PUT_LINE(miesiace(i));
END LOOP;
END;
/
-- 10.. Sprawdź działanie obu rodzajów kolekcji w przypadku atrybutów bazodanowych.

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
 nazwa VARCHAR2(50),
 kraj VARCHAR2(30),
 jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
 numer NUMBER,
 egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';
/
-- 11. Zbuduj tabelę ZAKUPY zawierającą atrybut zbiorowy KOSZYK_PRODUKTOW w postaci tabeli zagnieżdżonej. Wstaw do tabeli przykładowe dane. Wyświetl zawartość tabeli, usuń wszystkie transakcje zawierające wybrany produkt
CREATE TYPE produkty IS TABLE OF VARCHAR2(20);
/
CREATE TYPE zakupy AS OBJECT (
    ID NUMBER,
    KOSZYK_PRODUKTOW produkty
)
/
CREATE TABLE ZAKUPYTAB OF zakupy
NESTED TABLE KOSZYK_PRODUKTOW STORE AS tab_produkty;
/   
INSERT INTO ZAKUPYTAB VALUES
(zakupy(1,produkty('MILKA','SNICKERS','TWIX')));
INSERT INTO ZAKUPYTAB VALUES
(zakupy(2,produkty('MILKA','SNICKERS','TWIX','MARS')));
INSERT INTO ZAKUPYTAB VALUES
(zakupy(3,produkty('MILKA','SNICKERS','TWIX','MARS','KITKAT')));
SELECT * FROM ZAKUPYTAB;
/
DELETE FROM ZAKUPYTAB z
WHERE EXISTS (SELECT * FROM TABLE(z.KOSZYK_PRODUKTOW) p
WHERE p.column_value = 'MARS');
/
SELECT * FROM ZAKUPYTAB;

-- 12. Zbuduj hierarchię reprezentującą instrumenty muzyczne.
CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
/
CREATE TYPE BODY instrument AS
 MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN dzwiek;
 END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
 material VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
 /
 CREATE OR REPLACE TYPE BODY instrument_dety AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'dmucham: '||dzwiek;
 END;
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
 RETURN glosnosc||':'||dzwiek;
 END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
 producent VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
 /
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'stukam w klawisze: '||dzwiek;
 END;
END;
/
DECLARE
 tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
 trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
 fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
 dbms_output.put_line(tamburyn.graj);
 dbms_output.put_line(trabka.graj);
 dbms_output.put_line(trabka.graj('glosno'));
 dbms_output.put_line(fortepian.graj);
END;
/
-- 13. Zbuduj hierarchię zwierząt i przetestuj klasy abstrakcyjne.
CREATE TYPE istota AS OBJECT (
 nazwa VARCHAR2(20),
 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
 NOT INSTANTIABLE NOT FINAL;
 /
CREATE TYPE lew UNDER istota (
 liczba_nog NUMBER,
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
 /
CREATE OR REPLACE TYPE BODY lew AS
 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
 BEGIN
 RETURN 'upolowana ofiara: '||ofiara;
 END;
END;
/
DECLARE
 KrolLew lew := lew('LEW',4);
--  InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
 DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;
/
-- 14. Zbadaj własność polimorfizmu na przykładzie hierarchii instrumentów.
DECLARE
 tamburyn instrument;
 cymbalki instrument;
 trabka instrument_dety;
 saksofon instrument_dety;
BEGIN
 tamburyn := instrument('tamburyn','brzdek-brzdek');
 cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
 trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
--  saksofon := instrument('saksofon','tra-taaaa');
--  saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;
/
-- 15. Zbuduj tabelę zawierającą różne instrumenty. Zbadaj działanie funkcji wirtualnych.
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
);
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;