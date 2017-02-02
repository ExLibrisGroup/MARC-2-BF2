# MARC to BIBFRAME 2 Crosswalk

This represents an ongoing effort to create a crosswalk to transform MARC21 records into [BIBFRAME 2](https://www.loc.gov/bibframe/docs/bibframe2-model.html). The resulting crosswalk will be used in Ex Libris's Alma to enable display and export of records in BIBFRAME.

This repository consists of sample MARCXML records and one or more XSLT files. Alma enriches MARC records and transforms them with the XSLT as depicted in the figure below:

![Enrich and transform records in Alma](https://www.lucidchart.com/publicSegments/view/41d37dbd-ec24-4674-b7a9-15ec4a415708/image.png)

To execute the XSLT transformation there are a few options to choose from:

1. http://www.freeformatter.com/xsl-transformer.html
2. On a Unix server try http://xmlsoft.org/XSLT/xsltproc2.html
3. Using a programing language, for example for Java see http://stackoverflow.com/questions/4604497/xslt-processing-with-java
4. XML editor such as XMLSpy has built-in support for XSL transformation

## Creating enriched records from Alma
1. Configure the general publishing profile to enrich with linked data
2. Run the Publishing Platform Job for the enriched profile
3. The job output file includes BIB records with linked data
4. To view the linked data, unzip the output file and check the XML content
5. The Linked Data is set in `<subfield code="0">` of the relevant MARC codes:
```
008, 041a: 
"language" - "http://id.loc.gov/vocabulary/iso639-2/"

020a:
"isbn10" - "http://www.isbnsearch.org/isbn/" "/resolver/wikidata/isbn10/" 
"isbn13" - "http://www.isbnsearch.org/isbn/" "/resolver/wikidata/isbn13/" 

022a:
"issn" - "http://worldcat.org/issn/" "/resolver/wikidata/issn/" 

1xx,6xx:
"LCSH" - "http://id.loc.gov/authorities/subjects/" "/resolver/wikidata/lc/" 
"GND" - "https://portal.dnb.de/opac.htm/?method=simpleSearch&amp;cqlMode=true&amp;query=idn=" "http://viaf.org/viaf/sourceID/DNB|" "/resolver/wikidata/gnd/"
"LCNAMES" - "http://id.loc.gov/authorities/names/" "http://viaf.org/viaf/sourceID/LC|" "/resolver/wikidata/lc/"
"MESH" - "http://www.ncbi.nlm.nih.gov/mesh/?term="
```


