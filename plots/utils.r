library(scales)
library(ggplot2)
library(tidyverse)
library(reshape2)
library(argparser)

parse_arguments <- function() {
  p <- arg_parser('evaluation_parser')
  p <- add_argument(p, "--infile", help="csv inputfile with data to plot")
  p <- add_argument(p, "--outfile", help="name of pdf with plots")
  argv <- parse_args(p)
  return(argv)
}

get_melted_data <- function(data, remove.na = TRUE, normalize_value = TRUE, id.vars) {
  data.melted = pivot_longer(data, cols = !all_of(id.vars), names_to = "variable")
  if (remove.na) {
    data.melted <- filter(data.melted, !is.na(value))
  }
  if(normalize_value) {
    data.melted$value <- data.melted$value / 1000
  }
  return (data.melted)
}

get_plot_num_bytes_as_x <- function(data.melted, title, measurement, transformation, use_log_y = FALSE, column_for_faceting, y_axis_desc, print_min_max = FALSE) {
  data.melted <- data.melted %>% filter(variable == measurement)
  if(!missing(transformation)) {
    data.melted = transformation(data.melted)
  }

  #data.melted$num_bytes <- as.factor(data.melted$num_bytes)
  data.group_by <- group_by(data.melted, num_bytes, id)
  data.mean <- summarise(data.group_by, min = min(value), max = max(value), mean = mean(value))
  
  g <- ggplot(data.mean, aes(x=num_bytes, color = id, y=mean))
  g <- g + geom_point(size = 0.1)
  if(print_min_max) {
    g <- g + geom_pointrange(mapping = aes(ymin = min, ymax = max))
  }
  #g <- g + geom_line()
  g <- g + guides(color = guide_legend(override.aes = list(size=1)))
  g <- g + theme_bw()
  g <- g + theme(axis.text.x = element_text(angle = 90), strip.background = element_rect(fill = "white", colour = "white"))
  g <- g + labs(title = title, y = y_axis_desc, x = "num bytes")

  if(use_log_y) {
    g <- g + scale_y_continuous(trans = log10_trans())
  }
  #g + scale_x_discrete(breaks=c(0,100000,200000,300000))
    #breaks = trans_breaks("log2", function(x) 2^x),
  #labels = trans_format("log2", math_format(2^.x))
  #g = g + scale_x_continuous(trans = "log2", labels = trans_format("log2", math_format(2^.x)))
  return (g)
}

