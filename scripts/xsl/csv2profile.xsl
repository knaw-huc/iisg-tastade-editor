<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:csv="https://di.huc.knaw.nl/ns/csv" exclude-result-prefixes="xs math csv" version="3.0">

    <xsl:import href="csv2xml-semi.xsl"/>

    <xsl:param name="csv" select="'tastade.csv'"/>

    <xsl:template name="main">
        <xsl:for-each-group select="csv:getCSV($csv)//r[normalize-space() != '']"
            group-by="c[@n = 'entiteit']">
            <xsl:variable name="ent" select="current-grouping-key()"/>
            <xsl:result-document href="profiles/{$ent}.xml" method="xml">
                <ComponentSpec isProfile="true" CMDVersion="1.2" CMDOriginalVersion="1.2"
                    xsi:noNamespaceSchemaLocation="https://infra.clarin.eu/CMDI/1.x/xsd/cmd-component.xsd"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsl:expand-text="yes">
                    <Header>
                        <ID>clarin.eu:cr1:p_{$ent}</ID>
                        <Name>{$ent}</Name>
                        <Description/>
                        <Status>development</Status>
                    </Header>
                    <Component name="{$ent}" CardinalityMin="1" CardinalityMax="1">
                        <xsl:for-each-group select="current-group()"
                            group-by="c[@n = 'sub_entiteit']">
                            <xsl:variable name="sub_entiteit" select="current-grouping-key()"/>
                            <Component name="{replace(replace($sub_entiteit,'\s+','_'),'[^a-zA-Z_0-9]','_')}">
<!-- het uitsluiten van de entiteit binnen zichzelf werkt niet goed als deze een repeat oid is -->
                                <xsl:for-each select="current-group()[normalize-space(c[@n='veld'])!=replace(lower-case($sub_entiteit),' ','_')][normalize-space(c[@n='veld'])!='']">
                                    <Element name="{normalize-space(c[@n='veld'])}">
                                        <xsl:variable name="type_field"
                                            select="normalize-space(c[@n = 'type'])"/>
                                        <xsl:choose>
                                            <xsl:when test="$type_field = 'text' or $type_field = 'textarea'">
                                                <xsl:attribute name="ValueScheme" select="'string'"
                                                />
                                            </xsl:when>
                                            <xsl:when test="$type_field = 'number'">
                                                <xsl:attribute name="ValueScheme" select="'int'"/>
                                            </xsl:when>
                                            <xsl:when test="$type_field = 'alt_date_picker'">
                                                <xsl:attribute name="ValueScheme" select="'date'"/>
                                            </xsl:when>
                                            <xsl:when test="$type_field = 'true_false'">
                                                <xsl:attribute name="ValueScheme" select="'boolean'"/>
                                            </xsl:when>
                                            <xsl:when test="$type_field = 'wysiwyg'">
                                                <xsl:attribute name="ValueScheme" select="'string'"
                                                />
                                            </xsl:when>
                                            <!-- wat te doen met clone (is voorziening om niet te hoeven copy en paste)  -->
                                            <xsl:when test="$type_field = 'clone'">
                                                <xsl:attribute name="ValueScheme" select="'string'"
                                                />
                                            </xsl:when>
<!-- tab is waarschijnlijk een groeperings iets -->
                                            <xsl:when test="$type_field = 'tab'">
                                                <xsl:attribute name="ValueScheme" select="'tab'"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="$type_field = 'select' or $type_field = 'radio' or $type_field = 'checkbox'">
                                                <ValueScheme>
                                                    <Vocabulary>
                                                        <enumeration>
                                                            <xsl:variable name="choice_list"
                                                                select="c[@n = 'choice_list']"/>
                                                            <xsl:if test="$choice_list != ''">
                                                                <xsl:for-each
                                                                    select="tokenize($choice_list, '\|')">
                                                                    <item>
                                                                        <xsl:value-of select="."/>
                                                                    </item>
                                                                </xsl:for-each>
                                                            </xsl:if>
                                                        </enumeration>
                                                    </Vocabulary>
                                                </ValueScheme>
                                            </xsl:when>
                                        </xsl:choose>
                                    </Element>
                                </xsl:for-each>
                            </Component>
                        </xsl:for-each-group>
                        <!-- </xsl:for-each>-->
                    </Component>
                </ComponentSpec>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>


</xsl:stylesheet>
