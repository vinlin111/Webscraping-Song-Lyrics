

# get beatles lyrics 
links <- read_html("http://www.metrolyrics.com/beatles-lyrics.html") %>% # lyrics site
  html_nodes("td a") # get all links to all songs
# get all the links to song lyrics
tibble(name = links %>% html_text(trim = TRUE) %>% str_replace(" Lyrics", ""), # get song names
       url = links %>% html_attr("href")) -> songs # get links
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

# get k = 5 shingles for "Eleanor Rigby"
best_song <- songs %>% filter(name == "Eleanor Rigby") # this song is the best
shingles <- tokenize_ngrams(best_song$lyrics, n = 5) # shingle the lyrics
# inspect results
head(shingles) %>%
  kable()

# get k = 3 shingles for "Eleanor Rigby"
shingles <- tokenize_ngrams(best_song$lyrics, n = 3)
# inspect results
head(shingles) %>%
  kable()

songs %>%
  mutate(shingles = (map(lyrics, tokenize_ngrams, n = 3))) -> songs

# create all pairs to compare then get the jacard similarity of each
# start by first getting all possible combinations
song_sim <- expand.grid(song1 = seq_len(nrow(songs)), song2 = seq_len(nrow(songs))) %>%
  filter(song1 < song2) %>% # don't need to compare the same things twice
  group_by(song1, song2) %>% # converts to a grouped table
  mutate(jaccard_sim = jaccard_similarity(songs$shingles[song1][[1]], 
                                          songs$shingles[song2][[1]])) %>%
  ungroup() %>%  # Undoes the grouping
  mutate(song1 = songs$name[song1],    
         song2 = songs$name[song2]) # store the names, not "id"
# inspect results
summary(song_sim)

# plot of similarity scores
ggplot(song_sim) + # use ggplot2
  geom_raster(aes(song1, song2, fill = jaccard_sim)) + # tile plot
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 4), 
        axis.text.y = element_text(size = 4),
        aspect.ratio = 1)

song_sim %>%
  filter(jaccard_sim > .5) %>% # only look at those with similarity > .5
  kable() # pretty table
