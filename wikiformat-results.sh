#! /bin/sh

# First arg - input file of results to process
# Second arg - output file
IFS='|'
echo "||~ Gene ID||~ MeSH Disease Term||~ Score||~ $PRED_REF_SOURCE ||" 
while read term gene_id arg3 arg4 arg5 arg6 arg7 arg8 arg9 arg10 arg11 score
do
   echo -n "|| [*http://view.ncbi.nlm.nih.gov/gene/$gene_id $gene_id] || [*http://view.ncbi.nlm.nih.gov/mesh/$term $term] || $score || " 
    echo "SELECT DISTINCT $PRED_REF_SOURCE.pmid FROM $PRED_REF_SOURCE, pubmed_mesh_parent WHERE $PRED_REF_SOURCE.gene_id=$gene_id AND $PRED_REF_SOURCE.pmid=pubmed_mesh_parent.pmid AND pubmed_mesh_parent.mesh_parent=\"$term\" LIMIT 10" | mysql-dbrc wcdb2 | tail -n +2 | awk 'NR>1{printf ","};{printf("[*http://view.ncbi.nlm.nih.gov/pubmed/%s %s]",$1, $1)}'
    echo "||"
done

