-- 1. Utwórz w swoim schemacie kopię tabeli CYTATY ze schematu ZTPD.
create table CYTATY_COPY as
select * from ZTPD.CYTATY;

select * from cytaty_copy;

-- 2. Znajdź w tabeli CYTATY za pomocą standardowego operatora LIKE cytaty, które
-- zawierają zarówno słowo ‘optymista’ jak i ‘pesymista’ ignorując wielkość liter.
select * from cytaty_copy
where lower(tekst) like '%optymista%' and lower(tekst) like '%pesymista%';

-- 3. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEKST tabeli CYTATY przy
-- domyślnych preferencjach dla tworzonego indeksu
create index cytaty_copy_ctx on cytaty_copy(tekst) indextype is ctxsys.context;

-- 4. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- zarówno słowo ‘optymista’ jak i ‘pesymista’ (ignorując wielkość liter w tym i kolejnych
-- zapytaniach ze względu na charakterystykę indeksu).

select * from CYTATY_COPY
where contains(cytaty_copy.TEKST, 'optymista and pesymista', 1) > 0;

-- 5. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
-- ‘pesymista’, a nie zawierają słowa ‘optymista’.
select * from CYTATY_COPY
where contains(cytaty_copy.TEKST, 'pesymista not optymista', 1) > 0;

-- 6. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowa
-- ‘optymista’ i ‘pesymista’ w odległości maksymalnie 3 słów
select * from CYTATY_COPY
where contains(cytaty_copy.TEKST,'near((optymista, pesymista), 3)')>0;

-- 7. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowa
-- ‘optymista’ i ‘pesymista’ w odległości maksymalnie 10 słów.
select * from CYTATY_COPY
where contains(cytaty_copy.TEKST,'near((optymista, pesymista), 10)')>0;

-- 8. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
-- ‘życie’ i jego odmiany. Niestety Oracle nie wspiera stemmingu dla języka polskiego. Dlatego
-- zamiast frazy ‘$życie’ „poratujemy się” szukaniem frazy ‘życi%’.
select * from CYTATY_COPY
where contains(cytaty_copy.TEKST,'życi%')>0;

-- 9. Zmodyfikuj poprzednie zapytanie, tak by dla każdego pasującego cytatu wyświetlony
-- został stopień dopasowania (SCORE).
select autor,tekst, score(1) as stopien_dopasowania
from CYTATY_COPY
where contains(cytaty_copy.TEKST,'życi%',1)>0;

-- 10. Zmodyfikuj poprzednie zapytanie, tak by wyświetlony został tylko najlepiej pasujący
-- cytat (w przypadku „remisu” może zostać wyświetlony dowolny z najlepiej pasujących
-- cytatów).
select autor,tekst, score(1) as stopien_dopasowania
from CYTATY_COPY
where contains(cytaty_copy.TEKST,'życi%',1)>0
order by score(1) desc
fetch first 1 row only;

-- 11. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- słowo ‘problem’ za pomocą wzorca z „literówką”: ‘probelm’.
select * from CYTATY_COPY
where contains(cytaty_copy.TEKST,'fuzzy(probelm)',1)>0;

-- 12. Wstaw do tabeli CYTATY cytat Bertranda Russella 'To smutne, że głupcy są tacy pewni
-- siebie, a ludzie rozsądni tacy pełni wątpliwości.'. Zatwierdź transakcję.
-- select COUNT(*) from CYTATY_COPY;
insert into CYTATY_COPY values (39,'Bertrand Russell','To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
COMMIT;

-- 13. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- słowo ‘głupcy’. Jak wyjaśnisz wynik zapytania?
select * from CYTATY_COPY
where contains(cytaty_copy.TEKST,'głupcy')>0;
-- Nie ma w indeksie

-- 14. Odszukaj w swoim schemacie tabelę, która zawiera zawartość indeksu odwróconego na
-- tabeli CYTATY. Wyświetl jej zawartość zwracając uwagę na to, czy słowo ‘głupcy’ znajduje
-- się wśród poindeksowanych słów.
select * from DR$cytaty_copy_ctx$i;

-- 15. Indeks CONTEXT utworzony przy domyślnych preferencjach nie jest uaktualniany na
-- bieżąco. Możliwa jest synchronizacja na żądanie (poprzez procedurę) lub zgodnie z zadaną
-- polityką (poprzez preferencję ustawioną przy tworzeniu indeksu: po zatwierdzeniu transakcji,
-- z zadanym interwałem czasowym). Można też przebudować indeks usuwając go i tworząc
-- ponownie. Wadą tej opcji jest czas trwania operacji i czasowa niedostępność indeksu, ale z tej
-- opcji skorzystamy ze względu na jej prostotę.
drop index cytaty_copy_ctx;

create index cytaty_copy_ctx on cytaty_copy(tekst) indextype is ctxsys.context;

-- 16. Sprawdź czy po przebudowaniu indeksu słowo ‘głupcy’ pojawiło się w indeksie
-- odwróconym, a następnie powtórz zapytanie z punktu 13. 
select * from DR$cytaty_copy_ctx$i;

select * from CYTATY_COPY
where contains(cytaty_copy.TEKST,'głupcy')>0;

-- 17. Usuń indeks na tabeli CYTATY, a następnie samą tabelę CYTATY.
drop index cytaty_copy_ctx;

drop table CYTATY_COPY;

-- Zaawansowane indeksowanie i wyszukiwanie
-- 1. Utwórz w swoim schemacie kopię tabeli QUOTES ze schematu ZTPD
-- select * from ZTPD.QUOTES;
create table QUOTES_COPY as select * from ZTPD.QUOTES;

select * from QUOTES_COPY;

-- 2. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEXT tabeli QUOTES przy
-- domyślnych preferencjach
create index quotes_copy_ctx on quotes_copy(text) indextype is ctxsys.context;

-- 3. Tabela QUOTES zawiera teksty w języku angielskim, dla którego Oracle Text obsługuje
-- stemming. Sprawdź działanie operatora CONTAINS dla wzorców:
-- - ‘work’
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'work')>0;
-- - ‘$work’
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'$work')>0;
-- - ‘working’
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'working')>0;
-- - ‘$working’
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'$working')>0;

