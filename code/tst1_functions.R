
#--------------------------------------------------------
# Global
#--------------------------------------------------------

# rm(list=ls())     # remove previous objects from workspace

library(tidyverse)
library(xtable)
library(ggrepel)

# figure properties
figscale <- 1
fw <- 5 # figure width
fh <- 5 # figure height
figdir <- "../plots/"
texfigdir <- "../plots/"

#--------------------------------------------------------------
# functions to print contingency tables
#--------------------------------------------------------------

# function takes an xtable
# and saves just the part between \begin{tabular} and \end{tabular}
printbl <- function(x, xname) {
  x %>% 
    str_split("\\{table\\}\\[ht\\]") %>% .[[1]] %>% .[2] %>% 
    str_split("\\\\end\\{table\\}") %>% .[[1]] %>% .[1] %>% 
    writeLines(xname)
}

#' create printable contingency tables from plot data
#' (using last_plot() by default)
plot2conting <- function(facetvar, xplot = last_plot()) {
  facetvars <- xplot %>% 
    .$data %>% 
    distinct_(facetvar) %>% 
    pull(1) %>% 
    as.character()
  for (v in facetvars) {
    xplot %>% 
      .$data %>% 
      mutate_(xvar = facetvar) %>% 
      mutate_at(vars(xvar), as.character) %>% 
      filter(xvar == v) %>% 
      xtabs(data = ., formula = logratio ~ stressTransAlt + promTransBiAlt) %>% 
      under(-2) %>% 
      xtable(digits = 2) %>% 
      print(sanitize.text.function = function(x){x}) %>% 
      printbl(paste0("../tables/", facetvar, v, ".txt"))
  }
}

# plot2conting("line.initial")

#--------------------------------------------------------------
# avoidance function & plot function (latest)
#--------------------------------------------------------------

avoid.fun <- function(dx, l.feat, m.feat) {
  
  # all potential combinations of features
  combis <- expand_(dx, c(m.feat, l.feat))
  
  #' P(L,M)
  p.lm <- dx %>% 
    count_(c(m.feat, l.feat)) %>% 
    ungroup() %>% 
    mutate(f.lm = n / sum(n, na.rm = T),
           n.lm = n,
           n = NULL) %>% 
    full_join(combis) %>% 
    replace_na(list(n.lm = 0, f.lm = 0))
  
  #' P(M)
  p.m <- dx %>% 
    count_(m.feat) %>% 
    ungroup() %>% 
    mutate(f.m = n / sum(n, na.rm = T),
           n.m = n,
           n = NULL)
  
  #' P(L)
  p.l <- dx %>% 
    count_(l.feat) %>% 
    ungroup() %>% 
    mutate(f.l = n / sum(n, na.rm = T),
           n.l = n,
           n = NULL)
  
  #' compute:
  #'     expected (frequency and counts) of l,m combination
  #'     logratio between observed and expected frequencies
  #'     confidence intervals for count ratio
  require(PropCIs)
  d.avoid <- p.lm %>%
    full_join(p.m) %>% 
    full_join(p.l) %>% 
    mutate(f.lm.exp = f.l * f.m,
           n.lm.exp = f.lm.exp * sum(n.lm, na.rm = T),
           logratio = log2(f.lm / f.lm.exp)) %>% 
    rowwise() %>% 
    mutate(cilow = oddsratioci.mp(n.lm.exp, n.lm, conf.level = .95)$conf.int[1] %>% log2(),
           ciup = oddsratioci.mp(n.lm.exp, n.lm, conf.level = .95)$conf.int[2] %>% log2()) %>% 
    ungroup() %>% 
    mutate_at(vars(cilow, ciup), funs(if_else(n.lm == 0, 0, .)))
  
  return(d.avoid)
  
}

