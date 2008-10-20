infile<-Sys.getenv("PROCESS_INFILE")
infile
outfile<-Sys.getenv("PROCESS_OUTFILE")
outfile

# Load
hist<-read.table(infile,sep="|", header=TRUE)
pdf(outfile)
barplot(hist$count, names.arg=as.character(hist$log.value))
dev.off()

