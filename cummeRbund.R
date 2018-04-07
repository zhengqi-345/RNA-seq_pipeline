if(require(cummeRbund)){
	library(cummeRbund)
}else{
	source("http://www.bioconductor.org/biocLite.R")
	biocLite("cummeRbund",dependencies=T)
	library('cummeRbund')
}

args<- commandArgs(T)

if(exists(args[1])){
	infile=args[1]
}else{
	exit
}		

if(exists(args[2])){
	output=args[2]
}else{
	output="output.jpg"
}

cuff_data <- readCufflinks(infile)
jpeg(output)
par(mfrow=c(2,2))
layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
csDensity(genes(cuff_data))
csScatter(genes(cuff_data), 'C1', 'C2')
csVolcano(genes(cuff_data), 'C1', 'C2')
de.off()
