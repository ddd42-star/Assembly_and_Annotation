library(tidyverse)
library(data.table)

setwd("C:/Users/dario/OneDrive/università/MA/Module Genomics/Genome and Transcriptome")


data_plot <- read.table("assembly.all.maker.renamed.gff.AED.txt")

View(data_plot)

names(data_plot)[1] <- "AED"
names(data_plot)[2] <- "Percentage"

plot(data_plot$AED,data_plot$Percentage, xlab = "AED Values", ylab = "Cumulative fraction of Annotation", type='l',lty=1, col='blue' )
grid()
abline(v=0.5, col="green")
abline(v=0.3, col="red")
legend('bottomright', legend =c("Distribution AED values", "AED=0.5", "AED=0.3"), col = c('blue', 'green', 'red'), lty = c(1,1,1))
title("Distribution of AED values")
