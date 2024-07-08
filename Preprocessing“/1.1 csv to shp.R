# Install and load the 'sf' package
install.packages("sf")
library(sf)

# Set your working directory to the folder containing the CSV file
setwd("C:/Users/rutendo.musimwa/OneDrive - VLIZ/From LAPTOP user/Downloads")

# Read the CSV file into a data frame
csv_data <- read.csv("terrain_characteristics_c73a_56f5_3e23.csv")

# Remove rows with missing or non-numeric values in longitude and latitude columns
csv_data <- csv_data[!is.na(csv_data$longitude) & !is.na(csv_data$latitude), ]

# Convert the "longitude" and "latitude" columns to numeric
csv_data$longitude <- as.numeric(as.character(csv_data$longitude))
csv_data$latitude <- as.numeric(as.character(csv_data$latitude))
# Load libraries
library(ggplot2)
library(tidyr)  # For gather function

# Assuming data is a tibble with numeric columns for each year
# You may need to adjust column names based on your actual data
# I'm using gather to reshape the data for plotting

data_long <- gather(data, key = "Year", value = "Values", -1)

# Create box and whisker plot for each column on one plot
ggplot(data_long, aes(x = Year, y = Values, fill = Year)) +
  geom_boxplot(position = "dodge") +
  labs(title = "Box and Whisker Plots",
       x = "Year",
       y = "Values",
       subtitle = "Distribution Across Years") +
  theme_minimal()

# Remove rows with missing or non-numeric values after coercion
csv_data <- csv_data[!is.na(csv_data$longitude) & !is.na(csv_data$latitude), ]

# Create a simple feature (sf) object using the data frame
sf_object <- st_as_sf(csv_data, coords = c("longitude", "latitude"))

# Write the sf object to a shapefile
st_write(sf_object, "output_shapefile.shp")
