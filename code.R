library(tidyverse)

bikesInfosTwoWeeks = read.csv("bikes_two_weeks.csv", header = TRUE, sep = ",")
str(bikesInfosTwoWeeks)
head(bikesInfosTwoWeeks)
names(bikesInfosTwoWeeks)
summary(bikesInfosTwoWeeks)

# Nombre unique de stations de vélo
number_of_stations <- length(unique(bikesInfosTwoWeeks$number))
cat("Nombre de stations de vélo à Toulouse :", number_of_stations, "\n")

# Obtenir les informations des stations
stations_info <- bikesInfosTwoWeeks %>%
    group_by(number,station_name,lat,lng) %>%
    summarise(
        bike_stands=mean(bike_stands),
        average_bike_stands=mean(available_bike_stands),
        average_bikes=mean(available_bikes)
    ) %>%
    arrange(number)

# Afficher et enregistrer les informations des stations
print(stations_info)
write.csv(stations_info, "stations_info_toulouse.csv", row.names = FALSE)
