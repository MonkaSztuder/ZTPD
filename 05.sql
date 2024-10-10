-- 1A. W ramach poprzednich ćwiczeń stworzona została tabela FIGURY. Zawiera ona kolumnę
-- przestrzenną – warstwę mapy przestrzennej
-- Zarejestruj stworzoną przez Ciebie warstwę w słowniku bazy danych (metadanych). Domyślna
-- tolerancja niechaj wynosi 0.01.

select * from figury;
/
INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
'FIGURY',
'KSZTALT',
MDSYS.SDO_DIM_ARRAY(
	MDSYS.SDO_DIM_ELEMENT('X', 0, 9, 0.01),
	MDSYS.SDO_DIM_ELEMENT('Y', 0, 9, 0.01) ),
	NULL
);
/
-- 1B. Dokonaj estymacji rozmiaru indeksu R-drzewo dla stworzonej przez Ciebie tabeli FIGURY.
-- 3000000,8192,10,2,0
select MDSYS.SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2,0) from DUAL;
/
-- 1C. Utwórz indeks R-drzewo na utworzonej przez Ciebie tabeli.
create INDEX figury_idx ON figury(ksztalt) INDEXTYPE is MDSYS.SPATIAL_INDEX_V2;

-- 1D. Sprawdź za pomocą operatora SDO_FILTER, które z utworzonych geometrii "mają coś
-- wspólnego" z punktem 3,3.

select ID
from FIGURY
where SDO_FILTER(KSZTALT,
	SDO_GEOMETRY(2001,null,
	SDO_POINT_TYPE(3,3,null),
	null,null)) = 'TRUE';

-- 1E. Sprawdź za pomocą operatora SDO_RELATE, które z utworzonych geometrii "mają coś
-- wspólnego" (nie są rozłączne) z punktem 3,3.

select ID
from FIGURY
where SDO_RELATE(KSZTALT,
	SDO_GEOMETRY(2001,null,
	SDO_POINT_TYPE(3,3,null),
	null,null),
	'mask=ANYINTERACT') = 'TRUE';

-- 2A. Wykorzystując operator SDO_NN i funkcję SDO_NN_DISTANCE znajdź dziewięć najbliższych
-- miast wraz z odległościami od Warszawy.

-- • COUNTRY_BOUNDARIES – granice państw,
-- • RIVERS – rzeki,
-- • MAJOR_CITIES – główne miasta,
-- • WATER_BODIES – śródlądowe obszary wodne,
-- • STREETS_AND_RAILROADS – drogi.

select * from MAJOR_CITIES where city_name='Warsaw';
/
select 
	MC.CITY_NAME as Miasto , 
	ROUND(SDO_NN_DISTANCE(1),7) as Odl 
	from MAJOR_CITIES MC
  where SDO_NN( GEOM, (select MCW.GEOM from MAJOR_CITIES MCW where MCW.CITY_NAME='Warsaw'), 
	'sdo_num_res=10', 1) = 'TRUE' and MC.CITY_NAME != 'Warsaw';

-- 2B. Sprawdź, które miasta znajdują się w odległości 100 km od Warszawy. Skorzystaj z operatora
-- SDO_WITHIN_DISTANCE. Wynik porównaj z wynikiem z zadania powyżej.
select 
	MC.CITY_NAME as Miasto 
	from MAJOR_CITIES MC
	where SDO_WITHIN_DISTANCE( GEOM,( select MCW.GEOM from MAJOR_CITIES MCW where MCW.CITY_NAME='Warsaw'),
	'distance=100 unit=km') = 'TRUE'and MC.CITY_NAME != 'Warsaw';

-- 2C. Wyświetl miasta ze Słowacji. Skorzystaj z operatora SDO_RELATE.

select 
	MC.CNTRY_NAME as Kraj ,MC.CITY_NAME as Miasto 
	from MAJOR_CITIES MC
	where SDO_RELATE(GEOM, (select GEOM from COUNTRY_BOUNDARIES where CNTRY_NAME='Slovakia'), 'mask=INSIDE') = 'TRUE';

-- 2D. Znajdź odległości pomiędzy Polską a krajami, które z nią nie graniczą. Wykorzystaj operator
-- SDO_RELATE oraz funkcję SDO_DISTANCE.

