import sys
import sets
from sets import Set

sep='|'

def usage():
	print "Print all rows of data_file containing a row of pat_file in the first (or num_fields) field(s)"
        print sys.argv[0], " <pat_file> [<data_file> [<num_fields>]]"
	print "Field delimiter is  '",sep,"'"
	print "Use '-' as data_file or omit for stdin"
	print "num_fields defaults to 1"

def main():
	num_fields=1
	if (len(sys.argv) >= 3):
		patfile=open(sys.argv[1])
		if (sys.argv[2] == '-'):
			datafile=sys.stdin
		else:
			datafile=open(sys.argv[2])
		if (len(sys.argv) > 3):
			num_fields=int(sys.argv[3])
	elif (len(sys.argv) == 2):
		patfile=open(sys.argv[1])
		datafile=sys.stdin
        else:     
		usage()
		sys.exit(-1)

	patterns=Set()

	for line in patfile:
		patterns.add(line.strip())
	patfile.close()
	
	for line in datafile:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		if len(tuple) < (num_fields):
			continue
		if sep.join(tuple[:num_fields]) in patterns:
			print line,

main()
