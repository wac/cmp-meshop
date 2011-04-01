# Assumes BioMart Results are TSV with fields
# "entrezgene" 
# "start_position"
# "end_position"
# "transcript_start"
# "transcript_end"
# "transcript_count"
# "percentage_gc_content" 
#
import urllib
import sys

sep="|"

file=sys.stdin
query=""
for line in file:
	query=query+line
params=urllib.urlencode({'query' : query})

urlstring="http://www.biomart.org/biomart/martservice?" + params

print "#gene_id"+sep+"genomic_length"+sep+"transcript_length"+sep+"num_transcripts"+sep+"gc_content"+sep+urlstring
result=urllib.urlopen(urlstring)
for line in result.readlines():
	tuple=line.strip("\t").split()
	gene_id=tuple[0]
	gene_length=str(abs(int(tuple[1])-int(tuple[2])))
	rna_length=str(abs(int(tuple[3])-int(tuple[4])))
	num_transcripts=tuple[5]
	gc=tuple[6]
	print gene_id+sep+gene_length+sep+rna_length+sep+num_transcripts+sep+gc