library(dbplyr)
library(ggplot2)
library(tidyr)

setwd("C:/Users/dario/OneDrive/università/MA/Module Genomics/Genome and Transcriptome")

gypsy_name <- "Gypsy_sequences.fa.rexdb-plant.cls.tsv"
gypsy <- read.csv(gypsy_name, sep="\t")
gypsy <- gypsy %>%
  separate(X.TE, into = c("V1", "_"), sep = "#")

copia_name <- "Copia_sequences.fa.rexdb-plant.cls.tsv"
copia <- read.csv(copia_name, sep="\t")
copia <- copia %>%
  separate(X.TE, into = c("V1", "_"), sep = "#")

read_filtered_file <- function(file_path) {
  lines <- readLines(file_path)
  filtered_lines <- lines[31:966]
  data <- read.table(text = paste(filtered_lines, collapse = "\n"), header = FALSE)
  return(data)
}

sum_file_name <- "assembly.fasta.mod.EDTA.TEanno.sum"
abundances <- read_filtered_file(sum_file_name)

copia <- dplyr::inner_join(copia, abundances, by="V1")
gypsy <- dplyr::inner_join(gypsy, abundances, by="V1")

ggplot(copia, aes(x = Clade, y = V2)) +
  geom_bar(stat = "identity", fill = "steelblue") +  # Create bar chart
  labs(title = "Abundance of Each Clade in Copia", x = "Clade", y = "Number of Occurrences") +
  theme_minimal()

ggplot(gypsy, aes(x = Clade, y = V2)) +
  geom_bar(stat = "identity", fill = "steelblue") +  # Create bar chart
  labs(title = "Abundance of Each Clade in Gypsy", x = "Clade", y = "Number of Occurrences") +
  theme_minimal()

