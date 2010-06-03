import sys
import sets
from sets import Set

sep='|'

def usage():
	print "Compute ROC (Receiver Operating Characteristic) and AROC (Area under ROC)"
        print sys.argv[0], " <validationfile> <graph data output> [<score column>]"
	print "Field delimiter is  '",sep,"'"
	print "Assumes YN truth field is field 1, sorted by score"
	
def main():
	score_col=-1
	last_score=0
	failed=0

	if len(sys.argv) < 3:
		usage()
		exit(-1)
	if len(sys.argv) > 3:
		score_col=int(sys.argv[3])-1
	num_lines=0
	num_positives=0
	num_skip=0
	print "Counting Lines and Positives"
	scorefile=open(sys.argv[1])
	for line in scorefile:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		if len(tuple) <= score_col:
			num_skip=num_skip+1
			print "WARNING file:", sys.argv[1],"skipping line", num_skip+num_lines  , "Length",len(tuple),"Needed",score_col
			print "LINE:",line
			failed=1
			continue
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

	dx=0 # Deal with ties "fairly"

	# Use "parralelogram" rather than rectangles to approximate curve
	tp_fraction_old=0.0
	scorefile=open(sys.argv[1])
	outfile=open(sys.argv[2], 'w')
	for line in scorefile:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)

		# Skip the line if to short
		if len(tuple) <= score_col:
			continue;

		curr_lines=curr_lines+1

		if curr_lines == 1:
			# Before processing the first line
			if score_col >= 0:
				last_score=tuple[score_col]
		elif (score_col < 0) or (tuple[score_col] != last_score):
			if (score_col >= 0):
				last_score=tuple[score_col]

			tp_fraction=1.0 * curr_positives / num_positives
			np_fraction=1.0 * curr_negatives / num_negatives
			auc = auc + ((tp_fraction + tp_fraction_old) * dx / 2.0)
			dx = 0
			tp_fraction_old=tp_fraction

			if (((np_fraction) > next_graph_x) or ((tp_fraction) > next_graph_y)):
				outfile.write(str(np_fraction)+"|"+str(tp_fraction)+"\n")
				next_graph_x=np_fraction+0.001
				next_graph_y=tp_fraction+0.001

		# Process current row
		if tuple[0]=='Y':
			curr_positives=curr_positives+1
		else:
			curr_negatives=curr_negatives+1
			dx=dx+1


# Process Final Score
	tp_fraction=1.0 * curr_positives / num_positives
	np_fraction=1.0 * curr_negatives / num_negatives
	auc = auc + ((tp_fraction + tp_fraction_old) * dx / 2.0)

	auc = auc / num_negatives
	print "AUC:", auc
	if failed:
		exit(1)
main()
