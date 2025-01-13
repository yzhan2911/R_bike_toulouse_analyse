library(tidyverse)
install.packages("dplyr")


bikesInfosTwoWeeks = read.csv("bikes_two_weeks.csv", header = TRUE, sep = ",")
str(bikesInfosTwoWeeks)
head(bikesInfosTwoWeeks)
names(bikesInfosTwoWeeks)
summary(bikesInfosTwoWeeks)

#########################
# pretaiter les donnees et separer en deux semaines
######################### 
bikesInfosTwoWeeks <- bikesInfosTwoWeeks %>%
  mutate(
    timestamp = as.POSIXct(timestamp),
    hour = format(timestamp, "%H"),  
    day = weekdays(timestamp)  
  )

# Séparer les données pour la semaine non Noël et Noël
bikesWeekNonNoel <- bikesInfosTwoWeeks %>%
  filter(timestamp >= as.POSIXct("2024-12-15") & timestamp <= as.POSIXct("2024-12-21 23:59:59"))
bikesWeekNoel <- bikesInfosTwoWeeks %>%
  filter(timestamp >= as.POSIXct("2024-12-22") & timestamp <= as.POSIXct("2024-12-28 23:59:59"))

View(bikesInfosTwoWeeks)
View(bikesWeekNoel)
View(bikesWeekNonNoel)

#########################
# extraire les infos de tous les station de velos ,ainsi le nombre de velo disponibles en moyen 
#########################
library(ggplot2)


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
View(stations_info)
names(stations_info)

ggplot(stations_info, aes(x = lng, y = lat)) +
  geom_point(size = 4, color = "blue") +   
  labs(
    title = "Positions of Stations",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),  
    legend.position = "right"   
  ) +
  coord_cartesian(xlim = c(1.35, 1.5))+   
  theme(aspect.ratio = 1)
 
#########################
# Clustering basé sur l'occupation des stations
#########################

stations_data <- stations_info %>%
  ungroup() %>%
  select(average_bikes)
stations_data_scaled <- scale(stations_data)

set.seed(123) 
kmeans_result <- kmeans(stations_data_scaled, centers = 3, nstart = 25)

stations_info$cluster <- kmeans_result$cluster
# 3 = rouge (stations les plus occupées), 2 et 1 = autres couleurs
cluster_colors <- c("1" = "green", "2" = "blue", "3" = "red")
view(stations_info)
head(stations_info)
ggplot(stations_info, aes(x = lng, y = lat, color = factor(cluster))) +
  geom_point(size = 4) +
  scale_color_manual(values = cluster_colors) +
  labs(title = "K-means Clustering of Stations", 
        x = "Longitude", 
        y = "Latitude", 
        color = "Cluster") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),   
    legend.position = "right"   
  ) +
  coord_cartesian(xlim = c(1.35, 1.5))+
  theme(aspect.ratio = 1)



#########################
# Analyse des heures pleines et heures creuses d'apres clusters 
#########################
names(stations_info)

bikes_with_clusters <- bikesInfosTwoWeeks %>%
  inner_join(stations_info %>% select(number, cluster), by = "number")
names(bikes_with_clusters) 

  ##Calculer les moyennes horaires pour chaque cluster
avg_bikes_hour_by_cluster <- bikes_with_clusters %>%
  group_by(cluster, hour) %>%
  summarise(mean_bikes = mean(available_bikes, na.rm = TRUE), .groups = "drop")


ggplot(avg_bikes_hour_by_cluster, aes(x = as.numeric(hour), y = mean_bikes, color = factor(cluster))) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  labs(
    title = "Évolution horaire des vélos disponibles par cluster",
    x = "Heure de la journée",
    y = "Nombre moyen de vélos disponibles",
    color = "Cluster"
  ) +
  scale_x_continuous(breaks = 0:23) +   
  scale_color_manual(values = c("1" = "blue", "2" = "green", "3" = "red")) +   
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)   
  )+
  theme(aspect.ratio = 1)
  
#########################
# time seris annalyse pour la semaine noel et la semaine non noel
#########################
names(stations_info)
names(bikesInfosTwoWeeks)

# le nombre moyen de vélos disponibles par heure pour chaque jour
avg_bikes_day_hour <- bikesWeekNoel %>%  ##bikesWeekNoel sinon
  group_by(day, hour) %>%
  summarise(mean_bikes = mean(available_bikes, na.rm = TRUE), .groups = "drop") %>%
  mutate(day = factor(day, levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")))


ggplot(avg_bikes_day_hour, aes(x = as.numeric(hour), y = mean_bikes, group = day)) +
  geom_line(color = "blue", linewidth = 1.5) +
  geom_point(size = 3, color = "red") +
  labs(
    title = paste("Hourly Evolution of Available Bikes for Chrismas week by Day for Station", station_number),
    x = "Hour of the Day",
    y = "Mean Available Bikes"
  ) +
  facet_wrap(~day, ncol = 3, scales = "free_y") +   
  theme_minimal() +
  scale_x_continuous(breaks = 0:23) +   
  theme(
    aspect.ratio = 1/1.5, 
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),  
    axis.text.x = element_text(angle = 45, hjust = 1)  
  )
 
avg_bikes_non_noel <- bikesWeekNonNoel %>%
  group_by(hour) %>% 
  summarise(mean_bikes = mean(available_bikes, na.rm = TRUE), .groups = "drop")
 
avg_bikes_noel <- bikesWeekNoel %>%
  group_by(hour) %>%
  summarise(mean_bikes = mean(available_bikes, na.rm = TRUE), .groups = "drop")
 
ggplot() +
  geom_line(data = avg_bikes_non_noel, aes(x = as.numeric(hour), y = mean_bikes, color = "Non Noël"), linewidth = 1.5) +
  geom_point(data = avg_bikes_non_noel, aes(x = as.numeric(hour), y = mean_bikes, color = "Non Noël"), size = 3) +
  geom_line(data = avg_bikes_noel, aes(x = as.numeric(hour), y = mean_bikes, color = "Noël"), linewidth = 1.5) +
  geom_point(data = avg_bikes_noel, aes(x = as.numeric(hour), y = mean_bikes, color = "Noël"), size = 3) +
  labs(
    title = "Hourly Evolution of Available Bikes: Noël vs Non Noël",
    x = "Hour of the Day",
    y = "Mean Available Bikes",
    color = "Week"
  ) +
  scale_x_continuous(breaks = 0:23) +  # Affiche toutes les heures
  scale_color_manual(values = c("Non Noël" = "blue", "Noël" = "orange")) +  # Couleurs personnalisées
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )+   
  theme(
    aspect.ratio = 1)









