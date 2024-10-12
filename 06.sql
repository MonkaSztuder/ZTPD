-- 1A. Wykorzystując klauzulę CONNECT BY wyświetl hierarchię typu ST_GEOMETRY.

select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
    from all_types t
    start with t.type_name = 'ST_GEOMETRY'
    connect by prior t.type_name = t.supertype_name
    and prior t.owner = t.owner;

-- 1B. Wyświetl nazwy metod typu ST_POLYGON.
select distinct m.method_name
    from all_type_methods m
    where m.type_name like 'ST_POLYGON'
    and m.owner = 'MDSYS'
    order by 1;

-- C. Utwórz tabelę MYST_MAJOR_CITIES o następujących kolumnach:
-- • FIPS_CNTRY VARCHAR2(2),
-- • CITY_NAME VARCHAR2(40),
-- • STGEOM ST_POINT.

create table MYST_MAJOR_CITIES
(
  FIPS_CNTRY VARCHAR2(2),
  CITY_NAME VARCHAR2(40),
  STGEOM ST_POINT
);

-- 1D. Przepisz zawartość tabeli MAJOR_CITIES (znajduje się ona w schemacie ZTPD) do
-- stworzonej przez Ciebie tabeli MYST_MAJOR_CITIES dokonując odpowiedniej
-- konwersji typów.

insert into MYST_MAJOR_CITIES
    select C.FIPS_CNTRY, C.CITY_NAME, TREAT(ST_POINT.FROM_SDO_GEOM(C.GEOM) AS ST_POINT) STGEOM
    from MAJOR_CITIES C;

-- 2A. Wstaw do tabeli MYST_MAJOR_CITIES informację dotyczącą Szczyrku. Załóż, że
-- centrum Szczyrku znajduje się w punkcie o współrzędnych 19.036107;
-- 49.718655. Wykorzystaj 3-argumentowy konstruktor ST_POINT (ostatnim
-- argumentem jest identyfikator układu współrzędnych).

insert into MYST_MAJOR_CITIES
    values ('PL', 'Szczyrk', ST_POINT(19.036107, 49.718655, 8307));

-- 3A. Utwórz tabelę MYST_COUNTRY_BOUNDARIES z następującymi atrybutami
-- • FIPS_CNTRY VARCHAR2(2),
-- • CNTRY_NAME VARCHAR2(40),
-- • STGEOM ST_MULTIPOLYGON.

create table MYST_COUNTRY_BOUNDARIES
(
  FIPS_CNTRY VARCHAR2(2),
  CNTRY_NAME VARCHAR2(40),
  STGEOM ST_MULTIPOLYGON
);

-- 3B. Przepisz zawartość tabeli COUNTRY_BOUNDARIES do nowo utworzonej tabeli
-- dokonując odpowiednich konwersji.

insert into MYST_COUNTRY_BOUNDARIES
    select CB.FIPS_CNTRY, CB.CNTRY_NAME, ST_MULTIPOLYGON(CB.GEOM)
    from COUNTRY_BOUNDARIES CB;

-- 3C. Sprawdź jakiego typu i ile obiektów przestrzennych zostało umieszczonych
-- w tabeli MYST_COUNTRY_BOUNDARIES.
select CB.STGEOM.ST_GEOMETRYTYPE() as typobiektu, count(*) as ile
    from MYST_COUNTRY_BOUNDARIES CB
    group by CB.STGEOM.ST_GEOMETRYTYPE();

-- 3D. Sprawdź czy wszystkie definicje przestrzenne uznawane są za proste.

select CB.STGEOM.ST_ISSIMPLE()
    from MYST_COUNTRY_BOUNDARIES CB;

-- 4A. Sprawdź ile miejscowości (MYST_MAJOR_CITIES) zawiera się w danym państwie
-- (MYST_COUNTRY_BOUNDARIES).

select CB.CNTRY_NAME, count(*)
    from MYST_COUNTRY_BOUNDARIES CB, MYST_MAJOR_CITIES MC
    where CB.STGEOM.ST_CONTAINS(MC.STGEOM) = 1
    group by CB.CNTRY_NAME;

