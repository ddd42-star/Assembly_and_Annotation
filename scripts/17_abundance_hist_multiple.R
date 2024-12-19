library(ggplot2)
library(tidyr)

setwd("C:/Users/dario/OneDrive/università/MA/Module Genomics/Genome and Transcriptome")

read_filtered_file <- function(file_path, start, end) {
  print(file_path)
  lines <- readLines(file_path)
  filtered_lines <- lines[start:end]
  #print(filtered_lines)
  data <- read.table(text = paste(filtered_lines, collapse = "\n"), header = FALSE)
  return(data)
}

process_te_data <- function(te_name, sum_file_name, start, end, accession) {
  te_data <- read.csv(te_name, sep="\t") %>%
    separate(X.TE, into = c("V1", "_"), sep = "#")
  
  abundances <- read_filtered_file(sum_file_name, start, end)
  
  te_data <- dplyr::inner_join(te_data, abundances, by="V1")
  
  te_data <- te_data %>% dplyr::mutate(Accession = accession)
  
  return(te_data)
}

# List of file pairs
file_pairs <- list(
  list(te_name = "Copia_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "assembly.fasta.mod.EDTA.TEanno.sum", start=31, end=978, accession="Db-1"),
  list(te_name = "Gypsy_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "assembly.fasta.mod.EDTA.TEanno.sum", start=31, end=978, accession="Db-1"),
  list(te_name = "St0/Copia_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "St0/ERR11437341.asm.bp.p_ctg.fa.mod.EDTA.TEanno.sum", start=31, end=978, accession="St0"),
  list(te_name = "St0/Gypsy_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "St0/ERR11437341.asm.bp.p_ctg.fa.mod.EDTA.TEanno.sum", start=31, end=978, accession="St0"),
  list(te_name = "Had-6bn/Copia_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "Had-6bn/assembly.fasta.mod.EDTA.TEanno.sum", start=355, end=1173, accession="Had-6bn"),
  list(te_name = "Had-6bn/Gypsy_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "Had-6bn/assembly.fasta.mod.EDTA.TEanno.sum", start=355, end=1173, accession="Had-6bn"),
  list(te_name = "Kar1/Copia_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "Kar1/assembly.fasta.mod.EDTA.TEanno.sum", start=314, end=1143, accession="Kar1"),
  list(te_name = "Kar1/Gypsy_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "Kar1/assembly.fasta.mod.EDTA.TEanno.sum", start=314, end=1143, accession="Kar1"),
  list(te_name = "Rubezhnoe1/Copia_arab_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "Rubezhnoe1/flye_assembly.fasta.mod.EDTA.TEanno.sum", start=31, end=968, accession="Rubezhnoe1"),
  list(te_name = "Rubezhnoe1/Gypsy_arab_sequences.fa.rexdb-plant.cls.tsv", sum_file_name = "Rubezhnoe1/flye_assembly.fasta.mod.EDTA.TEanno.sum", start=31, end=968, accession="Rubezhnoe1")
  
  # add more accession number if you want
)

# Process each file pair and create a list of dataframes
te_data_list <- lapply(file_pairs, function(pair) {
  process_te_data(pair$te_name, pair$sum_file_name, pair$start, pair$end, pair$accession)
})

combined_data_copia <- NULL
combined_data_gypsy <- NULL

# Plot for Copia
for (i in seq(1,length(te_data_list), 2)) {
  copia_data <- te_data_list[[i]] %>%
  dplyr::group_by(Accession, Clade) %>%
  dplyr::summarise(Count = sum(V2))
  
  combined_data_copia <- dplyr::bind_rows(combined_data_copia, copia_data)
}


ggplot(combined_data_copia, aes(x = Clade, y = Count, fill = Accession)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  #facet_wrap(~ Accession, ncol = 2) +  # Facet by Accession
  labs(title = "Abundance of Each Copia Accession by Clade", x = "Clade", y = "Count") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot for Gypsy
for (i in seq(2,length(te_data_list), 2)) {
  gypsy_data <- te_data_list[[i]] %>%
  dplyr::group_by(Accession, Clade) %>%
  dplyr::summarise(Count = sum(V2))
  
  combined_data_gypsy <- dplyr::bind_rows(combined_data_gypsy, gypsy_data)
}


ggplot(combined_data_gypsy, aes(x = Clade, y = Count, fill = Accession)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  #facet_wrap(~ Accession, ncol = 2) +  # Facet by Accession
  labs(title = "Abundance of Each Gypsy Accession by Clade", x = "Clade", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
