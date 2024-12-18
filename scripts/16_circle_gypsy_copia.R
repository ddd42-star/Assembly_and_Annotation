library(dplyr)
library(circlize)
library(ComplexHeatmap)
library(ape)

setwd("C:/Users/dario/OneDrive/università/MA/Module Genomics/Genome and Transcriptome")

anno_data=read.gff("assembly.fasta.mod.EDTA.TEanno.gff3",na.strings = c(".","?"),GFF3 = T)
head(anno_data)

superfamily_counts <- table(anno_data$type)
print(superfamily_counts)

# Step 2: Identify the most abundant superfamily
most_abundant_superfamily <- names(superfamily_counts)[which.max(superfamily_counts)]

# Step 3: Filter out the most abundant superfamily from the dataframe
filtered_te_annotations <- anno_data[anno_data$type != most_abundant_superfamily, ]

superfamily_counts_2 <- table(filtered_te_annotations$type)

superfamily_counts_2 <- superfamily_counts_2[superfamily_counts_2 > 0]

most_abundant_superfamilies <- names(sort(superfamily_counts_2, decreasing = TRUE))

# Filter for only the most abundant superfamilies
#filtered_te_annotations <- anno_data[anno_data$type %in% most_abundant_superfamilies,]
filtered_te_annotations$seqid <- gsub("contig_","", filtered_te_annotations$seqid)

# Step 1: Filter out unwanted superfamilies from the original data
unwanted_superfamilies <- c("target_site_duplication", "repeat_region", "long_terminal_repeat")

filtered_te_annotations_2 <- filtered_te_annotations[!(filtered_te_annotations$type %in% unwanted_superfamilies), ]

superfamily_counts_3 <- table(filtered_te_annotations_2$type)

superfamily_counts_3 <- superfamily_counts_3[superfamily_counts_3 > 0]

most_abundant_superfamilies <- names(sort(superfamily_counts_3, decreasing = TRUE))

View(filtered_te_annotations_2)

# remove some coloumn
#filtered_te_annotations_2$seqid <- NULL

#filtered_te_annotations_2$source <- NULL

#filtered_te_annotations_2$phase <- NULL

# print most abundant superfamilies
print(most_abundant_superfamilies)


fai_data <- read.table("assembly.fasta.fai", sep="\t", header=FALSE)

# rename contig
fai_data$V1 <- gsub("contig_","", fai_data$V1)

# Sort the data by scaffold length (column V2) in descending order
fai_data_sorted <- fai_data[order(-fai_data$V2), ]

# Select the top 20 longest scaffolds
top_20_scaffolds <- fai_data_sorted[1:20, ]

# Check the top 20 scaffolds
print(top_20_scaffolds)


# Prepare ideogram data for the circos plot
ideogram_data <- data.frame(
  scaffold = top_20_scaffolds$V1,
  start = 1,
  end = top_20_scaffolds$V2
)

#only Retand and athila
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
cls_data$TE_ID <- gsub("_LTR$", "", cls_data$TE_ID)

# Check the changes to TE_ID_clean
head(cls_data$TE_ID)


# Extract TE_ID from 'attributes' column in 'filtered_te_annotations2'
filtered_te_annotations_2$TE_ID <- sub(".*Name=([^;]+);.*", "\\1", filtered_te_annotations_2$attributes)

filtered_te_annotations_2$TE_ID <- gsub("_INT$", "", filtered_te_annotations_2$TE_ID)

filtered_te_annotations_2$TE_ID <- gsub("_LTR$", "", filtered_te_annotations_2$TE_ID)

# Perform the join to add Clade information from 'cls_data' to 'filtered_te_annotations'
merged_data <- merge(filtered_te_annotations_2, cls_data, by = "TE_ID", all.x = TRUE)

# Check the merged data to verify the Clade and other information is added
head(merged_data)

merged_data_no_na <- merged_data[!is.na(merged_data$Clade), ]
head(merged_data_no_na)

# Initialize circos plot with the ideogram data
circos.clear()
circos.genomicInitialize(ideogram_data)

# Define colors for the superfamilies and plot the density
superfamily_colors <- c("green", "orange", "magenta", "blue", "yellow")
most_abundant_superfamilies <- c("Mutator_TIR_transposon",
                                 "Gypsy_LTR_retrotransposon","CACTA_TIR_transposon","Copia_LTR_retrotransposon")

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
clade_colors <- c("Retand" = "red", "Athila"='black')

# Prepare the clade data
clade_data <- merged_data_no_na[merged_data_no_na$Clade %in% c("Retand", 'Athila'), ]

# Select relevant columns: scaffold, start, end, and Clade
clade_data <- clade_data[, c("seqid", "start", "end", "Clade")]

# Check if 'start' and 'end' are numeric
clade_data$start <- as.numeric(clade_data$start)
clade_data$end <- as.numeric(clade_data$end)

# Check for out-of-bounds regions
max_scaffold_length <- max(merged_data_no_na$end)
if (any(clade_data$end > max_scaffold_length)) {
  cat("Warning: Some 'end' values exceed the maximum scaffold length.\n")
}

# Remove rows with NA or zero-length regions
clade_data <- clade_data[!is.na(clade_data$start) & !is.na(clade_data$end), ]
clade_data <- clade_data[clade_data$end > clade_data$start, ]


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
