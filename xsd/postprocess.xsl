<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  version="2.0">
  
  <xsl:strip-space elements="*"/>
  <xsl:output indent="yes"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="node()|comment()|processing-instruction()"/>
  </xsl:template>
  
  <xsl:template match="node()|@*|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*|comment()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="xs:any">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(@namespace)">
        <xsl:attribute name="namespace">##other</xsl:attribute>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="xs:element[@ref]">
    <xsl:choose>
      <xsl:when test="following-sibling::*[1]/self::xs:element[@ref = current()/@ref] and
        not(preceding-sibling::*[1]/self::xs:element[@ref = current()/@ref])">
        <xs:element ref="{current()/@ref}" 
          minOccurs="{count(following-sibling::*/self::xs:element[@ref = current()/@ref and not(@minOccurs = '0')]) + 1}"
          maxOccurs="{tei:count-elements(1, current())}"/>
      </xsl:when>
      <xsl:when test="following-sibling::*[1]/self::xs:sequence[xs:element/@ref = current()/@ref] and
        not(preceding-sibling::*[1]/self::xs:element[@ref = current()/@ref])">
        <xs:element ref="{current()/@ref}" 
          minOccurs="1"
          maxOccurs="{tei:count-elements(1, current())}"/>
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1]/self::xs:element[@ref = current()/@ref]"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="xs:group[@ref]">
    <xsl:choose>
      <xsl:when test="following-sibling::*[1]/self::xs:group[@ref = current()/@ref] and
        not(preceding-sibling::*[1]/self::xs:group[@ref = current()/@ref])">
        <xs:group ref="{current()/@ref}" 
          minOccurs="{count(following-sibling::*/self::xs:group[@ref = current()/@ref and not(@minOccurs = '0')]) + 1}"
          maxOccurs="{tei:count-elements(1, current())}"/>
      </xsl:when>
      <xsl:when test="following-sibling::*[1]/self::xs:sequence[xs:group/@ref = current()/@ref] and
        not(preceding-sibling::*[1]/self::xs:group[@ref = current()/@ref])">
        <xs:group ref="{current()/@ref}" 
          minOccurs="1"
          maxOccurs="{tei:count-elements(1, current())}"/>
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1]/self::xs:group[@ref = current()/@ref]"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="xs:sequence">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1]/self::xs:element[@ref = current()/xs:element/@ref]"/>
      <xsl:when test="preceding-sibling::*[1]/self::xs:group[@ref = current()/xs:group/@ref]"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="tei:count-elements">
    <xsl:param name="count"/>
    <xsl:param name="elt"/>
    <xsl:choose>
      <xsl:when test="$elt/following-sibling::*[1]/self::xs:element[@ref = $elt/@ref]">
        <xsl:value-of select="tei:count-elements($count + 1, $elt/following-sibling::*[1])"/>
      </xsl:when>
      <xsl:when test="$elt/following-sibling::*[1]/self::xs:group[@ref = $elt/@ref]">
        <xsl:value-of select="tei:count-elements($count + 1, $elt/following-sibling::*[1])"/>
      </xsl:when>
      <xsl:when test="$elt/following-sibling::*[1]/self::xs:sequence[xs:element/@ref = $elt/@ref]">
        <xsl:value-of select="tei:count-elements($count + 1, $elt/following-sibling::*[1]/xs:element)"/>
      </xsl:when>
      <xsl:when test="$elt/following-sibling::*[1]/self::xs:sequence[xs:group/@ref = $elt/@ref]">
        <xsl:value-of select="tei:count-elements($count + 1, $elt/following-sibling::*[1]/xs:group)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$elt/@maxOccurs = 'unbounded'">unbounded</xsl:when>
          <xsl:otherwise><xsl:value-of select="$count"/></xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>