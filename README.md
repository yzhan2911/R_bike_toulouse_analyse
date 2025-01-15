# R_bike_toulouse_analyse

## Zeng Yongjia && Zhang Yu

## Objectif du Projet

L'objectif principal de ce projet est d'explorer l’utilisation quotidienne des vélos partagés dans le réseau de Toulouse. Plus précisément, nous cherchons à identifier les tendances d’utilisation durant la semaine de Noël et à les comparer avec celles d’une semaine ordinaire. Cette analyse vise à mieux comprendre les comportements réels des usagers pendant une période festive.

## Données Utilisées

Pour cette étude, nous avons analysé les données d'utilisation des stations de vélos partagés à Toulouse sur deux semaines consécutives, du **15 décembre 2024 au 28 décembre 2024**, représentant un total de **476 642 observations**. 

Les données proviennent de l'**API JCDecaux**, qui fournit des informations détaillées sur le système de vélos partagés. Voici les principales caractéristiques des données utilisées :

- **Timestamp** : Enregistrements temporels avec une fréquence de 15 minutes.
- **Station_name, number** : Nom et numéro unique de chaque station.
- **Lat, lng, status** : Coordonnées géographiques et état de chaque station.
- **Bike_stands** : Nombre total d’emplacements dans chaque station.
- **Available_bike_stands** : Nombre d’emplacements disponibles à un instant donné.
- **Available_bikes** : Nombre de vélos disponibles à un instant donné.

## Méthodologie

Nous avons utilisé **R** pour effectuer les analyses, en exploitant ces données pour dégager des tendances significatives et visualiser les différences entre les périodes festives et non festives. Cette approche permet de mieux comprendre les dynamiques d’utilisation des vélos à Toulouse et d’identifier des opportunités pour optimiser leur gestion, en particulier durant les périodes spéciales comme Noël.
