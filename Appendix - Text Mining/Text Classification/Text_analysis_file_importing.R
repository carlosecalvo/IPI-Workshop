# Importing text files into R

library(here)
library(pdftools)
library(tidyverse)
library(tm)
library(tidytext)

# Using pdf_tools

clean_water <- pdf_text("Text_data/Clean Water Act.pdf") %>% str_split("\n")
head(clean_water)

clean_water_text <- clean_water[3:234] # Remove the first two pages that are cover pages

# Since the last two rows in every page are the same (i.e. the date and an empty row) we need to remove them. As well as the first two rows that contain the header.
water_act <- list()
for (i in 1:length(clean_water_text)) {
  j <- length(clean_water_text[[i]])
  k <- length(clean_water_text[[i]]) - 1
    water_act[[i]] <- clean_water_text[[i]][-j]
    water_act[[i]] <- water_act[[i]][-k]
    water_act[[i]] <- water_act[[i]][-3]
    water_act[[i]] <- water_act[[i]][-2]
    water_act[[i]] <- water_act[[i]][-1]
}

water <- stringi::stri_join_list(water_act, sep = "")

water_act_df <- as_tibble(water, text = text) %>% 
  mutate(linenumber = row_number(), text = value) %>%
  select(linenumber, text)

tidy_water_act <- water_act_df %>% 
  unnest_tokens(word, text)

# Now we can run tidytext analysis on this tidy data set

tidy_water_act %>%
  count(word, sort = TRUE) 

# Remove stop words
library(stopwords)

tidy_water_act <- tidy_water_act %>%
  anti_join(stop_words) 

tidy_water_act %>%
  count(word, sort = TRUE)

tidy_water_act %>%
  count(word, sort = TRUE) %>%
  filter(n > 100) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip()

# Using xpdf and tm

read <- readPDF(control = list(text = "-layout"))
document <- Corpus(URISource("Text_data/Clean Water Act.pdf"), readerControl = list(reader = read))
doc <- content(document[[1]])
head(doc)







# Using tm to read in word docs
## Needs to be saved as .doc or .txt, not .docx

library(antiword)
read_doc <- readDOC(engine = "antiword", AntiwordOptions = c(file = "Text_data/Clean Water Act.pdf") )
clean_air <- Corpus(URISource("Text_data/Clean Air Act.doc"), readerControl = list(reader = read_doc))
clean_air_doc <- content(clean_air[[1]])

