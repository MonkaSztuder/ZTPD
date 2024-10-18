-- 1A. Utwórz tabelę A6_LRS posiadającą jedną kolumnę GEOM typu SDO_GEOMETRY.

create table A6_LRS
(
  GEOM SDO_GEOMETRY
);

-- 1B. Skopiuj do tabeli A6_LRS obiekt przestrzenny z tabeli STREETS_AND_RAILROADS
-- znajdujący się w odległości nie większej niż 10 km od Koszalina.

insert into A6_LRS
select SR.GEOM
    from STREETS_AND_RAILROADS SR, MAJOR_CITIES MC
    where SDO_RELATE(SR.GEOM, SDO_GEOM.SDO_BUFFER(MC.GEOM, 10, 1, 'unit=km'),'MASK=ANYINTERACT') = 'TRUE'
    and MC.CITY_NAME = 'Koszalin';

-- 1C. Sprawdź długość oraz liczbę punktów, na który składa się skopiowany odcinek –
-- planowany przebieg autostrady A6.
select SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km') DISTANCE, ST_LINESTRING(GEOM).ST_NUMPOINTS() ST_NUMPOINTS
    from A6_LRS;

-- 1D. Dokonaj konwersji obiektu przestrzennego uzupełniając go o miary punktów
-- wchodzących w skład obiektu z przedziału od 0 do wartości będącej długością
-- skopiowanego odcinka.
update A6_LRS SR
set SR.GEOM = SDO_LRS.CONVERT_TO_LRS_GEOM(SR.GEOM, 0, SDO_GEOM.SDO_LENGTH(SR.GEOM, 1, 'unit=km'));

-- 1E. Zarejestruj metadane dotyczące tabeli A6_LRS.
insert into USER_SDO_GEOM_METADATA
    values ('A6_LRS','GEOM',MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
    MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
    MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1) ), 8307);

-- 1F. Utwórz indeks przestrzenny na tabeli A6_LRS.
create index lrs_routes_idx on A6_LRS(GEOM) indextype is MDSYS.SPATIAL_INDEX;

select SDO_LRS.VALID_MEASURE(GEOM, 1000) VALID_1000,
 SDO_LRS.GEOM_SEGMENT_LENGTH(GEOM) LENGTH,
 SDO_LRS.GEOM_SEGMENT_START_MEASURE(GEOM) START_MEASURE,
 SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
from A6_LRS;

-- 2A. Sprawdź czy miara o wartości 500 jest prawidłową miarą dla utworzonego
-- segmentu LRS.
select SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
    from A6_LRS;

-- 2B. Sprawdź jaki punkt jest punktem kończącym segment LRS. 
select SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
    from A6_LRS;

-- 2C. Wyznacz punkt, w którym kończy się 150-ty kilometr autostrady A6.
select SDO_LRS.LOCATE_PT(GEOM, 150, 0) KM150
    from A6_LRS;

-- 2D. Wyznacz ciąg linii będący fragmentem autostrady A6 od jej 120 kilometra do 160
-- kilometra.
select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) CLIPED 
    from A6_LRS;

-- 2E. Zakładając, że punkty definiujące autostradę A6 są jej wjazdami znajdź
-- współrzędne wjazdu położonego najbliżej od Słupska, przy założeniu, że kierowca
-- udaje się do Szczecina.
select SDO_LRS.GET_NEXT_SHAPE_PT(A6.GEOM, SDO_LRS.PROJECT_PT(A6.GEOM, C.GEOM)) WJAZD_NA_A6
    from A6_LRS A6, MAJOR_CITIES C 
    where C.CITY_NAME = 'Slupsk';

-- 2F. Gdyby chcieć zbudować gazociąg biegnący po lewej stronie autostrady A6
-- w odległości 50 metrów od niej, ciągnący się od 50-tego do 200-nego jej
-- kilometra, to jaki byłby koszt jego budowy? Przyjmij, że koszt budowy gazociągu
-- to 1mln/km.
select SDO_GEOM.SDO_LENGTH(SDO_LRS.OFFSET_GEOM_SEGMENT(A6.GEOM, M.DIMINFO, 50, 200, 50, 'unit=m'), 1, 'unit=km') KOSZT
    from A6_LRS A6, USER_SDO_GEOM_METADATA M
    where M.TABLE_NAME = 'A6_LRS' and M.COLUMN_NAME = 'GEOM';