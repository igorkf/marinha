
library(tidyverse)
library(rvest)
library(furrr)
library(tictoc)
library(js)

set.seed(1)

link <- sprintf("https://www.inscricao.marinha.mil.br/marinha/index_concursos.jsp?id_concurso=%d", 1:390L)


scrap <- function(x) {
  if(RCurl::url.exists(x) == T) {
    y <- read_html(x) %>%
      html_nodes(".header0 b") %>%
      html_text(trim = T)
  } else {
    y <- NA
  }
  
  return(y)
}



plan(multiprocess)
  
tic()
nomes_concurso <- furrr::future_map_chr(link, ~scrap(.x), .progress = T)
toc()


tab <- tibble(concurso = nomes_concurso, concurso2 = nomes_concurso) %>%
  mutate(concurso = paste0('<a href=', '"',  link, '"', '>', concurso, '</a>')) %>%
  filter(!is.na(concurso2) == T,
         str_detect(concurso2, "null") == F,
         str_detect(concurso2, "") == T
  ) %>%
  slice(nrow(.):1) %>% 
  select(concurso)


writexl::write_xlsx(tab, "C:/Users/Igor/Documents/trabalhos_R/concurso_marinha/base_marinha.xlsx")





