<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0" xmlns:xls="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match='/'>
        <html>
            <body>
                <h1>Zespoły:</h1>
                <!--                6a-->
                <!--                <ol>-->
                <!--                    <xsl:for-each select="ZESPOLY/ROW">-->
                <!--                        <li><xsl:value-of select="NAZWA"/></li>-->
                <!--                    </xsl:for-each>-->
                <!--                </ol>-->
                <ol>
                    <xsl:apply-templates select="ZESPOLY/ROW"/>
                </ol>
                <xsl:apply-templates select="ZESPOLY/ROW" mode="details"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="ROW">
        <li>
            <a href="#{NAZWA}">
                <xsl:value-of select="NAZWA"/>
            </a>

        </li>
    </xsl:template>
    <!--    7-->
    <xsl:template match="*" mode="details">
        <h2 id="{NAZWA}">Nazwa:<xsl:value-of select="NAZWA"/>
        </h2>
        <h2>Adres:
            <xsl:value-of select="ADRES"/>
        </h2>
        <!--        14-->
        <xsl:if test="count(PRACOWNICY/ROW)>0">
            <!--        8-->
            <table border="1">
                <tr>
                    <th>Nazwisko</th>
                    <th>Etat</th>
                    <th>Zatrudniony</th>
                    <th>Placa Pod</th>
                    <!--                11-->
                    <!--                <th>Id Szefa</th>-->
                    <th>Szef</th>
                </tr>
                <xsl:apply-templates select="PRACOWNICY/ROW" mode="employee">
                    <!--                10-->
                    <xsl:sort select="NAZWISKO"/>
                </xsl:apply-templates>
            </table>
        </xsl:if>
        <!--        13-->
        Liczba pracowników:
        <xsl:value-of select="count(PRACOWNICY/ROW)"/>


    </xsl:template>
    <xsl:template match="ROW" mode="employee">
        <!--        8.-->
        <tr>
            <td>
                <xsl:value-of select="NAZWISKO"/>
            </td>
            <td>
                <xsl:value-of select="ETAT"/>
            </td>
            <td>
                <xsl:value-of select="ZATRUDNIONY"/>
            </td>
            <td>
                <xsl:value-of select="PLACA_POD"/>
            </td>
            <!--            11-->
            <!--            <td><xsl:value-of select="ID_SZEFA"/></td>-->
            <td>
                <xsl:call-template name="idSzefa">
                    <xsl:with-param name="idszef" select="ID_SZEFA"/>
                </xsl:call-template>
            </td>
        </tr>

    </xsl:template>
    <xsl:template name="idSzefa">
        <xsl:param name="idszef"/>
        <!--                <xsl:value-of select="//ROW[ID_PRAC=$idszef]/NAZWISKO"/>-->
        <!--12-->
        <xsl:choose>
            <xsl:when test="$idszef != ''">
                <xsl:value-of select="//ROW[ID_PRAC=$idszef]/NAZWISKO"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Brak</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
</xsl:stylesheet>