library(rvest) # web scraping
library(stringr) # string manipulation
library(dplyr) # data manipulation
library(tidyr) # tidy data
library(purrr) # functional programming
library(scales) # formatting for rmd output
library(ggplot2) # plots
library(numbers) # divisors function
library(textreuse) # detecting text reuse and document similarity
library(kableExtra)

get_links <- function(artist_name){
  artist_name %>%
    tolower() -> artist_name
  if (length(strsplit(artist_name, split = " ")[[1]]) > 1){
    name <- gsub(artist_name, pattern = " ", replacement = "-")
  } else {(artist_name -> name)}
  link <- paste0("http://metrolyrics.com/", name, "-lyrics.html")
  links <- read_html(link) %>%
    html_nodes("td a")
  tibble(name = links %>% html_text(trim = TRUE) %>% str_replace(" Lyrics", ""), # get song names
         url = links %>% html_attr("href")) -> songs
  return(songs)
}

get_links("katy perry")

# function to extract lyric text from individual sites
get_lyrics <- function(url){
  test <- try(url %>% read_html(), silent=T)
  if ("try-error" %in% class(test)) {
    # if you can't go to the link, return NA
    return(NA)
  } else
    url %>% read_html() %>%
    html_nodes(".verse") %>% # this is the text
    html_text() -> words
  
  words %>%
    paste(collapse = ' ') %>% # paste all paragraphs together as one string
    str_replace_all("[\r\n]" , ". ") %>% # remove newline chars
    return()
}

# get all the lyrics
# remove duplicates and broken links
songs %>%
  mutate(lyrics = (map_chr(url, get_lyrics))) %>%
  filter(nchar(lyrics) > 0) %>% #remove broken links
  group_by(name) %>% 
  mutate(num_copy = n()) %>%
  filter(num_copy == 1) %>% # remove exact duplicates (by name)
  select(-num_copy) -> songs 