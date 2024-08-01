library(ggplot2)
library(dplyr)

the.path <- "/home/alex/Desktop/phd/phd_papers/papanastasatou_etal/"
file <- paste(the.path, "metaseqr_all_out_FFDEN_vs_FFctrl.txt.gz", sep = "/")
save <- paste(the.path, "volcano.tiff", sep = "/")

dataspace <- read.delim(file)

# Remove rows with NA in column 19
dataspace <- dataspace %>% filter(!is.na(dataspace[,19]))

# Define the threshold for highlighting genes
dataspace$threshold <- as.factor(abs(dataspace[,22]) > 1 & dataspace[,19] < 0.05)

# Categorize genes based on fold change and p-value
dataspace <- dataspace %>%
  mutate(threshold = case_when(
    abs(dataspace[,22]) > 1 & dataspace[,19] < 0.05 ~ ifelse(dataspace[,22] > 1, "Upregulated", "Downregulated"),
    TRUE ~ "Unregulated"
  ))

# Calculate -log10 p-value
dataspace$log10_p.value <- -log10(dataspace[,19])


##Construct the plot object
g = ggplot(data=dataspace, aes(x=dataspace[,22], y=log10_p.value , colour=threshold)) +
  geom_point(alpha=0.4, size=1) +
  theme_bw() + ggtitle("FFDEN vs FFctrl") + 
  #scale_y_discrete(limits = c(1,2,3,4,5,6)) + 
  #scale_x_discrete(limits = c(-4, -3, -2, -1, 0, 1, 2, 3, 4 )) + #limits according to data
  theme(legend.position="none") + 
  scale_colour_manual(values = c("Upregulated"= "red", "Downregulated"="blue",  "Unregulated"= "black")) +  #colours for upreg and downreg
  geom_vline(xintercept = c(-1,1), linetype="dashed") + #adds dashed lines for limits
  geom_hline(yintercept = 1.3, linetype="dashed") +
  xlab("log2 fold change") + 
  ylab("-log10 p-value")

ggsave(save, plot = g, dpi=300)