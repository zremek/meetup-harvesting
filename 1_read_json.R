#install.packages("jsonlite")
library(jsonlite)

ds_groups_29 <- fromJSON(txt = "meetup_api/ds_groups_29.json", flatten = TRUE)
table(ds_groups_29$untranslated_city)

ds_groups_poznan <- fromJSON(txt = "meetup_api/ds_groups_poznan.json", flatten = TRUE)
table(ds_groups_poznan$untranslated_city)

ds_groups_wroclaw <- fromJSON(txt = "meetup_api/ds_groups_wroclaw.json", flatten = TRUE)
table(ds_groups_wroclaw$untranslated_city)

ds_groups_rzeszow <- fromJSON(txt = "meetup_api/ds_groups_rzeszow.json", flatten = TRUE)
table(ds_groups_rzeszow$untranslated_city)

ds_groups_olsztyn <- fromJSON(txt = "meetup_api/ds_groups_olsztyn.json", flatten = TRUE)
table(ds_groups_olsztyn$untranslated_city)

ds_groups_szczecin <- fromJSON(txt = "meetup_api/ds_groups_szczecin.json", flatten = TRUE)
table(ds_groups_szczecin$untranslated_city) # outside PL only

ds_groups_bp <- fromJSON(txt = "meetup_api/ds_groups_bp.json", flatten = TRUE)
table(ds_groups_bp$untranslated_city)

ds_groups_kosz <- fromJSON(txt = "meetup_api/ds_groups_kosz.json", flatten = TRUE)
table(ds_groups_kosz$untranslated_city)

ds_groups_bielsko <- fromJSON(txt = "meetup_api/ds_groups_bielsko.json", flatten = TRUE)
table(ds_groups_bielsko$untranslated_city)

all_ids <- c(ds_groups_olsztyn$id, ds_groups_rzeszow$id[ds_groups_rzeszow$country == "PL"],
             ds_groups_wroclaw$id,ds_groups_poznan$id, ds_groups_29$id, ds_groups_bp$id,
             ds_groups_kosz$id, ds_groups_bielsko$id[ds_groups_bielsko$country == "PL"])
length(unique(all_ids)) 

### eventually 86 ids, as https://www.meetup.com/topics/data-science/pl/ states: 
### 86 groups in Poland, topic "data science" 2019-06-04