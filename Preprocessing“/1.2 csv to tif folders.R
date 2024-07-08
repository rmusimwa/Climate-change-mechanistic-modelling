library(raster)

# Function to convert CSV to TIFF
convert_csv_to_tiff <- function(csv_file) {
  # Read the CSV file
  data <- read.csv(csv_file)
  
  # Check if required columns are present
  if (!all(c("latitude", "longitude", "so_mean") %in% colnames(data))) {
    cat("Required columns not found in CSV file:", csv_file, "\n")
    return(NULL)
  }
  
  # Create raster object from CSV data
  r <- rasterFromXYZ(data[, c("longitude", "latitude", "so_mean")], crs = CRS("+proj=longlat +datum=WGS84"))
  
  # Set the output file path for TIFF
  output_tiff <- sub("\\.csv$", ".tif", csv_file)
  
  # Write raster to TIFF file
  writeRaster(r, filename = output_tiff, format = "GTiff", overwrite = TRUE)
  
  # Print a message indicating success
  cat("GeoTIFF file created successfully:", output_tiff, "\n")
}

# Set the directory containing the CSV files
csv_folder <- "C:/Users/rutendo.musimwa/OneDrive - VLIZ/BAR ecological modelling/Scripts/Mackerel/Input-output_files Mackerel/Climate change/BioOracle New/Salinity/Salinity maps/SSP585/CSV"

# Get the list of CSV files in the folder
csv_files <- list.files(csv_folder, full.names = TRUE, pattern = "\\.csv$", recursive = TRUE)

# Loop through each CSV file and convert to TIFF
for (csv_file in csv_files) {
  convert_csv_to_tiff(csv_file)
}
