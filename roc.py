import sys
import sets
from sets import Set

sep='|'

def usage():
	print "Compute ROC (Receiver Operating Characteristic) and AROC (Area under ROC)"
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
	num_negatives=num_lines-num_positives
	print "Number of Lines:", num_lines
	print "Number of Positives:", num_positives
	print "Number of Non-Positives:", num_negatives
	auc=0.0
	curr_positives=0
	curr_negatives=0
	curr_lines=0
	next_graph_x=0.0
	next_graph_y=0.0
 	tp_fraction=0.0
	np_fraction=0.0
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
		else:
			curr_negatives=curr_negatives+1
			np_fraction=1.0 * curr_negatives / num_negatives
			auc = auc + tp_fraction
			if (((np_fraction) > next_graph_x) or ((tp_fraction) > next_graph_y)):
				outfile.write(str(np_fraction)+"|"+str(tp_fraction)+"\n")
				next_graph_x=np_fraction+0.001
				next_graph_y=tp_fraction+0.001
	auc = auc / num_lines
	print "AUC:", auc
main()
