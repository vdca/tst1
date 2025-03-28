#' ---
#' title: tsetting NL (s--p+)
#' subtitle: contrast word-initial vs word-internal contexts
#' author: varun@ni.eus
#' date: "`r format(Sys.time(), '%Y-%m-%d')`"
#' link-citations: true
#' output: 
#'   html_document:
#'     toc: false
#'     toc_depth: 2
#'     toc_float: false
#'     theme: "flatly"
#'     highlight: "textmate"
#'     css: "css/vignette.css"
#' ---

#+ setup, include=F
knitr::opts_chunk$set(fig.width=6, fig.height=5, echo=F, warning=F, message=F)

#-------------------------------------------------------------------------------
# Global
#-------------------------------------------------------------------------------

rm(list=ls())     # remove previous objects from workspace

library(DT)
library(tidyverse)

# create html links
esteka <- function(link, txt) {
  paste0('<a href="', link, '">', txt, '</a>')
}

source('tst1_functions.R')

#------------------------------------------------
# Load data
#------------------------------------------------

# original data available at: http://www.liederenbank.nl/mtc/
# further enriched with data from:
#   - ling. stress: http://tst-centrale.org/en/producten/lexica/e-lex/7-25
#   - musical prominence: derived using the music21 python toolkit
#   - word class (part of speech): http://celex.mpi.nl/
d <- read_tsv('../data/tst1_data.tsv')

# create ordered labels (=factors)
# for stress and prominence transitions.

# character codes
stresslev <- c("stress-", "stress=", "stress+")
promlev <- c("prom-", "prom=", "prom+")

# translation table (number to factor)
stress_labels <- tibble(stressTrans = c(-1, 0, 1),
                        stressTransAlt = factor(stresslev, levels = stresslev))
prom_labels <- tibble(promTransBi = c(-1, 0, 1),
                      promTransBiAlt = factor(promlev, levels = promlev))

# add character labels (as factor) to transition categories
d <- d %>% 
  left_join(stress_labels) %>%
  left_join(prom_labels)

# subset data

dfilter <- d %>%
  filter(melismaTrans == '00',
         content %in% c(1),
         line.initial == 0,
         word.initial %in% c(0, 1),
         lastLine == 0,     # forgot why I applied this filter; didn't discuss in paper
         stressTrans == -1, promTransBi == 1) %>% 
  mutate(word.initial = as.factor(word.initial))

#' filtered out: function words, melisma, first/last in line

#--------------------------------------------------------------
# subset data
#--------------------------------------------------------------

# functions: showLine() and downLine()
# showLine("NLB015552_01_1", T)
# downLine(SIhigh$phraseID, "../plotak/NLB/SIhigh/")

# d %>% 
#   filter(stressTrans == -1, promTransBi == 1,
#          line.initial == 0, word.initial == 1,
#          melismaTrans == '00', content == 1) %>% 
#   pull(phraseID)

# showLine(ex = 'NLB161811_01_4', score = T, datuak = d)

#-------------------------------------------------------------------------------
# labur
#-------------------------------------------------------------------------------

# testa

# a <- tibble(blip = rnorm(10),
# 						blop = rnorm(10))

# DT::datatable(a)

dout <- dfilter %>% 
  select(songID, phraseID, syllable, word, POS = clx.pos,
         word.initial,
         stressTransAlt, promTransBiAlt) %>% 
  mutate(phraseID = esteka(score_url(songID), phraseID),
         extra_info = esteka(main_url(songID), songID),
         songID = NULL)
	
dout %>%
  DT::datatable(filter = 'top', rownames = F, escape = F,
            extensions = c('Select', 'SearchPanes'),
            options = list(paging = T,
                           autoWidth = T,
                           scroller = T,
                           # scrollX = F,
                           pageLength = 100,
                           dom = 'Plfritip',
                           columnDefs = list(
                             # list(visible = F, targets = c(1:2)),
                             list(searchPanes = list(show = T),
                                  targets = c(3, 4)),
                             list(searchPanes = list(show = F),
                                  targets = c(0:2, 5:7))
                           )))

