library(tidyverse)
library(lubridate)
library(ggrepel)

# options(scipen = 999) # turn off scientific notation

# colours form Set3 "#80b1d3", "#fdb462"

d <- d %>% mutate(created_date = as_date(as_datetime(created / 1000)),
                  next_event_date = as_date(as_datetime(next_event.time / 1000)),
                  created_year = year(created_date))

n_cumsum_year <- d %>% group_by(created_year) %>%
  summarise(n = n()) %>% 
  ungroup() %>% 
  mutate(cums = cumsum(n)) %>% 
  add_case(created_year = 2013, 
           n = NA, # 0 new groups in 2013
           cums = 1) %>% 
  arrange(created_year) %>% 
  ggplot() +
  geom_point(aes(created_year, n), colour = "#80b1d3", size = 4, show.legend = TRUE) +
  geom_segment(aes(x = created_year, 
                   xend = created_year, 
                   y = 0, 
                   yend = n), 
               size = 1, colour = "#80b1d3",
               show.legend = TRUE) +
  geom_path(aes(created_year, cums), colour = "#fdb462", size = 1, show.legend = TRUE) +
  theme_minimal(base_family = "serif", base_size = 10) +
  scale_x_continuous(breaks = 2012:2019) +
  scale_y_continuous(breaks = seq(0, 90, 10)) +
  labs(title = "W latach 2017 - 2018 powstało więcej grup\n niż od 2012 do 2016",
       caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com",
       x = "Rok powstania grupy",
       y = "Ilość grup [szt.]") +
  annotate("text", label = "Suma grup powstałych\nw danym roku", x = 2013.2,
           y = 15, colour = "#80b1d3", family = "serif") +
  annotate("text", label = "Skumulowana suma grup", x = 2016.5, y = 72,
           colour = "#fdb462", family = "serif")

# png("n_cumsum_year.png", width = 160, height = 100, units = "mm", res = 300)
# plot(n_cumsum_year) # Rys. 19. in chapter 5.1.4.
# dev.off()

# shorten groups' names
d$short_name <- sapply(d$name, FUN = function(x) 
  paste(strsplit(x," ")[[1]][1:4],collapse = " "))
d$short_name <- sapply(d$short_name, FUN = function(x) 
  gsub(" NA", "", x))
d$short_name

d$short_name[7] <- "Data Community Bydgoszcz"
d$short_name[64] <- "Pearson Poznań AI"    

next_event <- d %>%
  arrange(desc(created_date)) %>%
  mutate(short_name = factor(short_name, levels = short_name)) %>% 
  ggplot(aes(colour = city)) + 
  geom_segment(aes(x = short_name, 
                   xend = short_name, 
                   y = created_date, 
                   yend = next_event_date), 
               size = 1, show.legend = FALSE) +
  geom_point(aes(x = short_name, y = created_date, fill = "Założenie\ngrupy"),
             shape = 19, size = 3) +
  geom_point(aes(x = short_name, y = next_event_date, fill = "Zaplanowane\nspotkanie"),
             shape = 17, size = 3, show.legend = FALSE) +
  scale_colour_brewer(palette = "Set3", name = "Miasto") +
  scale_fill_manual(name = "Punkt\nw czasie", 
                    values = c("black", "black"),
                    guide = guide_legend(override.aes = list(shape = c(19, 17)))) +
  scale_y_date(date_breaks = "6 months", date_labels = "%Y-%m",
               date_minor_breaks = "6 months") +
  theme_minimal(base_family = "serif", base_size = 10) +
  theme(axis.text.x = element_text(angle = 90),
        legend.position = c(0.25, 0.4),
        legend.background = element_rect(colour = "white")) +
  labs(title = "Kolejne spotkania najczęściej planują grupy\no najdłuższym i najkrótszym stażu",
       caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com",
       x = "Skrócona nazwa grupy [do czterech pierwszych słów]",
       y = "Data") +
  coord_flip()

# d %>% group_by(created_year) %>% 
#   summarise(n = n(),
#             count_next_event = sum(!is.na(next_event_date)),
#             prop_next_event = count_next_event / n)
# 
# png("next_event.png", width = 160, height = 220, units = "mm", res = 300)
# plot(next_event) # Rys. 20. in chapter 5.1.4.
# dev.off()

box_created <- d %>% 
  ggplot(aes(x = fct_rev(reorder(city, created_date, min)), y = created_date)) +
  geom_boxplot() +
  geom_point(aes(colour = city), size = 4, alpha = 1/2) +
  # scale_fill_brewer(palette = "Set3") +
  scale_color_brewer(palette = "Set3", name = "") +
  scale_y_date(date_breaks = "6 months", date_labels = "%Y-%m",
               date_minor_breaks = "6 months") +
  theme_minimal(base_family = "serif", base_size = 10) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(
    title = "21A",
    subtitle = "Miasta różnią się czasem rozpoczęcia działalności grup\ni powstawaniem nowych grup w czasie",
       x = "",
       y = "Data założenia grupy") +
  coord_flip()

