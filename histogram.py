# Make a histogram of the log values
# column given by first arg

import sys
import math

sep='|'

def usage():
    print "Generate histogram of the log10 (of absolute) values in field specified by first argument,  binned to one decimal place"
    print "\n", sys.argv[0], "<hist_col>\n"
    print "Input from stdin,  histogram output to stdout"
    print "Field separator is '", sep, "'"
    print

# Assume if x is too small that it is at least 1e-323
def safelog(x):
    if math.fabs(float(x)) < 1e-323 :
        return -323 # math.log(1e-323)
    return math.log(math.fabs(float(x)), 10)

def main():
    hist={}

    if (len(sys.argv) < 2):
        usage()
        sys.exit(-1)

    hist_col=int(sys.argv[1])

    file=sys.stdin
    for line in file:
        tuple=line.strip().split(sep)
        if len(tuple) < hist_col:
            continue
        value=tuple[hist_col-1]
        key=int(safelog(value)*10)
        if key in hist:
            hist[key]=hist[key]+1
        else:
            hist[key]=1
    
    print "log(value)|count"
    for key in hist:
        print str(key/10.0)+"|"+str(hist[key])

# Run the main program
main()
