<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:csv="https://di.huc.knaw.nl/ns/csv"
    exclude-result-prefixes="xs math csv"
    version="3.0">
    
    <xsl:import href="csv2xml.xsl"/>
    
    <xsl:param name="csv" select="'tastade.csv'"/>
    
    <xsl:template name="main">
        <xsl:for-each-group select="csv:getCSV($csv)//r[normalize-space()!='']" group-by="c[@n='entiteit']">
            <xsl:variable name="ent" select="current-grouping-key()"/>
            <xsl:result-document href="profiles/{$ent}.xml" method="xml">
                <ComponentSpec isProfile="true" CMDVersion="1.2" CMDOriginalVersion="1.2" xsi:noNamespaceSchemaLocation="https://infra.clarin.eu/CMDI/1.x/xsd/cmd-component.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsl:expand-text="yes">
                    <Header>
                        <ID>clarin.eu:cr1:p_{$ent}</ID>
                        <Name>{$ent}</Name>
                        <Description></Description>
                        <Status>development</Status>
                    </Header>
                    <Component name="{$ent}" CardinalityMin="1" CardinalityMax="1">
                        <xsl:for-each select="current-group()[normalize-space(c[@n='veld'])!='']">
                            <Element name="{normalize-space(c[@n='veld'])}">
                                <xsl:choose>
                                    <xsl:when test="normalize-space(c[@n='type'])='text'">
                                        <xsl:attribute name="ValueScheme" select="'string'"/>
                                    </xsl:when>
                                </xsl:choose>
                            </Element>
                        </xsl:for-each>
                    </Component>
                </ComponentSpec>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>


</xsl:stylesheet>