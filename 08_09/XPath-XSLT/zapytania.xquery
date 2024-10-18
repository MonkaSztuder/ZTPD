(:XPath w XQuery:)
(:26:)
(:for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/swiat.xml')/SWIAT/KONTYNENTY/KONTYNENT:)
(:return <KRAJ>:)
(: {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:27:)
(:for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ:)
(:return <KRAJ>:)
(: {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:28:)
(:for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ:)
(:where starts-with($k/NAZWA, 'A'):)
(:return <KRAJ>:)
(: {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:29:)
(:for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ:)
(:where starts-with($k/NAZWA, substring($k/STOLICA, 1, 1)):)
(:return <KRAJ>:)
(: {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:30:)
(:doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/swiat.xml')//KRAJ:)

(:31:)
(:doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/zesp_prac.xml'):)


(:XPATH:)
(:32:)
(:doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/zesp_prac.xml')//NAZWISKO:)

(:33:)
(:for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW[NAZWA='SYSTEMY EKSPERCKIE']/PRACOWNICY/ROW:)

(:return $k/NAZWISKO:)

(:34:)
(:for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW[ID_ZESP=10]:)

(:return count($k/PRACOWNICY/ROW):)
(:35:)
(:for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW/PRACOWNICY/ROW[ID_SZEFA=100]:)

(:return $k/NAZWISKO:)

(:36:)
let $teamID := doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW/PRACOWNICY/ROW[NAZWISKO='BRZEZINSKI']/ID_ZESP
for $k in doc('file:///C:/Users/user/Documents/githubRepos/TPDII/ZTPD/08/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW[ID_ZESP=$teamID]

return sum($k/PRACOWNICY/ROW/PLACA_POD)