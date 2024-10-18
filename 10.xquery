(:5
doc("db/bib/bib.xml")//bib/book/author/last:)

(:6
for $z in doc("db/bib/bib.xml")//bib/book
let $titles := $z/title
let $authors := $z/author
for $t in $titles
for $a in $authors
return
<ksiazka>
  {$a}
  {$t}
</ksiazka>:)

(:7
for $z in doc("db/bib/bib.xml")//bib/book
let $titles := $z/title
let $authors := $z/author
for $t in $titles
for $a in $authors
return
<ksiazka>
  <author>
  {concat($a/last,$a/first)}
  </author>
  {$t}
</ksiazka>:)

(:8
for $z in doc("db/bib/bib.xml")//bib/book
let $titles := $z/title
let $authors := $z/author
for $t in $titles
for $a in $authors
return
<ksiazka>
  <author>
  {concat($a/last," ",$a/first)}
  </author>
  {$t}
</ksiazka> :)
(:9
<wynik>
{
for $z in doc("db/bib/bib.xml")//bib/book
let $titles := $z/title
let $authors := $z/author
for $t in $titles
for $a in $authors
return
<ksiazka>
  <author>
  {concat($a/last," ",$a/first)}
  </author>
  {$t}
</ksiazka>
}
</wynik>
:)

(:10
for $z in doc("db/bib/bib.xml")//bib/book
where $z/title = "Data on the Web"
return 
<imiona>
{$z/author/first}
</imiona>:)

(:11
for $z in doc("db/bib/bib.xml")//bib/book[title="Data on the Web"]
return 
<DataOnTheWeb>
{$z}
</DataOnTheWeb>

for $z in doc("db/bib/bib.xml")//bib/book
where $z/title="Data on the Web"
return 
<DataOnTheWeb>
{$z}
</DataOnTheWeb>:)

(:12
for $z in doc("db/bib/bib.xml")//bib/book
where contains($z/title,'Data')
return 
<Data>
{$z/author/last}
</Data>:)

(:13
for $z in doc("db/bib/bib.xml")//bib/book
where contains($z/title,'Data')
return 
<Data>
{$z/title}
{$z/author/last}
</Data>:)

(:14
for $z in doc("db/bib/bib.xml")//bib/book
where count($z/author)<=2
return 
$z/title:)

(:15
for $z in doc("db/bib/bib.xml")//bib/book
return 
<ksiazka>
{$z/title}
<autorow>
{count($z/author)}
</autorow>
</ksiazka>:)

(:16
for $z in doc("db/bib/bib.xml")//bib
let $year := $z/book/@year
return
<przedzial>
{min($year)||" - "|| max($year)}
</przedzial>:)

(:17
for $z in doc("db/bib/bib.xml")//bib
let $p := $z/book/price
return
<roznica>
{max($p)-min($p)}
</roznica>:)

(:18
<najtansze>
{
for $z in doc("db/bib/bib.xml")//bib/book
where $z/price=(for $zz in doc("db/bib/bib.xml")//bib
let $p := $zz/book/price
return
min($p)
)
return
<najtańsza>
{$z/title},
{$z/author}
</najtańsza>
}
</najtansze>:)

(:19
for $a in distinct-values(doc("db/bib/bib.xml")//bib/book/author/last)
let $b := doc("db/bib/bib.xml")//bib/book[author/last = $a]/title
return
<autor>
  {$a}
  <ksiazki>
    {
      for $t in $b
      return <tytul>{$t}</tytul>
    }
  </ksiazki>
</autor>:)

(:20
<wynik>{
for $z in collection("db/shakespeare")
return
$z//PLAY/TITLE
}
</wynik>:)

(:21
for $z in collection("db/shakespeare")
let $t := $z//PLAY/TITLE
where contains($z/PLAY,'or not to be')
return
$z//PLAY/TITLE:)

(:22:)
<wynik>{
for $z in collection("db/shakespeare")//PLAY
let $t := $z/TITLE
return
<sztuka tytul="{$t}">
  <postaci>{count($z/PERSONAE/PERSONA)+count($z/PERSONAE/PGROUP/PERSONA)}</postaci>
    <aktow>{count($z//ACT)}</aktow>
    <scen>{count($z//SCENE)}</scen>
</sztuka>
}
</wynik>