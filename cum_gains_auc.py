import sys
import sets
from sets import Set

sep='|'

def usage():
	print "Compute Cumulative Gains Area Under Curve"
        print sys.argv[0], " <validationfile> <graph data output>"
	print "Field delimiter is  '",sep,"'"
	print "Assumes YN truth field is field 1, sorted by score"
	
def main():
	if len(sys.argv) < 3:
		usage()
		exit(-1)
	num_lines=0
	num_positives=0
	print "Counting Lines and Positives"
	scorefile=open(sys.argv[1])
	for line in scorefile:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		num_lines=num_lines+1
		if tuple[0]=='Y':
			num_positives=num_positives+1
	scorefile.close()
	print "Number of Lines:", num_lines
	print "Number of Positives:", num_positives
	auc=0.0
	curr_positives=0
	curr_lines=0
	last_graph=0.0
	scorefile=open(sys.argv[1])
	outfile=open(sys.argv[2], 'w')
	for line in scorefile:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		curr_lines=curr_lines+1
		if tuple[0]=='Y':
			curr_positives=curr_positives+1
		tp_fraction=1.0 * curr_positives / num_positives
		auc = auc + tp_fraction
		if (1.0*curr_lines/num_lines) > last_graph:
			outfile.write(str(last_graph)+"|"+str(tp_fraction)+"\n")
			last_graph=last_graph+0.001
	auc = auc / num_lines
	print "AUC:", auc
main()
