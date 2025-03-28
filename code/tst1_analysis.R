
#--------------------------------------------------------
# Global
#--------------------------------------------------------

rm(list=ls())     # remove previous objects from workspace

library(tidyverse)
library(cowplot)
theme_set(theme_cowplot())
theme_set(theme_bw())
library(xtable)
library(ggrepel)

source('tst1_functions.R')

# figure properties
figscale <- 1
fw <- 5       # width
fh <- 5       # height
figdir <- "../plots/"
texfigdir <- "../plots/"

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

#--------------------------------------------------------------
# run main analysis
#--------------------------------------------------------------

# apply avoidance function once with all musical + linguistic predictors.
# then plot selected features as needed for comparison.
dfull <- d %>%
  mutate(stanzaInitial = (phraseN == 1) & (sylNp == 1)) %>% 
  filter(stanzaInitial == F,
         lastLine == 0,   # forgot why I applied this filter; didn't discuss in paper
         # sylPerW == 2,
         content %in% c(1,0)) %>%
  avoid.fun(c("stressTransAlt", "content", "word.initial"),
            c("promTransBiAlt", "melismaTrans", "line.initial"))

#--------------------------------------------------------------
# basic description
#--------------------------------------------------------------

# n of observations for each combination of linguistic/musical features
dfull %>% 
  count(n.lm, sort = T)

# out of 288 logical combinations,
# 107 combinations are absent.
# consider, e.g. that none of the 72 combinations
# which involve line.initial=1, and word.initial=0
# are observed (i.e. words are not split across lines)
dfull %>% 
  filter(line.initial==1, word.initial==0) %>% 
  summarise(sum(n.lm), n())

# there are 16 combinations with 1000+ observations
dfull %>% 
  count(n.lm) %>% 
  filter(n.lm > 1000)

#--------------------------------------------------------------
# avoidance plots and tables
#--------------------------------------------------------------

# compare control of word-initial syllables in:
# line-initial vs non-line-initial context.
# --> the transition from line n-1 to line n is not controlled
dfull %>% 
  filter(melismaTrans %in% c("00"),
         content == 1,
         word.initial == 1) %>% 
  avoid.plot(c("line.initial"))
ggsave.alt(custom.name = "line.initial", width = fw*1.5)
plot2conting("line.initial")
# size of each sub-sample (n of target syllables)
last_plot()$data %>% 
  group_by(line.initial) %>% 
  summarise(sum(n.lm))

# compare control of:
# word-initial vs non-word-initial syllables in:
# a non-line-initial context.
# the between-words transition is less controlled than the within-word trans
dfull %>% 
  filter(melismaTrans %in% c("00"),
         content == 1,
         line.initial == 0) %>% 
  avoid.plot(c("word.initial"))
ggsave.alt(custom.name = "word.initial", width = fw*1.5)
plot2conting("word.initial")
# size of each sub-sample (n of target syllables)
last_plot()$data %>% 
  group_by(word.initial) %>% 
  summarise(sum(n.lm))

# non-initial syllables in content words, no melismas
dfull %>% 
  filter(melismaTrans %in% c("00"),
         line.initial == 0,
         word.initial == 0,
         content == 1) %>% 
  avoid.plot(c("content"))
ggsave.alt(custom.name = "content1", width = fw*1.5)

# content vs function words
dfull %>% 
  filter(melismaTrans %in% c("00"),
         line.initial == 0,
         word.initial == 0) %>% 
  avoid.plot(c("content"))
ggsave.alt(custom.name = "content2", width = fw*1.5)
plot2conting("content")
# size of each sub-sample (n of target syllables)
last_plot()$data %>% 
  group_by(content) %>% 
  summarise(sum(n.lm))

# only content words, non-line-initial, non-word-initial.
# compare syllables preceded by a melisma (10) to those without (00)
dfull %>% 
  filter(content == 1,
         line.initial == 0,
         word.initial == 0,
         melismaTrans %in% c("00", "10")) %>% 
  avoid.plot(c("melismaTrans"))
# texfig(last_plot(), "melprev2.tex", xfw = fw*1.5); dev.off()
ggsave.alt(custom.name = "melprev2", width = fw*1.5)
plot2conting("melismaTrans")
# size of each sub-sample (n of target syllables)
last_plot()$data %>% 
  group_by(melismaTrans) %>% 
  summarise(sum(n.lm))

dfull %>% 
  filter(content == 1,
         line.initial == 0,
         word.initial == 0,
         melismaTrans %in% c("00", "01")) %>% 
  avoid.plot(c("melismaTrans"))
ggsave.alt(custom.name = "mel2", width = fw*1.5)

