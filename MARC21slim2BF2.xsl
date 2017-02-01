<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:relator="http://id.loc.gov/vocabulary/relators/"
	xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdac="http://rdaregistry.info/Elements/c/"
	xmlns:rdaw="http://rdaregistry.info/Elements/w/"
	xmlns:rdae="http://rdaregistry.info/Elements/e/"
	xmlns:rdam="http://rdaregistry.info/Elements/m/"
	xmlns:rdai="http://rdaregistry.info/Elements/i/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="marc">

	<xsl:template name="datafield">
		<xsl:param name="tag" />
		<xsl:param name="ind1">
			<xsl:text> </xsl:text>
		</xsl:param>
		<xsl:param name="ind2">
			<xsl:text> </xsl:text>
		</xsl:param>
		<xsl:param name="subfields" />
		<xsl:element name="datafield">
			<xsl:attribute name="tag">
				<xsl:value-of select="$tag" />
			</xsl:attribute>
			<xsl:attribute name="ind1">
				<xsl:value-of select="$ind1" />
			</xsl:attribute>
			<xsl:attribute name="ind2">
				<xsl:value-of select="$ind2" />
			</xsl:attribute>
			<xsl:copy-of select="$subfields" />
		</xsl:element>
	</xsl:template>

	<xsl:template name="subfieldSelect">
		<xsl:param name="codes">
			abcdefghijklmnopqrstuvwxyz
		</xsl:param>
		<xsl:param name="delimeter">
			<xsl:text> </xsl:text>
		</xsl:param>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
					<xsl:value-of select="text()" />
					<xsl:value-of select="$delimeter" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of
			select="substring($str,1,string-length($str)-string-length($delimeter))" />
	</xsl:template>

	<xsl:template name="buildSpaces">
		<xsl:param name="spaces" />
		<xsl:param name="char">
			<xsl:text> </xsl:text>
		</xsl:param>
		<xsl:if test="$spaces>0">
			<xsl:value-of select="$char" />
			<xsl:call-template name="buildSpaces">
				<xsl:with-param name="spaces" select="$spaces - 1" />
				<xsl:with-param name="char" select="$char" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="chopPunctuation">
		<xsl:param name="chopString" />
		<xsl:param name="punctuation">
			<xsl:text>.:,;/ </xsl:text>
		</xsl:param>
		<xsl:variable name="length" select="string-length($chopString)" />
		<xsl:choose>
			<xsl:when test="$length=0" />
			<xsl:when test="contains($punctuation, substring($chopString,$length,1))">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString"
						select="substring($chopString,1,$length - 1)" />
					<xsl:with-param name="punctuation" select="$punctuation" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not($chopString)" />
			<xsl:otherwise>
				<xsl:value-of select="$chopString" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="chopPunctuationFront">
		<xsl:param name="chopString" />
		<xsl:variable name="length" select="string-length($chopString)" />
		<xsl:choose>
			<xsl:when test="$length=0" />
			<xsl:when test="contains('.:,;/[ ', substring($chopString,1,1))">
				<xsl:call-template name="chopPunctuationFront">
					<xsl:with-param name="chopString"
						select="substring($chopString,2,$length - 1)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not($chopString)" />
			<xsl:otherwise>
				<xsl:value-of select="$chopString" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:output method="xml" indent="yes" />

	<xsl:template match="/">
		<xsl:if test="marc:collection">
			<rdf:RDF xmlns:relator="http://id.loc.gov/vocabulary/relators/"
				xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdac="http://rdaregistry.info/Elements/c/"
				xmlns:rdaw="http://rdaregistry.info/Elements/w/" xmlns:rdae="http://rdaregistry.info/Elements/e/"
				xmlns:rdam="http://rdaregistry.info/Elements/m/" xmlns:rdai="http://rdaregistry.info/Elements/i/">

				<xsl:for-each select="marc:collection">
					<xsl:for-each select="marc:record">
							<xsl:apply-templates select="." />
					</xsl:for-each>
				</xsl:for-each>
			</rdf:RDF>
		</xsl:if>
	</xsl:template>

	<xsl:template match="marc:record">
		<xsl:variable name="leader" select="marc:leader" />
		<xsl:variable name="leader6" select="substring($leader,7,1)" />
		<xsl:variable name="leader7" select="substring($leader,8,1)" />
		<xsl:variable name="controlField008" select="controlfield[@tag=008]" />
		<xsl:variable name="cf008Date" select="substring($controlField008,8,4)" />
		<xsl:variable name="cf008Language" select="substring($controlField008,36,3)" />
		<xsl:variable name="id001" select="marc:controlfield[@tag=001]" />

		<!-- _____________ WORK _____________  -->
		<!-- title -->
		<xsl:for-each select="marc:datafield[@tag=245]|marc:datafield[@tag=246]">
			<bf:Work rdf:about="https://open-na.hosted.exlibrisgroup.com/alma/DEMO_INST/entity/work/TODO.rdf">
				<bf:title>
					<bf:workTitle>
						<bf:mainTitle><xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">
							abfghk
						</xsl:with-param>
					</xsl:call-template></bf:mainTitle>
					</bf:workTitle>
				</bf:title>
			</bf:Work>
		</xsl:for-each>


		<!-- _____________ INSTANCE _____________ -->
		<bf:Instance>
			<xsl:attribute name="rdf:about">https://open-na.hosted.exlibrisgroup.com/alma/DEMO_INST/entity/instance/<xsl:value-of select="$id001" />.rdf</xsl:attribute>

			<!-- lccn identifier from 010 -->
			<xsl:for-each select="marc:datafield[@tag=010]">
				<bf:identifiedBy>
					<bf:Lccn>
						<rdf:value><xsl:value-of select="marc:subfield[@code='a']" /></rdf:value>
					</bf:Lccn>
				</bf:identifiedBy>
			</xsl:for-each>


			<!-- isbn from 020 -->
			<xsl:if test="marc:datafield[@tag=020]">
				<bf:identifiedBy>
					<xsl:for-each select="marc:datafield[@tag=020]">
						<bf:Isbn>
							<rdf:value><xsl:value-of select="marc:subfield[@code='a']" /></rdf:value>
							<bf:source>http://www.isbnsearch.org/isbn/<xsl:value-of select="substring-before(marc:subfield[@code='a'],' ')"></xsl:value-of>
							</bf:source>
						</bf:Isbn>
					</xsl:for-each>
				</bf:identifiedBy>
			</xsl:if>

			<!-- identifier from 035 -->
			<xsl:for-each select="marc:datafield[@tag=035]">
				<bf:identifiedBy>
					<bf:Local>
						<rdf:value><xsl:value-of select="marc:subfield[@code='a']" /></rdf:value>
					</bf:Local>
				</bf:identifiedBy>
			</xsl:for-each>

			<!-- PrimaryContribution from 100 -->
			<xsl:for-each select="marc:datafield[@tag=100]">
				<bf:PrimaryContribution>
					<rdfs:label><xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">
							ab
						</xsl:with-param>
					</xsl:call-template></rdfs:label>
					<rdfs:label><xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">
							d
						</xsl:with-param>
					</xsl:call-template></rdfs:label>
				</bf:PrimaryContribution>
			</xsl:for-each>

			<!-- title from 245 -->
			<xsl:for-each select="marc:datafield[@tag=245]|marc:datafield[@tag=246]">
				<bf:title>
					<bf:InstanceTitle>
						<bf:mainTitle>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">
									afghk
								</xsl:with-param>
							</xsl:call-template>
						</bf:mainTitle>
						<bf:subTitle><xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">
									b
								</xsl:with-param>
							</xsl:call-template></bf:subTitle>
						<bf:responsibilityStatement><xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">
									c
								</xsl:with-param>
							</xsl:call-template></bf:responsibilityStatement>
					</bf:InstanceTitle>
				</bf:title>
			</xsl:for-each>

			<!-- Publication from 264 -->
			<xsl:variable name="sf264b">
				<xsl:for-each select="marc:datafield[@tag=264]/marc:subfield[@code='b']">
					<xsl:value-of select="." />
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="sf264c">
				<xsl:for-each select="marc:datafield[@tag=264]/marc:subfield[@code='c']">
					<xsl:value-of select="." />
				</xsl:for-each>
			</xsl:variable>

			<xsl:for-each select="marc:datafield[@tag=264]/marc:subfield[@code='a']">
				<bf:provisionActivity>
					<bf:Publication>
						<bf:place><xsl:value-of select="." /></bf:place>
						<bf:Agent><xsl:value-of select="$sf264b" /></bf:Agent>
						<bf:Date><xsl:value-of select="$sf264c" /></bf:Date>
					</bf:Publication>
				</bf:provisionActivity>
			</xsl:for-each>

			<!-- publisher from 260 - needed? -->
			<xsl:variable name="sf260b">
				<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='b']">
					<xsl:value-of select="." />
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="sf260c">
				<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='c']">
					<xsl:value-of select="." />
				</xsl:for-each>
			</xsl:variable>

			<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='a']">
				<bf:publication>
					<bf:Provider>
						<bf:providerName>
							<bf:Organization>
								<xsl:value-of select="$sf260b" />
							</bf:Organization>
						</bf:providerName>
						<bf:providerPlace>
							<bf:Place>
								<bf:label>
									<xsl:value-of select="." />
								</bf:label>
							</bf:Place>
						</bf:providerPlace>
						<bf:copyrightDate>
							<xsl:value-of select="$sf260c" />
						</bf:copyrightDate>
					</bf:Provider>
				</bf:publication>
			</xsl:for-each>

			<!-- extent from 300$$a -->
			<xsl:for-each select="marc:datafield[@tag=300]">
				<bf:extent><xsl:value-of select="marc:subfield[@code='a']" /></bf:extent>
			</xsl:for-each>

			<!--noteType from 300$$b -->
			<xsl:for-each select="marc:datafield[@tag=300]">
				<bf:note>
					<bf:noteType>Physical details</bf:noteType>
					<rdfs:label><xsl:value-of select="marc:subfield[@code='b']" /></rdfs:label>
				</bf:note>
			</xsl:for-each>

			<!--dimensions from 300$$c -->
			<xsl:for-each select="marc:datafield[@tag=300]">
				<bf:dimensions><xsl:value-of select="marc:subfield[@code='c']" /></bf:dimensions>
			</xsl:for-each>

			<!--note from 504 -->
			<xsl:for-each select="marc:datafield[@tag=504]">
				<bf:note>
					<bf:noteType>bibliography</bf:noteType>
					<rdfs:label><xsl:value-of select="marc:subfield[@code='a']" /></rdfs:label>
				</bf:note>
			</xsl:for-each>

		</bf:Instance>
	</xsl:template>
</xsl:stylesheet>