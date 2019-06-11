library(tidyverse)

lodz <- ds_groups_29 %>% 
    select(city, country, created, description, id, join_mode, lat,
           link, lon, members, meta_category.name, name, next_event.id,
           next_event.name, next_event.time, next_event.utc_offset, 
           next_event.yes_rsvp_count, organizer.bio, organizer.id, 
           organizer.name, pro_network.name, pro_network.network_url, 
           pro_network.number_of_groups, pro_network.urlname,
           score, status, timezone, untranslated_city, urlname, 
           visibility, who)
bielsko <- ds_groups_bielsko %>% 
  select(city, country, created, description, id, join_mode, lat,
         link, lon, members, meta_category.name, name, next_event.id, 
         next_event.name, next_event.time, next_event.utc_offset, 
         next_event.yes_rsvp_count, organizer.bio, organizer.id, 
         organizer.name, pro_network.name, pro_network.network_url, 
         pro_network.number_of_groups, pro_network.urlname,
         score, status, timezone, untranslated_city, urlname, 
         visibility, who)
bialapodl <- ds_groups_bp %>% 
  select(city, country, created, description, id, join_mode, lat,
         link, lon, members, meta_category.name, name, next_event.id, 
         next_event.name, next_event.time, next_event.utc_offset, 
         next_event.yes_rsvp_count, organizer.bio, organizer.id, 
         organizer.name, pro_network.name, pro_network.network_url, 
         pro_network.number_of_groups, pro_network.urlname,
         score, status, timezone, untranslated_city, urlname, 
         visibility, who)
kosz <- ds_groups_kosz %>% 
  select(city, country, created, description, id, join_mode, lat,
         link, lon, members, meta_category.name, name, #next_event.id, 
         #next_event.name, next_event.time, next_event.utc_offset, 
         #next_event.yes_rsvp_count, 
         organizer.bio, organizer.id, 
         organizer.name, 
         #pro_network.name, pro_network.network_url, 
         #pro_network.number_of_groups, pro_network.urlname,
         score, status, timezone, untranslated_city, urlname, 
         visibility, who)
olsztyn <- ds_groups_olsztyn %>% 
  select(city, country, created, description, id, join_mode, lat,
         link, lon, members, meta_category.name, name, next_event.id, 
         next_event.name, next_event.time, next_event.utc_offset, 
         next_event.yes_rsvp_count, organizer.bio, organizer.id, 
         organizer.name, pro_network.name, pro_network.network_url, 
         pro_network.number_of_groups, pro_network.urlname,
         score, status, timezone, untranslated_city, urlname, 
         visibility, who)
poznan <- ds_groups_poznan %>% 
  select(city, country, created, description, id, join_mode, lat,
         link, lon, members, meta_category.name, name, next_event.id, 
         next_event.name, next_event.time, next_event.utc_offset, 
         next_event.yes_rsvp_count, organizer.bio, organizer.id, 
         organizer.name, pro_network.name, pro_network.network_url, 
         pro_network.number_of_groups, pro_network.urlname,
         score, status, timezone, untranslated_city, urlname, 
         visibility, who)
rzeszow <- ds_groups_rzeszow %>% 
  select(city, country, created, description, id, join_mode, lat,
         link, lon, members, meta_category.name, name, next_event.id, 
         next_event.name, next_event.time, next_event.utc_offset, 
         next_event.yes_rsvp_count, organizer.bio, organizer.id, 
         organizer.name, pro_network.name, pro_network.network_url, 
         pro_network.number_of_groups, pro_network.urlname,
         score, status, timezone, untranslated_city, urlname, 
         visibility, who)
wroclaw <- ds_groups_wroclaw %>% 
  select(city, country, created, description, id, join_mode, lat,
         link, lon, members, meta_category.name, name, next_event.id, 
         next_event.name, next_event.time, next_event.utc_offset, 
         next_event.yes_rsvp_count, organizer.bio, organizer.id, 
         organizer.name, pro_network.name, pro_network.network_url, 
         pro_network.number_of_groups, pro_network.urlname,
         score, status, timezone, untranslated_city, urlname, 
         visibility, who)
d <- bind_rows(lodz, bielsko, bialapodl, kosz, olsztyn, poznan, rzeszow, wroclaw) %>% 
  mutate(id = as.character(id)) %>% filter(country == "PL")

dim(distinct(d)) # 91, should be 86 - sth wrong

check <- d %>% distinct() %>% group_by(id) %>% summarise(n = n()) %>% filter(n > 1)

# View(filter(d, id %in% check$id)) # manual check

check$issue <- ifelse(test = check$id != "29772902",
                      yes = "members diff",
                      no = "next event yes diff")

# What's in 'check' df?
# Explanation:
# Data downloading was done during ~75 minute period.
# Due to groups overlap in .json files, 
# in four groups a person joined group,
# in one a person clicked rsvp for next event.
# It caused 91 distinct records for 86 groups (ids).
# Below we manually drop 5 records, leaving the 'updated'.

d <- d %>% distinct() %>% filter(!(id == "29772902" & next_event.yes_rsvp_count == 57),
                                 !(id == "20276026" & members == 572),
                                 !(id == "22845948" & members == 2247),
                                 !(id == "19126868" & members == 217),
                                 !(id == "18729763" & members == 3616))
 
cat(dim(d)) # 86 31 is OK
