library(reshape2)
library(hrbrthemes)
library(tidyverse)
library(data.table)


# get data from parameter
setwd("C:/Users/dario/OneDrive/università/MA/Module Genomics/Genome and Transcriptome")


data <- "assembly.fasta.mod.out.landscape.Div.Rname.tab"

rep_table <- fread(data, header = FALSE, sep = "\t")
rep_table %>% head()
# How does the data look like?

colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
rep_table <- rep_table %>% filter(Rfam != "unknown")
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

table(rep_table$fam)
# How many elements are there in each Superfamily?

rep_table.m <- melt(rep_table)

rep_table.m <- rep_table.m[-c(which(rep_table.m$variable == 1)), ] # remove the peak at 1, as the library sequences are copies in the genome, they inflate this low divergence peak

# Arrange the data so that they are in the following order:
# LTR/Copia, LTR/Gypsy, all types of DNA transposons (TIR transposons), DNA/Helitron, all types of MITES
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LTR/Copia", "LTR/Gypsy", "DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", "DNA/Helitron",
  "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM"
))

# NOTE: Check that all the superfamilies in your dataset are included above
table(rep_table$fam)

rep_table.m$distance <- as.numeric(rep_table.m$variable) / 100 # as it is percent divergence

# Question:
# rep_table.m$age <- ??? # Calculate using the substitution rate and the formula provided in the tutorial
sub_rate <- 8.22 * 10^-9
rep_table.m$age <-as.numeric(rep_table.m$variable) / (2*sub_rate)

rep_table.m$age <- rep_table.m$age / 10^6 # convert in My= Million Year

# options(scipen = 999)

# remove helitrons as EDTA is not able to annotate them properly (https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A)
rep_table.m <- rep_table.m %>% filter(fam != "DNA/Helitron")

# change x = distance to see the percentage of divergence

ggplot(rep_table.m, aes(fill = fam, x = age, weight = value / 1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  scale_fill_brewer(palette = "Paired") +
  xlab("Age (Million years)") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

ggsave(filename = "Plots/output.pdf", width = 10, height = 5, useDingbats = F)


# Question: Now can you get separate plots for each superfamily? Use violin plots for this

# Question: Do you have other clades of LTR-RTs not present in the full length elements?
# You have to use the TEsorter output from Intact LTR-RTs and TElib to answer this question
