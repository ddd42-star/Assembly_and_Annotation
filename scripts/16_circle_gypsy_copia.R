library(dplyr)
library(circlize)

setwd("C:/Users/dario/OneDrive/università/MA/Module Genomics/Genome and Transcriptome")

# Attempt to read using read.delim for flexible handling of whitespace separators
cls_data <- read.delim("Copia_sequences.fa.rexdb-plant.cls.tsv", header = TRUE)

# Check the first few rows and structure to confirm correct parsing
head(cls_data)
str(cls_data)

# Split the 'X.TE' column to get the TE_ID and Class_Family separately
cls_data <- cls_data %>%
  mutate(TE_ID = sapply(strsplit(X.TE, "#"), `[`, 1),
         Class_Family = sapply(strsplit(X.TE, "#"), `[`, 2))

# Remove the original 'X.TE' column if no longer needed
cls_data$X.TE <- NULL

# Reorder columns for clarity
cls_data <- cls_data[, c("TE_ID", "Class_Family", "Order", "Superfamily", "Clade", "Complete", "Strand", "Domains")]

# Check the result to ensure it's as expected
head(cls_data)
# Extract the numeric part of the TE_ID in cls_data (i.e., remove "_INT" or any other suffix)
cls_data$TE_ID <- gsub("_INT$", "", cls_data$TE_ID)

# Check the changes to TE_ID_clean
head(cls_data$TE_ID)
head(filtered_te_annotations$TE_ID)


# Extract TE_ID from 'attributes' column in 'filtered_te_annotations'
filtered_te_annotations$TE_ID <- sub(".*Name=([^;]+);.*", "\\1", filtered_te_annotations$attributes)

# Perform the join to add Clade information from 'cls_data' to 'filtered_te_annotations'
merged_data <- merge(filtered_te_annotations, cls_data, by = "TE_ID", all.x = TRUE)

# Check the merged data to verify the Clade and other information is added
head(merged_data)

merged_data_no_na <- merged_data[!is.na(merged_data$Clade), ]
head(merged_data_no_na)

# Plot the distribution of Clade
library(ggplot2)
ggplot(merged_data_no_na, aes(x = Clade)) + 
  geom_bar() + 
  theme_minimal() + 
  labs(title = "Distribution of Clade (Copia)", x = "Clade", y = "Count")

#only crm and athila
#and do big dna transposont tir
# Attempt to read using read.delim for flexible handling of whitespace separators
cls_data <- read.delim("Gypsy_sequences.fa.rexdb-plant.cls.tsv", header = TRUE)

# Check the first few rows and structure to confirm correct parsing
head(cls_data)
str(cls_data)

# Split the 'X.TE' column to get the TE_ID and Class_Family separately
cls_data <- cls_data %>%
  mutate(TE_ID = sapply(strsplit(X.TE, "#"), `[`, 1),
         Class_Family = sapply(strsplit(X.TE, "#"), `[`, 2))

# Remove the original 'X.TE' column if no longer needed
cls_data$X.TE <- NULL

# Reorder columns for clarity
cls_data <- cls_data[, c("TE_ID", "Class_Family", "Order", "Superfamily", "Clade", "Complete", "Strand", "Domains")]

# Check the result to ensure it's as expected
head(cls_data)
# Extract the numeric part of the TE_ID in cls_data (i.e., remove "_INT" or any other suffix)
cls_data$TE_ID <- gsub("_INT$", "", cls_data$TE_ID)

# Check the changes to TE_ID_clean
head(cls_data$TE_ID)
head(filtered_te_annotations$TE_ID)


# Extract TE_ID from 'attributes' column in 'filtered_te_annotations'
filtered_te_annotations$TE_ID <- sub(".*Name=([^;]+);.*", "\\1", filtered_te_annotations$attributes)

# Perform the join to add Clade information from 'cls_data' to 'filtered_te_annotations'
merged_data <- merge(filtered_te_annotations, cls_data, by = "TE_ID", all.x = TRUE)

# Check the merged data to verify the Clade and other information is added
head(merged_data)

merged_data_no_na <- merged_data[!is.na(merged_data$Clade), ]
head(merged_data_no_na)

# Plot the distribution of Clade
library(ggplot2)
ggplot(merged_data_no_na, aes(x = Clade)) + 
  geom_bar() + 
  theme_minimal() + 
  labs(title = "Distribution of Claden (Gypsy)", x = "Clade", y = "Count")

