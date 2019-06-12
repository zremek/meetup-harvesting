library(moments)
library(tidyverse)
library(stringr)

# pro networks

d %>% select(name, city, contains("pro")) %>% filter(!is.na(pro_network.name)) %>% View()

d %>% filter(name == "Poznań Women in Machine Learning & Data Science") %>% View  

# map_bar message

lon_lat_cities %>% select(city, members_sum, members_per_groups, groups_n) %>% arrange(desc(groups_n))

# members
summary(d$members)
skewness(d$members)
kurtosis(d$members)

by(d$members, d$city, summary)
by(d$members, d$city, skewness)

boxplot(d$members~d$city)
hist(d$members)
hist(d$members[d$city == "Warszawa"])
hist(d$members[d$city == "Kraków"])

d$name[d$members >= 3000]

# members vs population
# csv from http://swaid.stat.gov.pl/Dashboards/Miasta%20najwi%C4%99ksze%20pod%20wzgl%C4%99dem%20liczby%20ludno%C5%9Bci.aspx
city_pop <- read_csv("city_pop.csv", skip = 3)
city_pop[1,7] <- "Warszawa"
names(city_pop)[7] <- "city"
city_pop <- city_pop %>% mutate(ogolem_num = gsub("[[:space:]]", "", ogolem),
                                ogolem_num = parse_integer(ogolem_num)) 
city_pop <- left_join(lon_lat_cities, city_pop, "city") 
city_pop %>% 
  ggplot(aes(x = as.numeric(ogolem_num), y = as.numeric(members_sum), label = city, colour = city)) +
  geom_point() + 
  geom_text() +
  scale_y_log10() +
  scale_x_log10()

summary(lm(members_sum~ogolem_num, city_pop))
# cor(city_pop$members_sum, city_pop$groups_n, method = "pearson")
# cor(city_pop$members_sum, city_pop$groups_n, method = "kendall")
cor(city_pop$members_sum, city_pop$groups_n, method = "spearman")
# check https://stackoverflow.com/questions/7549694/adding-regression-line-equation-and-r2-on-graph

# rsvp vs members
d %>% filter(!is.na(next_event.id)) %>% dim()
d %>% filter(!is.na(next_event.id)) %>% 
  mutate(rspv_by_members = next_event.yes_rsvp_count / members) %>% 
  select(rspv_by_members) %>% summary()
d %>% filter(!is.na(next_event.id)) %>% 
  mutate(rspv_by_members = next_event.yes_rsvp_count / members) %>% 
  select(name, members, next_event.yes_rsvp_count, rspv_by_members) %>% arrange(members)
