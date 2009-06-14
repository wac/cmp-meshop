#!/bin/sh
OUTPUT_FILE=`date +BioMartGene-%Y-%m-%d.txt`
echo Getting $OUTPUT_FILE
cat hum_gene_query.biomart.xml | python query_biomart_gene_features.py > $OUTPUT_FILE.tmp
mv $OUTPUT_FILE.tmp $OUTPUT_FILE
echo Done