kruskal.test(created / 1000 ~ city, d %>% filter(city != "Gdynia" &
                                                   city != "Białystok" &
                                                   city != "Rzeszów" &
                                                   city != "Toruń"))

# d %>% group_by(city) %>% 
#   summarise(dif = max(created_date) - min(created_date),
#             n_gr = n(),
#             gr_per_dif = n_gr / dif,
#             dif_per_gr = dif / n_gr,
#             min = min(created_date)) %>%
#   arrange(dif_per_gr) %>% 
#   filter(dif_per_gr != 0) %>% 
#   ggplot(aes(x = min, y = dif_per_gr, label = city)) +
#   geom_smooth(method = "lm", se = FALSE,
#               colour = "gray") +
#   geom_point(size = 5) +
#   geom_text(nudge_y = 15, family = "serif") +
#   scale_x_date(date_breaks = "6 months", date_labels = "%Y-%m",
#                date_minor_breaks = "6 months") +
#   scale_y_continuous(limits = c(0, 300)) +
#   theme_minimal(base_family = "serif", base_size = 10) +
#   theme(axis.text.x = element_text(angle = 90)) +
#   labs(
#     title = "21B",
#     subtitle = "",
#     caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com",
#     x = "Data założenia pierwszej grupy w mieście",
#     y = "")

dif_n_gr <- d %>% group_by(city) %>% 
  summarise(dif = max(created_date) - min(created_date),
            n_gr = n(),
            gr_per_dif = n_gr / dif,
            dif_per_gr = dif / n_gr,
            min = min(created_date)) %>%
  arrange(dif_per_gr) %>% 
  filter(dif_per_gr != 0) %>% 
  ggplot(aes(x = dif, y = n_gr, label = city)) +
  geom_smooth(method = "lm", se = FALSE,
              colour = "gray") +
  geom_point(size = 2) +
  ggrepel::geom_text_repel(aes(label = city), family = "serif",
                           nudge_y = -1) +
  # geom_text(nudge_y = -1, family = "serif") +
  # scale_x_date(date_breaks = "6 months", date_labels = "%Y-%m",
  #              date_minor_breaks = "6 months") +
  scale_y_continuous(limits = c(0, 25)) +
  scale_x_reverse(limits = c(2500, 0)) +
  theme_minimal(base_family = "serif", base_size = 10) +
  labs(
    title = "21B",
    subtitle = "Ilość grup w mieście rośnie wraz z czasem od założenia pierwszej do ostatniej grupy
widoczna jest niska aktywność Łodzi i wysoka aktywność Warszawy
    
Uwaga: usunięto miasta z tylko jedną grupą",
    caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com",
    x = "Czas od założenia pierwszej do ostatniej grupy w mieście [ilość dni]",
    y = "Ilość grup w mieście [szt.]")

box_dif <- plot_grid(box_created, dif_n_gr, nrow =  2, rel_heights = c(1.7, 1))

# png("box_dif.png", width = 160, height = 180, units = "mm", res = 300)
# plot(box_dif) # Rys. 5. in chapter 5.1.
# dev.off()

names_time <- d %>% 
  mutate(name_AI = grepl("AI|Sztuczna|Artificial", name),
         name_ML = grepl("ml|ML|Machine", name),
         name_DS = grepl("Data Science", name, ignore.case = TRUE),
         name_BD = grepl("Big Data", name, ignore.case = TRUE),
         name_data = grepl("data", name, ignore.case = TRUE)) %>% 
  select(created_year, name, contains("name_")) %>% 
  group_by(created_year) %>% 
  summarise(n = n(),
            sum_AI = sum(name_AI),
            sum_ML = sum(name_ML),
            sum_DS = sum(name_DS),
            sum_BD = sum(name_BD),
            sum_data = sum(name_data),
            sum_other = 
              n -
              (sum_AI +
                 sum_ML +
                 sum_DS +
                 sum_BD)) %>%
  gather(-created_year, key = "name_type", value = "count") %>% 
  filter(name_type != "n" & name_type != "sum_data") %>% 
  ggplot() +
  geom_col(aes(x = created_year, y = count, fill = name_type),
           position = "stack", colour = "black") +
  theme_minimal(base_size = 10, base_family = "serif") +
  scale_fill_brewer(palette = "Set3", 
                    name = "Nazwa grupy zawiera słowa:",
                    labels = c("sztuczna inteligencja",
                               "big data",
                               "data science",
                               "uczenie maszynowe",
                               "inne")) +
  scale_x_continuous(breaks = 2012:2019) +
  labs(title = 'Termin "sztuczna inteligencja" pojawia się w nazwach grup od 2017 r.
termin "big data" jest najmniej popularny',
      caption = "Dane pobrane w dniu 04.06.2019 r. przez API meetup.com",
      x = "Rok powstania grupy",
      y = "Ilość grup [szt.]")

# png("names_time.png", width = 160, height = 80, units = "mm", res = 300)
# plot(names_time) # Rys. 5. in chapter 5.1.
# dev.off()
