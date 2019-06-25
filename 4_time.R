library(lubridate)

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

d %>% group_by(created_year) %>% 
  summarise(n = n(),
            count_next_event = sum(!is.na(next_event_date)),
            prop_next_event = count_next_event / n)

png("next_event.png", width = 160, height = 220, units = "mm", res = 300)
plot(next_event) # Rys. 20. in chapter 5.1.4.
dev.off()
