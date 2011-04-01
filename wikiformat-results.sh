#! /bin/sh

# export REF_SOURCE=gene2pubmed (or generif)
# export SQL_CMD2=filter to access sql database
# stdin - file to process
# stdout - output
IFS='|'
echo "||~ Gene ||~ MeSH Disease Term||~ Score||~ $REF_SOURCE ||" 
while read term gene_id arg3 arg4 arg5 arg6 arg7 arg8 arg9 arg10 arg11 score
  do
  echo "SELECT locus FROM gene WHERE gene_id=$gene_id" | $SQL_CMD2 | tail -n +2 | awk '{printf("|| %s ", $1)}'  
  echo -n "([*http://view.ncbi.nlm.nih.gov/gene/$gene_id $gene_id]) "
  echo -n "|| [*http://view.ncbi.nlm.nih.gov/mesh/search/"
  echo -n "$term" | sed "s/ /\%20/g"
  echo -n "[MeSH%20Term] $term] || $score || " 
  echo "SELECT DISTINCT $REF_SOURCE.pmid, pubmed.title FROM $REF_SOURCE, pubmed_mesh_parent, pubmed WHERE $REF_SOURCE.gene_id=$gene_id AND $REF_SOURCE.pmid=pubmed_mesh_parent.pmid AND pubmed_mesh_parent.mesh_parent=\"$term\" AND pubmed.pmid=$REF_SOURCE.pmid LIMIT 10" | $SQL_CMD2 | tail -n +2 | awk -F"\t" 'NR>1{printf "  "};{printf("[*http://view.ncbi.nlm.nih.gov/pubmed/%s %s] %s",$1, $1, $2)}'
  echo "||"
done

