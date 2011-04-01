#! /bin/sh

# Export REF_SOURCE=gene2pubmed (or generif)
# stdin - input file
# stdout - output
IFS='|'
echo "||~ Gene ||~ MeSH Disease Term||~ Score 12 ||~ $REF_SOURCE ||" 
while read term gene_id arg3 arg4 arg5 score arg7 arg8 arg9 arg10 arg11 arg12
  do
  NEJM_RESULT=`echo "SELECT DISTINCT $REF_SOURCE.pmid, pubmed.title FROM $REF_SOURCE, pubmed_mesh_parent, pubmed WHERE $REF_SOURCE.gene_id=$gene_id AND $REF_SOURCE.pmid=pubmed_mesh_parent.pmid AND pubmed_mesh_parent.mesh_parent=\"$term\" AND pubmed.pmid=$REF_SOURCE.pmid AND pubmed.journaltitle=\"The New England journal of medicine\" LIMIT 10" | mysql-dbrc wcdb3 | tail -n +2`
  if [ -n "$NEJM_RESULT" ] ;  then  
      echo "SELECT locus FROM gene WHERE gene_id=$gene_id" | mysql-dbrc wcdb3 | tail -n +2 | awk '{printf("|| %s ", $1)}'
      echo -n "([*http://view.ncbi.nlm.nih.gov/gene/$gene_id $gene_id]) "
      echo -n "|| [*http://view.ncbi.nlm.nih.gov/mesh/search/"
      echo -n "$term" | sed "s/ /\%20/g"
      echo -n "[MeSH%20Term] $term] || $score || "
      echo $NEJM_RESULT | awk -F"\t" 'NR>1{printf "  "};{printf("[*http://view.ncbi.nlm.nih.gov/pubmed/%s %s] %s",$1, $1, $2)}'
      echo "||"
  fi
done