select CB.CNTRY_NAME as Kraj,
 	ROUND(SDO_GEOM.SDO_DISTANCE(CBP.GEOM, CB.GEOM, 1, 'unit=km'),7) ODL
	from COUNTRY_BOUNDARIES CBP, COUNTRY_BOUNDARIES CB
	where CBP.CNTRY_NAME = 'Poland'
	and SDO_RELATE(CBP.GEOM, CB.GEOM, 'mask=anyinteract') <> 'TRUE';

-- 3A. Znajdź sąsiadów Polski oraz odczytaj długość granicy z każdym z nich.

select CB.CNTRY_NAME as Kraj,
 	ROUND(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(CBP.GEOM, CB.GEOM, 1), 1, 'unit=km'),7) ODL
	from COUNTRY_BOUNDARIES CBP, COUNTRY_BOUNDARIES CB
	where CBP.CNTRY_NAME = 'Poland'
	and SDO_RELATE(CBP.GEOM, CB.GEOM, 'mask=touch') = 'TRUE';

-- 3B. Podaj nazwę Państwa, którego fragment przechowywany w bazie danych jest największy.

select CB.CNTRY_NAME,
 ROUND(SDO_GEOM.sdo_area(CB.GEOM, 1, 'unit=SQ_KM')) POWIERZCHNIA
from COUNTRY_BOUNDARIES CB
order by 2 desc
fetch first 1 row only;

-- 3C. Wyznacz pole minimalnego ograniczającego prostokąta (MBR), w którym znajdują się Warszawa
-- i Łódź.

select 
ROUND( 
	SDO_GEOM.SDO_AREA(
		SDO_GEOM.SDO_MBR(
				SDO_GEOM.SDO_UNION(MCW.GEOM,MCL.GEOM,0.01)),1, 'unit=SQ_KM'),5) as km
	from MAJOR_CITIES MCW, MAJOR_CITIES MCL 
	where MCW.CITY_NAME ='Warsaw' and MCL.CITY_NAME ='Lodz';

-- 3D. Jakiego typu geometria będzie sumą geometryczną państwa polskiego i Pragi. Wykorzystaj
-- odpowiednią metodę typu SDO_GEOMETRY.

select 
	SDO_GEOM.SDO_UNION(	(CB.GEOM),(MC.GEOM),0.01).GET_DIMS()
	|| SDO_GEOM.SDO_UNION(	(CB.GEOM),(MC.GEOM),0.01).GET_LRS_DIM()
	|| LPAD(SDO_GEOM.SDO_UNION(	(CB.GEOM),(MC.GEOM),0.01).GET_GTYPE(), 2, '0') as GTYPE
	from COUNTRY_BOUNDARIES CB, MAJOR_CITIES MC
	where CB.CNTRY_NAME='Poland' and MC.CITY_NAME='Prague';

-- 3E. Znajdź nazwę miasta, które znajduje się najbliżej centrum ciężkości swojego państwa.

select MC.CITY_NAME, CB.CNTRY_NAME
	from MAJOR_CITIES MC, COUNTRY_BOUNDARIES CB
	where MC.CNTRY_NAME = CB.CNTRY_NAME
	order by ROUND(SDO_GEOM.SDO_DISTANCE(
		SDO_GEOM.SDO_CENTROID(CB.GEOM,0.01), 
		MC.GEOM),7) 
	fetch first 1 row only;

-- 3F. Podaj długość tych z rzek, które przepływają przez terytorium Polski. Ogranicz swoje obliczenia
-- tylko do tych fragmentów, które leżą na terytorium Polski.

select rzeki.rzeka , sum(rzeki.dl) as dlugosc
	from 
	(select R.NAME as Rzeka, 
	ROUND(SDO_GEOM.SDO_LENGTH(
		SDO_GEOM.SDO_INTERSECTION(R.GEOM, CB.GEOM, 1), 1, 'unit=km'),7) as dl
	from RIVERS R, COUNTRY_BOUNDARIES CB
	where SDO_RELATE(R.GEOM, CB.GEOM, 'mask=ANYINTERACT') = 'TRUE' 
		and CB.CNTRY_NAME='Poland') rzeki
	group by rzeki.Rzeka;
