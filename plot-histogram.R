infile<-Sys.getenv("PROCESS_INFILE")
infile
outfile<-Sys.getenv("PROCESS_OUTFILE")
outfile
mainlabel<-Sys.getenv("PROCESS_LABEL")

# Load
hist<-read.table(infile,sep="|", header=TRUE)
pdf(outfile)
barplot(hist$count, names.arg=as.character(hist$log.value), cex.names=0.7, xlab="log Score", ylab="Number of scores", main=mainlabel)
dev.off()

