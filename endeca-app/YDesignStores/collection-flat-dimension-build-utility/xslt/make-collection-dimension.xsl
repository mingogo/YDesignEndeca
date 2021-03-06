<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:endeca="http://endeca.com/schema/content/2008">

	<xsl:import href="hierarchy-functions.xsl"/>

	<xsl:output method="xml" doctype-system="dimensions.dtd"/>

	<xsl:param name="run-date"/>
	<xsl:param name="input-file" required="yes"/>
	<xsl:param name="delimiter" required="no" select="'\|'"/>
	<xsl:param name="id-pattern" required="no" select="'100000'"/>
	
	<!-- Create items variable -->
	<xsl:variable name="items" select="endeca:get-flat-list($input-file,$delimiter)"/>

	<xsl:attribute-set name="dimensions_attributes">
		<xsl:attribute name="VERSION">1.0.0</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="dimension_attributes">
		<xsl:attribute name="SRC_TYPE">INTERNAL</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="dval_attributes">
		<xsl:attribute name="TYPE">EXACT</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="synonym_attributes_classify">
		<xsl:attribute name="CLASSIFY">TRUE</xsl:attribute>
		<xsl:attribute name="DISPLAY">FALSE</xsl:attribute>
		<xsl:attribute name="SEARCH">TRUE</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="synonym_attributes_display">
		<xsl:attribute name="CLASSIFY">FALSE</xsl:attribute>
		<xsl:attribute name="DISPLAY">TRUE</xsl:attribute>
		<xsl:attribute name="SEARCH">TRUE</xsl:attribute>
	</xsl:attribute-set>

	<xsl:template match="/">

		<xsl:element name="DIMENSIONS" use-attribute-sets="dimensions_attributes">

				<xsl:call-template name="make-dimension">
					<xsl:with-param name="dimension-name" select="'Collections'"/>
					<xsl:with-param name="items" select="$items//*"/>
				</xsl:call-template>

		</xsl:element>

	</xsl:template>

	<!-- Create dimension -->
	<xsl:template name="make-dimension">
		<xsl:param name="dimension-name"/>
		<xsl:param name="items"/>

		<xsl:element name="DIMENSION" use-attribute-sets="dimension_attributes">

			<xsl:attribute name="NAME">
				<xsl:value-of select="$dimension-name" />
			</xsl:attribute>  

			<xsl:element name="DIMENSION_ID">
				<xsl:attribute name="ID">
					<xsl:value-of select="format-number(number($id-pattern),'###########')"/>
				</xsl:attribute>
			</xsl:element>
	
			<!-- dimension node -->
			<xsl:element name="DIMENSION_NODE">

				<xsl:element name="DVAL">

					<xsl:attribute name="TYPE">
						<xsl:text>EXACT</xsl:text>
					</xsl:attribute>  

					<xsl:element name="DVAL_ID">
						<xsl:attribute name="ID">
							<xsl:value-of select="$id-pattern" />
						</xsl:attribute>  
					</xsl:element>

					<xsl:element name="SYN" use-attribute-sets="synonym_attributes_display">
						<xsl:value-of select="$dimension-name" />
					</xsl:element>
				</xsl:element>

				<!-- Add dimension value properties -->
				<xsl:for-each select="$items//item[@collection_id]">
					<xsl:call-template name="make-dimension-node">
						<xsl:with-param name="current-node" select="."/>
					</xsl:call-template>
				</xsl:for-each>

			</xsl:element>
		</xsl:element>

	</xsl:template>

	<!-- Create dimension nodes -->
	<xsl:template name="make-dimension-node">
		<xsl:param name="current-node"/>

		<xsl:variable name="id" select="$current-node/@collection_id"/>
		<xsl:variable name="value" select="$current-node/@collection_name"/>

		<xsl:element name="DIMENSION_NODE">

			<xsl:element name="DVAL" use-attribute-sets="dval_attributes">

				<xsl:element name="DVAL_ID">
					<xsl:attribute name="ID">
						<xsl:value-of select="format-number(number($id-pattern)+$id,'###########')"/>
					</xsl:attribute>
				</xsl:element>

				<!-- Classify code -->
				<xsl:element name="SYN" use-attribute-sets="synonym_attributes_classify">
					<xsl:value-of select="$id"/>
				</xsl:element>

				<!-- Display name code -->
				<xsl:element name="SYN" use-attribute-sets="synonym_attributes_display">
					<xsl:value-of select="$value"/>
				</xsl:element>

				<!-- Add dimension value properties -->
				<xsl:for-each select="@*[(local-name() != 'collection_id') and (local-name() != 'collection_name') and (string-length() > 0)]">
					<xsl:element name="PROP">
						<xsl:attribute name="NAME">
							<xsl:value-of select="local-name()"/>
						</xsl:attribute>
						<xsl:element name="PVAL">
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				
			</xsl:element>

		</xsl:element>

	</xsl:template>

</xsl:stylesheet>
