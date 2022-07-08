## Pull Wikipedia table - list of Christmas songs

# Packages
library (rvest) # scrape
library (tidyverse) # clean
library (xml2) # geniusr patch dependency
library (geniusr) # geniusr


# Scrape christmas list

url <- "https://en.wikipedia.org/wiki/List_of_popular_Christmas_singles_in_the_United_States"

christmas_US <- url %>% read_html() %>% 
  html_table(header = TRUE, fill = TRUE)  %>% 
  .[[3]]

# run patch for genius r:

get_lyrics <- function (session) {
  lyrics <-  session %>% html_nodes(xpath = '//div[contains(@class, "Lyrics__Container")]')
  song <-  session %>% html_nodes(xpath = '//span[contains(@class, "SongHeaderVariantdesktop__")]') %>% html_text(trim = TRUE)
  artist <-  session %>% html_nodes(xpath = '//a[contains(@class, "SongHeaderVariantdesktop__Artist")]') %>% html_text(trim = TRUE)
  xml_find_all(lyrics, ".//br") %>% xml_add_sibling("p", "\n")
  xml_find_all(lyrics, ".//br") %>% xml_remove()
  lyrics <- html_text(lyrics, trim = TRUE)
  lyrics <- unlist(strsplit(lyrics, split = "\n"))
  lyrics <- grep(pattern = "[[:alnum:]]", lyrics, value = TRUE)
  if (is_empty(lyrics)) {
    return(tibble(line = NA, section_name = NA, section_artist = NA, 
                  song_name = song, artist_name = artist))
  }
  section_tags <- nchar(gsub(pattern = "\\[.*\\]", "", lyrics)) == 0
  sections <- geniusr:::repeat_before(lyrics, section_tags)
  sections <- gsub("\\[|\\]", "", sections)
  sections <- strsplit(sections, split = ": ", fixed = TRUE)
  section_name <- sapply(sections, "[", 1)
  section_artist <- sapply(sections, "[", 2)
  section_artist[is.na(section_artist)] <- artist
  tibble(line = lyrics[!section_tags], section_name = section_name[!section_tags], 
         section_artist = section_artist[!section_tags], song_name = song, 
         artist_name = artist)
}
assignInNamespace("get_lyrics", get_lyrics, "geniusr")

# Scrape

get_lyrics_search(artist_name ="Bloc Party", song_title = "Signs")


