#An Analysis of agriculuture dataset using the tidyverse in Rstudio 

#Skilled exhibited include, exporting a dataset into Rstudio, data cleaning and data visualization 


#First load the tidyverse

library(tidyverse)

#Import data into Rstudio

Zim_stats <- read_csv("C:/Users/miss blu/Downloads/Zim_stats.csv")

#Data Cleaning(changing column names, eliminating null values,selecting relevant data)

Stat_table<- data.frame(Zim_stats)
names(Stat_table)[10] <- "Percentage_of_total_country_area_cultivated"
names(Stat_table)[12] <- "Percentage_of_cultivated_land_irrigated"
names(Stat_table)[26] <- "Percentage_contribution_of_agriculture_to_GDP"
Statistics <- data.frame(Stat_table) %>% 
  select(Year,Percentage_of_total_country_area_cultivated,Percentage_of_cultivated_land_irrigated,Percentage_contribution_of_agriculture_to_GDP,Arable.land.area..1000.ha.) %>% 
  mutate(Arable_land_in_million_HA= Arable.land.area..1000.ha./1000)%>% 
  na.omit()

# Data Visualization using ggplot

Fig.1.0 <- Statistics %>% 
  ggplot(aes(x= Year, y= Arable_land_in_million_HA))+
  geom_line(color= "grey")+
  geom_point()+
  labs(title = "Arable land available in ZImbabwe by year", caption= "Fig.1.0:Arable land available peaked in 2007")+
  theme_minimal()
Fig.2.0 <-Statistics %>% 
  ggplot(aes(x=Year, y= Percentage_of_total_country_area_cultivated))+
  geom_bar(stat = "identity", width = 1.9,color="black", fill="black")+
  labs(title = "Percentage of total country area cultivated over time",caption= "Fig.2.0:Percentage of the total are of the country cultivated stagnated after 2007")+
  theme_minimal()
Fig.3.0 <- Statistics %>% 
  ggplot(aes(x= Year, y= Percentage_of_cultivated_land_irrigated))+
  geom_line(color= "grey")+
  geom_point()+
  coord_cartesian(ylim = c(4,7))+
  labs(title = "Changes in land cultivated under irrigation over time",caption= "Fig.3.0:Percentage of land cultivated under irrigation has been decreasing for the last 28 years")+
  theme_minimal()
Fig.4.0 <- Statistics %>% 
  ggplot(aes(x= Year, y= Percentage_contribution_of_agriculture_to_GDP))+
  geom_line(color= "grey")+
  geom_point()+
  labs(title = "Percentage contribution of agriculture to GDP by year",caption= "Fig.4.0:Percentage of agriculture contribution to the GDP has fluctuated over time")+
  theme_minimal()