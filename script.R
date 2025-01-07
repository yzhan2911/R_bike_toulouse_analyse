data = read.csv("bikes__toulouse.csv", header = TRUE, sep = ",")
str(data)
head(data)
names(data)
summary(data)
filteredData = subset(data, select = -c(timestamp) )

