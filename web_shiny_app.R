library(rvest)
library(tidyverse)
library(stringr)
library(purrr)
library(scales)
library(ggplot2)
library(numbers)
library(textreuse) 
library(kableExtra)

all_artist_lyrics <- function(artist_name){
  artist <- artist_name %>%
    tolower()
  artist <- gsub(" ", "-", artist)

  
  url_start <- "http://www.songlyrics.com/"
  full_url <- paste0(url_start, artist, "-lyrics/")

  
 song_nodes <- full_url %>%
   read_html() %>%
   html_nodes("#colone-container .tracklist a")

 
 song_links <- html_attr(song_nodes, name="href")

 
 song_titles <- song_nodes %>%
   html_text()

 
 lyrics <- tibble()
 for (i in 1:length(song_links)){
   message(str_c("Scraping Song ", i, " of ", length(song_links)))
   
   #scrape the song lyrics
   lyrics_scraped <- song_links[i] %>%
     read_html %>%
     html_nodes("#songLyricsDiv") %>%
     html_text()
   
   # format song for dataframe
   song_title <- song_titles[i] %>%
     str_to_upper() %>%
     gsub("[^[:alnum:] ]", "", .) %>%
     gsub("[[:space:]]", " ", .)
   
   lyrics <- rbind(lyrics, tibble(text=lyrics_scraped, artist=artist_name, song=song_title))
 }
 return(lyrics)
}

write.csv(all_artist_lyrics("Katy Perry"), file = "katy_perry.csv")