-- 4. Spróbuj znaleźć w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘it’. Czy
-- system zwrócił jakieś wyniki? Dlaczego?
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'it')>0;
-- nic nie zwrócił, ponieważ 'it' jest słowem stop?

-- 5. Sprawdź jakie stop listy dostępne są w systemie. Odpytaj w tym celu perspektywę
-- słownikową CTX_STOPLISTS. Jak myślisz, którą system wykorzystywał przy
-- dotychczasowych zapytaniach?
 select * from CTX_STOPLISTS;
--  Pewnie DEFAULT_STOPLIST

-- 6. Sprawdź jakie słowa znajdują się na domyślnej stop liście. Odpytaj w tym celu
-- perspektywę słownikową CTX_STOPWORDS. 
select * from CTX_STOPWORDS;

-- 7. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz go ponownie wskazując, że przy
-- indeksowaniu ma być użyta dostępna w systemie pusta stop lista.
drop index quotes_copy_ctx;

create index quotes_copy_ctx on quotes_copy(text) indextype is ctxsys.context 
parameters ('stoplist CTXSYS.EMPTY_STOPLIST');

-- 8. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘it’. Czy tym razem system
-- zwrócił jakieś wyniki?
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'it')>0;

-- 9. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’.
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'fool and humans')>0;

-- 10. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘computer’.
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'fool and computer')>0;

-- 11. Spróbuj znaleźć w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’ w jednym
-- zdaniu. Zinterpretuj komunikat o błędzie.
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'near(fool, humans)')>0;

-- 12. Usuń indeks pełnotekstowy na tabeli QUOTES.
drop index quotes_copy_ctx;

-- 13. Utwórz grupę sekcji bazującą na NULL_SECTION_GROUP, zawierającą dodatkowo
-- obsługę zdań i akapitów jako sekcji.
begin
    ctx_ddl.create_section_group('nullgroup2', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup2', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup2', 'PARAGRAPH');
end;
/

-- 14. Utwórz ponownie indeks pełnotekstowy na tabeli QUOTES wskazując utworzoną grupę
-- sekcji obsługującą zdania i akapity
drop index quotes_copy_ctx;

create index quotes_copy_ctx on quotes_copy(text) indextype is ctxsys.context
parameters ('stoplist CTXSYS.EMPTY_STOPLIST section group nullgroup2');

-- 15. Sprawdź czy teraz działają wzorce odwołujące się do zdań szukając najpierw cytatów
-- zawierających w tym samym zdaniu słowa ‘fool’ i ‘humans’, a następnie ‘fool’ i ‘computer’.

select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'fool and humans',1)>0;

select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'fool and computer',1)>0;

-- 16. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘humans’. Czy system
-- zwrócił też cytaty zawierające ‘non-humans’? Dlaczego?
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'humans')>0;
-- tak, teraz szuka tylko humans

-- 17. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz preferencję dla leksera (używając
-- BASIC_LEXER), wskazującą, że myślnik ma być traktowany jako część indeksowanych
-- tokenów (składnik słów tak jak litery). Utwórz ponownie indeks pełnotekstowy na tabeli
-- QUOTES wskazując utworzoną preferencję dla leksera
drop index quotes_copy_ctx;

begin
 ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
 ctx_ddl.set_attribute('lex_z_m','printjoins', '_-');
 ctx_ddl.set_attribute ('lex_z_m','index_text', 'YES');
end;
/

create index quotes_copy_ctx on quotes_copy(text) indextype is ctxsys.context
parameters('stoplist CTXSYS.EMPTY_STOPLIST section group nullgroup2 lexer lex_z_m');
-- 18. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘humans’. Czy system tym
-- razem zwrócił też cytaty zawierające ‘non-humans’?
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'humans')>0;
-- bez non-humans

-- 19. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają frazę ‘non-humans’.
-- Wskazówka: myślnik we wzorcu należy „escape’ować” („skorzystać z sekwencji ucieczki”).
select * from QUOTES_COPY
where contains(quotes_copy.TEXT,'non\-humans')>0;

-- 20. Usuń swoją kopię tabeli QUOTES i utworzoną preferencję
drop index quotes_copy_ctx;

drop table QUOTES_COPY;