-- 4B. Znajdź te państwa, które graniczą z Czechami.
select CB.CNTRY_NAME A_NAME, CBCR.CNTRY_NAME B_NAME
    from MYST_COUNTRY_BOUNDARIES CB, MYST_COUNTRY_BOUNDARIES CBCR
    where CB.STGEOM.ST_TOUCHES(CBCR.STGEOM) = 1
    and CBCR.CNTRY_NAME = 'Czech Republic';

-- 4C. Znajdź nazwy tych rzek, które przecinają granicę Czech – wykorzystaj tabelę
-- RIVERS (z racji korzystania z implementacji SQL/MM w Oracle konieczne jest
-- wykorzystanie także konstruktora typu ST_LINESTRING).
select distinct CB.CNTRY_NAME, R.name
    from MYST_COUNTRY_BOUNDARIES CB, RIVERS R
    where CB.CNTRY_NAME = 'Czech Republic'
    and ST_LINESTRING(R.GEOM).ST_INTERSECTS(CB.STGEOM) = 1;

-- 4D. Sprawdź, jaka powierzchnia jest Czech i Słowacji połączonych w jeden obiekt
-- przestrzenny

select  TREAT(CBCR.STGEOM.ST_UNION(CBS.STGEOM) as ST_POLYGON).ST_AREA() as poweirzchnia
    from MYST_COUNTRY_BOUNDARIES CBCR, MYST_COUNTRY_BOUNDARIES CBS
    where CBCR.CNTRY_NAME = 'Czech Republic'
    and CBS.CNTRY_NAME = 'Slovakia';

-- 4E. Sprawdź jakiego typu obiektem są Węgry z "wykrojonym" Balatonem –
-- wykorzystaj tabelę WATER_BODIES. 

select CB.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(WB.GEOM)).ST_GEOMETRYTYPE() WEGRY_BEZ
    from MYST_COUNTRY_BOUNDARIES CB, WATER_BODIES WB
    where CB.CNTRY_NAME = 'Hungary'
    and WB.name = 'Balaton';

-- A. Wykorzystując operator SDO_WITHIN_DISTANCE znajdź liczbę miejscowości
-- oddalonych od terytorium Polski nie więcej niż 100 km. (wykorzystaj tabele
-- MYST_MAJOR_CITIES i MYST_COUNTRY_BOUNDARIES). Obejrzyj plan wykonania
-- zapytania.

select CB.CNTRY_NAME A_NAME, count(*)
    from MYST_COUNTRY_BOUNDARIES CB, MYST_MAJOR_CITIES MC
    where SDO_WITHIN_DISTANCE(MC.STGEOM, CB.STGEOM,'distance=100 unit=km') = 'TRUE'
    and CB.CNTRY_NAME = 'Poland'
    group by CB.CNTRY_NAME;

-- B. Zarejestruj metadane dotyczące stworzonych przez Ciebie tabeli
-- MYST_MAJOR_CITIES i/lub MYST_COUNTRY_BOUNDARIES.

insert into USER_SDO_GEOM_METADATA
    select 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID
    from ALL_SDO_GEOM_METADATA T
    where T.TABLE_NAME = 'MAJOR_CITIES';

-- C. Utwórz na tabelach MYST_MAJOR_CITIES i/lub MYST_COUNTRY_BOUNDARIES
-- indeks R-drzewo.
create index MYST_MAJOR_CITIES_IDX on MYST_MAJOR_CITIES(STGEOM)
    indextype IS MDSYS.SPATIAL_INDEX;

-- D. Ponownie znajdź liczbę miejscowości oddalonych od terytorium Polski nie więcej
-- niż 100 km. Sprawdź jednocześnie, czy założone przez Ciebie indeksy są
-- wykorzystywane wyświetlając plan wykonania zapytania.

explain plan for
select CB.CNTRY_NAME A_NAME, count(*)
    from MYST_COUNTRY_BOUNDARIES CB, MYST_MAJOR_CITIES MC
    where SDO_WITHIN_DISTANCE(MC.STGEOM, CB.STGEOM,'distance=100 unit=km') = 'TRUE'
    and CB.CNTRY_NAME = 'Poland'
    group by CB.CNTRY_NAME;

select * from table(dbms_xplan.display);