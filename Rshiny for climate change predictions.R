library(shiny)
library(raster)
library(stars)
library(leaflet)
library(leafem)


base_map=leaflet() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addLegend("bottomright", title = "Habitat Suitability",
            colors = c("red", "orange", "yellow", "green", "blue", "darkblue"),
            labels = c("Low", "", "", "", "", "High"),
            opacity = 0.8)


# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
            body {
                background-color: #333333; /* dark grey */
                color: white; /* text color */
            }
            .text-box {
                background-color: black;
                color: white;
                padding: 10px;
                border-radius: 5px;
                white-space: pre-line; /* Preserve line breaks */
            }
        "))
  ),
  titlePanel("Species Habitat Suitability Maps"),
  fluidRow(
    column(
      width = 5,
      mainPanel(
        h3("Introduction"),
        p("This application displays habitat suitability maps for selected species from 2020 to 2100."),
        p("A red to orange to yellow to green to blue to dark blue colour scale is used to indicate habitat suitability:"),
        tags$ul(
          tags$li("red = low suitability"),
          tags$li("dark blue = high suitability"),
          tags$li("all suitability is between 0 and 1")
        ),
        p("A species, variable, and year can be selected using the options below."),
        selectInput("species", "Select Species:", choices = c("Atlantic Herring", "Atlantic Mackerel", "European Seabass")),
        selectInput("variable", "Select Variable:", choices = c("Temperature", "Salinity")),
        sliderInput("year", "Select Year:", min = 2020, max = 2090, value = 2020, step = 10)
      )
    ),
    column(
      width = 7,
      leafletOutput("map", width = "100%", height = "800px"),
      verbatimTextOutput("additional_text")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  output$map <- renderLeaflet({
    species <- input$species
    variable <- input$variable
    year <- input$year
    
    base_path <- switch(species,
                        "Atlantic Herring" = "~/climate/Herring/",
                        "Atlantic Mackerel" = "~/climate/Mackerel/",
                        "European Seabass" = "~/climate/Seabass/")
    
    file_path <- switch(variable,
                        "Temperature" = paste0(base_path, "Temperature/SSP585_", year, "_geotiff.tif"),
                        "Salinity" = paste0(base_path, "Salinity/SSP585_", year, "_geotiff.tif"))
    
    print(file_path)  # Add this line for debugging
    
    s <- read_stars(file_path)
    
    # Calculate the extent of the study area
    ext <- st_bbox(s)
    
    x_mean=mean(c(ext["xmin"], ext["xmax"]))
    y_mean=mean(c(ext["ymin"], ext["ymax"]))
    
    #coordinates need to be converted to lat lon
    p=st_sfc(st_point(c(x_mean, y_mean)), crs = 3857) %>% 
      st_transform(crs = 4326) %>% 
      st_coordinates()
    
    base_map %>%
      setView(lng = p[1],
              lat = p[2], zoom = 4.1) %>%
      leafem::addStarsImage(s, opacity = 0.8, project = F)
  })
  
  output$additional_text <- renderText({
    "We employed a mechanistic niche modelling approach that mathematically describes each species' specific ecological niche based on their responses to temperature and salinity. This approach, utilizing fuzzy logic principles, provided a more nuanced understanding than traditional methods. Climate prediction data from Bio-ORACLE (www.bio-oracle.org) was incorporated, focusing on sea surface temperature and salinity. Baseline data from 2010 established the foundation for the current scenario, while future projections spanned from 2020 to 2090, covering each decade under six Shared Socioeconomic Pathways (SSPs) – including the most extreme scenario, SSP585.

        Team 
        Our team comprises scientists and data managers from Flanders Marine Institute and Gent University: Rutendo Musimwa, Ward Standaert, Martha Stevens, Steven Pint and Gert Everaert"
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

