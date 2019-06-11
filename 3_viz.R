library(tidyverse)
library(RColorBrewer)
# install.packages("maptools")
# install.packages("rgeos")
# install.packages("sf")
library(rgeos)
library(maptools)
library(sf)
# install.packages("cowplot")
library(cowplot)

# fix cities' names
d <- d %>% 
  mutate(city = as.factor(city)) %>% mutate(city = fct_recode(.f = city,
                                                              Białystok = "Bialystok",
                                                              Gdańsk = "Gdansk",
                                                              Poznań = "Poznan",
                                                              Toruń = "Torun",
                                                              Warszawa = "Warsaw",
                                                              Wrocław = "Wroclaw"))


(cities_groups <- d %>% group_by(city) %>% summarise(groups_n = n(),
                                                     members_sum = sum(members)))

### compare share of education, firms and meetups between city areas  

# data from https://www.digitalpoland.org/assets/publications/mapa-polskiego-ai/map-of-the-polish-ai-2019-edition-i-report.pdf
(ai_firms <- read.csv("ai_firms_location.csv", encoding = "Win-1250", nrows = 7))

# data from https://bigdatatechwarsaw.eu/report-job-market-for-data-professionals-from-big-data-and-ai-to-bi/
# and own research (more in chapter 5.1.)
(edu_ds <- read.csv("obliczenia_edukacja_ds.csv", encoding = "Win-1250"))

(cities_groups <- cities_groups %>% mutate(area = fct_recode(.f = city,
                                                            Trójmiasto = "Gdańsk",
                                                            Trójmiasto = "Gdynia",
                                                            `a. katowicka` = "Katowice")) %>% 
    mutate(area = fct_other(f = area, drop = c("Białystok", "Lublin", "Łódź", "Rzeszów", "Toruń"),
                            other_level = "Inne")) %>% 
    mutate(area = as.character(area)))

(edu_ds <- edu_ds %>% mutate(area = fct_recode(.f = city,
                                               Trójmiasto = "Gdańsk",
                                               `a. katowicka` = "Gliwice")) %>% 
    mutate(area = fct_other(f = area, drop = c("Białystok", "Lublin", "Łódź", "Rzeszów", "Toruń"),
                            other_level = "Inne")) %>% 
    mutate(area = as.character(area)) %>% group_by(area) %>% summarise(n_edu = sum(n_edu)))

(groups_firms_edu <- cities_groups %>% group_by(area) %>% summarise(groups_n = sum(groups_n),
                                                                   members_sum = sum(members_sum)))
(groups_firms_edu <- left_join(groups_firms_edu, edu_ds))
ai_firms$area <- as.character(ai_firms$area)
(groups_firms_edu <- left_join(groups_firms_edu, ai_firms) %>% select(-firm_pct))
(groups_firms_edu_long <- groups_firms_edu %>% gather(groups_n, members_sum, n_edu, firm_n, 
                                                      key = type, value = n))
(groups_firms_edu <- groups_firms_edu %>% mutate(groups_pct = groups_n / sum(groups_n),
                                                 members_pct = members_sum / sum(members_sum),
                                                 edu_pct = n_edu / sum(n_edu),
                                                 firm_pct = firm_n / sum(firm_n)))
(groups_firms_edu_long_pct <- groups_firms_edu %>% select(area, contains("pct")) %>% 
    gather(contains("pct"), key = type, value = pct))
groups_firms_edu_long_pct$area <- factor(groups_firms_edu_long_pct$area,levels = groups_firms_edu_long_pct$area[c(1,3:7,2)])
# plot
ggplot(data = groups_firms_edu_long %>% filter(type != "members_sum")) + 
  geom_col(position = "dodge",
           aes(x = area, y = n, group = type, fill = type))

groups_firms_edu <- ggplot(data = groups_firms_edu_long_pct) + 
  geom_col(position = "dodge", 
           colour = "black",
           aes(x = area,
               y = pct, group = type, fill = type)) +
  labs(title = "Świat społeczny data science w Polsce koncentruje się w Warszawie",
       subtitle = "oraz ośrodkach miejskich powyżej 500 tys. mieszkańców",
       caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com i ze źródeł wymienionych w części 5.1.",
       x = "Ośrodek miejski",
       y = "Frakcja [każdy Wymiar = 1]") + 
  scale_fill_brewer(palette = "Set3", name = "Wymiar:",
                    labels = c("Kierunki\nstudiów\n[n = 27]","Firmy\n[n = 264]",
                               "Grupy\nmeetupowe\n[n = 86]", 
                               "Członkowie\ngrup\nmeetupowych\n[n = 48 351]")) +
  theme_minimal(base_family = "serif", base_size = 10) +
  theme(legend.position = "bottom", legend.direction = "horizontal", legend.box.just = "left")

