#!/usr/bin/env Rscript

library(Rsubread)

bampath = list.files(path = "mapped_new", full.names = TRUE)
result = featureCounts(bampath, annot.ext = 'chr19/merged.gtf', isGTFAnnotationFile=TRUE)
counts = result$counts
write.csv(counts, "counts.csv") 

correlation = cor(counts, method = 'spearman')
png(filename="heatmap.png")
heatmap(correlation, symm = TRUE, distfun = function(x){as.dist(1-x)})
dev.off()

mds=cmdscale(1-correlation,k=2)
write.csv(mds, "mds.csv") 
png(filename="mds.png")
plot(mds[,1],mds[,2], pch=19, col = c('#FFD700', '#FFD700', '#FFD700', '#FFD700', '#FFD700', 'blue', 'blue', 'blue', 'blue', 'blue'))
legend("bottomleft", legend = c("Мозжечок", "Кора"), col = c('blue', '#FFD700'), pch = 19, bty = "n")
dev.off()