# Prepare ideogram data for the circos plot
ideogram_data <- data.frame(
  scaffold = top_20_scaffolds$V1,
  start = 0,
  end = top_20_scaffolds$V2
)

# Initialize circos plot with the ideogram data
circos.clear()
circos.genomicInitialize(ideogram_data)

# Define colors for the superfamilies and plot the density
superfamily_colors <- c("green", "orange", "magenta", "blue", "yellow")
most_abundant_superfamilies <- c('Gypsy_LTR_retrotransposon', "Copia_LTR_retrotransposon", "CACTA_TIR_transposon",
                                 "Mutator_TIR_transposon", "CL1_LINE_transposon" )

for (i in 1:length(most_abundant_superfamilies)) {
  # Filter the data for the current superfamily
  superfamily_data <- filtered_te_annotations_2[filtered_te_annotations_2$type == most_abundant_superfamilies[i],]
  
  # Select relevant columns: scaffold (V1), start (V4), and end (V5)
  superfamily_data <- superfamily_data[, c(1, 4, 5)]
  colnames(superfamily_data) <- c("scaffold", "start", "end")
  
  # Plot the density
  circos.genomicDensity(superfamily_data, col = superfamily_colors[i], track.height = 0.1, window.size = 1e6)
}

# Define colors for Clades
clade_colors <- c("CRM" = "red", "Athila"='black')

# Prepare the clade data
clade_specific_data <- merged_data_no_na[merged_data_no_na$Clade %in% c("CRM", 'Athila'), ]

# Select relevant columns: scaffold, start, end, and Clade
clade_specific_data <- clade_specific_data[, c("seqid", "start", "end", "Clade")]

# Check if 'start' and 'end' are numeric
clade_specific_data$start <- as.numeric(clade_specific_data$start)
clade_specific_data$end <- as.numeric(clade_specific_data$end)

# Check for out-of-bounds regions
max_scaffold_length <- max(merged_data_no_na$end)
if (any(clade_specific_data$end > max_scaffold_length)) {
  cat("Warning: Some 'end' values exceed the maximum scaffold length.\n")
}

# Remove rows with NA or zero-length regions
clade_specific_data <- clade_specific_data[!is.na(clade_specific_data$start) & !is.na(clade_specific_data$end), ]
clade_specific_data <- clade_specific_data[clade_specific_data$end > clade_specific_data$start, ]


# Loop through each unique clade (similar to the superfamily loop)
for (i in 1:length(unique(clade_data$Clade))) {
  # Get the current clade name
  current_clade <- unique(clade_data$Clade)[i]

  # Filter the data for the current clade
  clade_specific_data <- clade_data[clade_data$Clade == current_clade, ]
  
  # Select relevant columns: seqid (scaffold), start, end
  clade_specific_data <- clade_specific_data[, c("seqid", "start", "end")]
  colnames(clade_specific_data) <- c("scaffold", "start", "end")  # Ensure column names match circos expectations

  # Ensure that 'start' and 'end' are numeric
  clade_specific_data$start <- as.numeric(clade_specific_data$start)
  clade_specific_data$end <- as.numeric(clade_specific_data$end)

  # Remove rows where 'start' >= 'end' or missing values
  clade_specific_data <- clade_specific_data[clade_specific_data$end > clade_specific_data$start, ]

  # Add a dummy 'value' column to resolve the `ylim` error
  clade_specific_data$value <- 1

  # Plot the density for the current clade
  circos.genomicDensity(clade_specific_data, 
                        col = clade_colors[current_clade], 
                        track.height = 0.1, 
                        window.size = 1e6)  # Adjust window size if needed
}

superfamily_legend <- Legend(
  labels = most_abundant_superfamilies,
  legend_gp = gpar(fill = superfamily_colors),
  title = "Superfamilies",
  title_position = "topleft"
)

# Create Clade Legend
clade_legend <- Legend(
  labels = names(clade_colors),
  legend_gp = gpar(fill = clade_colors),
  title = "Clades",
  title_position = "topleft"
)

# Combine the legends into one and draw them
draw(superfamily_legend, x = unit(1, "npc") - unit(10, "mm"), y = unit(1, "npc") - unit(5, "mm"), just = c("right", "top"))
draw(clade_legend, x = unit(1, "npc") - unit(10, "mm"), y = unit(1, "npc") - unit(30, "mm"), just = c("right", "top"))

