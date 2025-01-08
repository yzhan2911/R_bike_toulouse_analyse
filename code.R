library(tidyverse)


bikesInfosTwoWeeks = read.csv("bikes_two_weeks.csv", header = TRUE, sep = ",")
str(bikesInfosTwoWeeks)
head(bikesInfosTwoWeeks)
names(bikesInfosTwoWeeks)
summary(bikesInfosTwoWeeks)

#########################
# pretaiter les donnees #
#########################
bikesInfosTwoWeeks <- bikesInfosTwoWeeks %>%
  mutate(
    timestamp = as.POSIXct(timestamp),
    hour = format(timestamp, "%H"),
    day = weekdays(timestamp)
  )

##################################################################################
# le nombre moyen de vélos disponibles et de stations vides par site et par jour #
##################################################################################

number_of_stations <- length(unique(bikesInfosTwoWeeks$number))
cat("Nombre de stations de vélo à Toulouse :", number_of_stations, "\n")

# Obtenir les informations des stations
stations_info = bikesInfosTwoWeeks %>%
  group_by(number,station_name,lat,lng) %>%
  summarise(
    bike_stands=mean(bike_stands),
    average_bike_stands=mean(available_bike_stands),
    average_bikes=mean(available_bikes)
  ) %>%
  arrange(number)

names(stations_info)

####################################
# Kmeans Clustering annalyse #
####################################
stations_data <- stations_info %>%
  ungroup() %>%
  select(lat, lng, average_bike_stands, average_bikes)
stations_data_scaled <- scale(stations_data)

set.seed(123) 
kmeans_result <- kmeans(stations_data_scaled, centers = 3)

kmeans_result

stations_info$cluster <- kmeans_result$cluster

head(stations_info)
ggplot(stations_info, aes(x = lng, y = lat, color = factor(cluster))) +
  geom_point(size = 3) +
  labs(title = "K-means Clustering of Stations", x = "Longitude", y = "Latitude", color = "Cluster") +
  theme_minimal()
#######################
# time seris annalyse #
#######################

ggplot(bikesInfosTwoWeeks, aes(x = timestamp, y = available_bikes)) +
  geom_line(color = "blue", linewidth = 1) +
  facet_wrap(~station_name, scales = "free_y") +
  labs(
    title = "Available Bikes Over Time for Each Station",
    x = "Timestamp",
    y = "Available Bikes"
  ) +
  theme_minimal()

################################################
# Analyse des heures pleines et heures creuses #
################################################



###################################################################
# Analyse du bilan des véhicules inutilisés et des stations vides #
###################################################################






################################################
# Analyse des points chauds (analyse spatiale) #
################################################