groups_firms_edu
# save to good A4 fit size .png 
# max width = 160, height = 247

png("groups_firms_edu.png", width = 160, height = 130, units = "mm", res = 300)
plot(groups_firms_edu) # Rys. 4. in chapter 5.1.
dev.off()

### show locations of members, members by groups and groups 

shp <- sf::st_read(dsn = ".",layer = "gadm36_POL_1")

d %>% select(city, lon, lat) %>% View()
(lon_lat_cities <- d %>% group_by(city) %>% summarise(groups_n = n(),
                                                     members_sum = sum(members),
                                                     lon = median(lon),
                                                     lat = median(lat),
                                                     members_k = members_sum / 1000,
                                                     members_per_groups = members_sum / groups_n))

# map
map <- ggplot(data = lon_lat_cities) + geom_sf(data = shp, fill = "white") + 
  geom_point(aes(x = lon, y = lat, size = members_k, colour = city)) +
  coord_sf(datum = NA) + 
  scale_size_continuous(range = c(5, 15), name = "Suma członków\ngrup [tys. osób]") + 
  scale_colour_brewer(palette = "Set3") +
  theme_void(base_family = "serif", base_size = 10) +
  guides(colour = "none") +
  theme(legend.position = "bottom", legend.direction = "horizontal", 
        legend.box.just = "left", legend.spacing.x = unit(0, 'mm')) + 
  labs(title = "5A",
       subtitle = "Najmniejsza jest społeczność meetupów data science\nw Rzeszowie: 135 osób\nnajwiększa w Warszawie: 23 306",
       caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com")

# bar
bar <- ggplot(data = lon_lat_cities) +
  geom_col(aes(x = fct_rev(city), y = members_per_groups, fill = city),
           colour = "black") +
  scale_fill_brewer(palette = "Set3") +
  theme_minimal(base_family = "serif", base_size = 10) +
  guides(fill = "none") +
  labs(title = "5B",
       subtitle = "Najmniej osób na grupę\nprzypada w Lublinie: 97\nnajwięcej w Warszawie: 971",
       x = "",
       y = "Suma członków grup\nna jedną grupę [szt. osób]") +
  coord_flip()

# lollipop

d$short_name <- sapply(d$name, FUN = function(x) 
  paste(strsplit(x," ")[[1]][1:4],collapse = " "))
d$short_name <- sapply(d$short_name, FUN = function(x) 
  gsub(" NA", "", x))
d$short_name

d$short_name[7] <- "Data Community Bydgoszcz"
d$short_name[64] <- "Pearson Poznań AI"    


lolli <- d %>% arrange(city, -members) %>%
  mutate(short_name = factor(short_name, levels = short_name)) %>% 
ggplot(aes(x = fct_rev(short_name), y = members, colour = city)) + 
  geom_point(size = 4) + 
  geom_segment(aes(x = short_name, 
                   xend = short_name, 
                   y = 0, 
                   yend = members), 
               size = 1) +
  geom_hline(yintercept = median(d$members), linetype = "dashed", colour = "gray") +
  scale_y_log10() +
  scale_colour_brewer(palette = "Set3", name = NULL) +
  theme_minimal(base_family = "serif", base_size = 10) +
  labs(title = "Ponad połowa grup ma mniej niż 300 członków\ndwie grupy warszawskie są dziesięciokrotnie większe",
       caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com",
       x = "Skrócona nazwa grupy",
       y = "Ilość członków grupy [szt. osób, skala log10]") +
  annotate("text", label = "Mediana = 296,5", x = 58, y = 900, colour = "gray", family = "serif") +
  coord_flip() 

# combine map_bar
map_bar <- plot_grid(plot_grid(map, bar, ncol = 2, rel_widths = c(1.3, 1)))

png("map_bar.png", width = 160, height = 100, units = "mm", res = 300)
plot(map_bar) # Rys. 5. in chapter 5.1.
dev.off()

# lolli to PNG
png("lolli.png", width = 160, height = 220, units = "mm", res = 300)
plot(lolli) # Rys. 5. in chapter 5.1.
dev.off()





