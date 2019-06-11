library(moments)
library(tidyverse)

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