avoid.plot <- function(d.avoid, groupvar) {
  xnudge <- -.1
  xsize <- 3
  d.avoid %>% ggplot() +
    aes(x = factor(promTransBiAlt), y = logratio,
        color = logratio < -2) +
    geom_point() +
    geom_text_repel(data = d.avoid %>% filter(n.lm == 0), # observed n if observed 0
                    aes(label = n.lm), nudge_x = 2*abs(xnudge), segment.alpha = 0,
                    fontface = "plain", size = xsize) +
    geom_text_repel(data = d.avoid %>% filter(n.lm == 0), # expected n if observed 0
                    aes(label = as.integer(n.lm.exp)),
                    nudge_x = 2*xnudge, segment.alpha = 0, size = xsize) +
    geom_text(data = d.avoid %>% filter(n.lm != 0), # observed n if observed !0
              aes(label = n.lm), nudge_x = abs(xnudge), hjust = 0,
              fontface = "plain", size = xsize) +
    geom_text(data = d.avoid %>% filter(n.lm != 0), # expected n if observed !0
              aes(label = as.integer(n.lm.exp)),
              nudge_x = xnudge, hjust = 1, size = xsize) +
    geom_hline(yintercept=c(-2, 2), linetype="dotted", alpha = .5) +
    geom_hline(yintercept=c(0), linetype="dashed", alpha = .5) +
    geom_errorbar(aes(ymin=cilow, ymax=ciup), width=0) +
    facet_grid(reformulate("stressTransAlt", groupvar), labeller = labeller(.rows = label_both)) +
    labs(x = "", y = "log ratio") +
    theme(legend.position="none",
          panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    scale_color_manual(values=c("black", "red")) %>% 
    return()
}

#--------------------------------------------------------------
# save plots with cairo
#--------------------------------------------------------------

ggsave.alt <- function(plot.lst = list(last_plot()), custom.name = "lastplot", path = figdir, height = fh, width = fw, ...) {
  if (is.null(names(plot.lst))) names(plot.lst) <- custom.name
  plot.names <- paste0(names(plot.lst), ".pdf")
  pmap(list(plot.names, plot.lst), ggsave,
       device=cairo_pdf, scale = figscale,
       height = height, path = path, width = width, ...)
}

#------------------------------------------------------------
# Print an array marking values below threshold in red
#------------------------------------------------------------

# sprintf function keeps trailing zeroes after rounding (1.104 > 1.10, instead of 1.1)
under <- function(x, thresh = .5) {
  x <- ifelse(x < thresh, paste0("\\textcolor{red}{\\bfseries", sprintf("%.2f", round(x,2)), "}"),
              sprintf("%.2f", round(x,2)))
  return(x)
}

#------------------------------------------------------------
# NLB songs: showLine() & downLine
#------------------------------------------------------------

# tested on: 2022-12-20
score_url <- function(ex) {
  
  # get numeric code for sample
  ex_png <- ex %>% 
    str_extract(pattern = 'NLB[0-9]*_*') %>%  
    str_replace('NLB(0*)', '') %>% 
    str_replace('_', '')
  
  # score page
  paste0("https://www.liederenbank.nl/image.php?recordid=", ex_png)
}

main_url <- function(ex) {
  
  # get numeric code for sample
  ex_png <- ex %>% 
    str_extract(pattern = 'NLB[0-9]*_*') %>%  
    str_replace('NLB(0*)', '') %>% 
    str_replace('_', '')
  
  # main song page
  paste0("https://www.liederenbank.nl/liedpresentatie.php?zoek=", ex_png)
}

# showLine()
showLine <- function(ex, score = F, audio = F,
                     cols = c("syllable", "SIpd", "SDpi"), datuak = datuak) {
  
  # text
  print(datuak[datuak$phraseID == ex, cols])
  
  if (score == T) {
    # score
    browseURL(score_url(ex),
              browser = "firefox")
  }
  
  if (audio == T) {
    # audio; take only the song ID, without the the NLB prefix and any leading zeroes.
    ex_mp3 <- gsub("NLB(0*)", "", unlist(strsplit(ex, split = "_"))[1]); ex_mp3
    browseURL(paste("http://www.liederenbank.nl/sound.php?recordid=", ex_mp3, sep = ""),
              browser = "firefox")    
  }
  
}

showLine_legacy <- function(ex, web = F, cols = c("syllable", "SIpd", "SDpi"), datuak = datuak) {
  
  # text
  print(datuak[datuak$phraseID == ex, cols])
  
  if (web == T) {
    # score
    ex_png <- paste(unlist(strsplit(ex, split = "_"))[-3], collapse = "_")
    browseURL(paste("http://www.liederenbank.nl/images_witchcraft/all/", ex_png, ".png", sep = ""), browser = "firefox")
    
    # audio; take only the song ID, without the the NLB prefix and any leading zeroes.
    ex_mp3 <- gsub("NLB(0*)", "", unlist(strsplit(ex, split = "_"))[1]); ex_mp3
    browseURL(paste("http://www.liederenbank.nl/sound.php?recordid=", ex_mp3, sep = ""), browser = "firefox")    
  }
  
}

# downLine()
downLine <- function(x, where = "../plotak/NLB/") {
  
  dir.create(where, showWarnings = FALSE)
  
  for (ex in x) {
    # score
    ex_png <- paste(unlist(strsplit(ex, split = "_"))[-3], collapse = "_")
    score <- paste("http://www.liederenbank.nl/images_witchcraft/all/", ex_png, ".png", sep = "")
    download.file(score, paste(where, ex, ".png", sep = ""))
    
    # recording
    # take only the song ID, without the the NLB prefix and any leading zeroes.
    ex_mp3 <- gsub("NLB(0*)", "", unlist(strsplit(ex, split = "_"))[1]); ex_mp3
    exEmbed <- paste("http://www.liederenbank.nl/sound.php?recordid=", ex_mp3, sep = "")
    rec <- readLines(exEmbed, warn = F) # read html source where recording is embedded
    a <- rec[grep("embed src", rec)] # find line where recording URL is located
    r <- regexec("embed src=\\\"(.*)\"  width", a)
    mp3url <- unlist(regmatches(a, r))[2] # extract recording URL
    download.file(mp3url, paste(where, ex, ".mp3", sep = "")) # download
  } 
  
}

