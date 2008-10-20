#! /bin/sh

# First arg - input file of results to process
# Second arg - output file
IFS='|'
echo "||~ Gene ID||~ Gene Name||~ MeSH Disease Term||~ Score||~ $REF_SOURCE ||" 
while read term gene_id arg3 arg4 arg5 arg6 arg7 arg8 arg9 arg10 arg11 score
  do
  echo -n "|| [*http://view.ncbi.nlm.nih.gov/gene/$gene_id $gene_id] "
  echo "SELECT locus FROM gene WHERE gene_id=$gene_id" | mysql-dbrc wcdb2 | tail -n +2 | awk '{printf("|| %s ", $1)}'  
  echo -n "|| [*http://view.ncbi.nlm.nih.gov/mesh/$term $term] || $score || " 
  echo "SELECT DISTINCT $REF_SOURCE.pmid, pubmed.title FROM $REF_SOURCE, pubmed_mesh_parent, pubmed WHERE $REF_SOURCE.gene_id=$gene_id AND $REF_SOURCE.pmid=pubmed_mesh_parent.pmid AND pubmed_mesh_parent.mesh_parent=\"$term\" AND pubmed.pmid=$REF_SOURCE.pmid LIMIT 10" | mysql-dbrc wcdb2 | tail -n +2 | awk -F"\t" 'NR>1{printf ","};{printf("[*http://view.ncbi.nlm.nih.gov/pubmed/%s %s]",$1, $2)}'
  echo "||"
done

