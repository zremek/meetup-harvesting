group_url <- "https://www.meetup.com/Spotkania-Entuzjastow-R-Warsaw-R-Users-Group-Meetup"
past <- file.path(group_url, 'events', 'past')
remDr$navigate(past)
links <- remDr$findElements(using = 'css selector', "a")
### not working