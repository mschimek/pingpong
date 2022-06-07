library(scales)
library(ggplot2)
library(tidyverse)
library(reshape2)
library(argparser)

source("utils.r")

options(tibble.width = Inf)



argv = parse_arguments()
infile = argv$infile
outfile = argv$outfile

# read data
data = read_csv(infile, guess_max = 2000)
# keys that identify a run
id.vars = c("iteration", "num_bytes", "id")
# clean data
data = filter(data, iteration > 4) # use a warm up run
data = filter(data, num_bytes %% 200 == 0) # use a warm up run
# transform from wide to long format
data.melted = get_melted_data(data, normalize_value = FALSE, id.vars = id.vars)



# start output in pdf
pdfname = argv$outfile
pdf(paste("", pdfname, ".pdf",sep=""), width=10, height=5)

g = get_plot_num_bytes_as_x(data.melted, title = "Overview all", "time", y_axis_desc = "time (ns)")
plot(g)
g = get_plot_num_bytes_as_x(filter(data.melted, grepl("dist", id)), title = "Overview only distributed (i.e. 2 compute nodes)", "time", y_axis_desc = "time (ns)")
plot(g)
g = get_plot_num_bytes_as_x(filter(data.melted, grepl("shared", id)), title = "Overview only shared (i.e. 1 compute nodes)", "time", y_axis_desc = "time (ns)")
plot(g)
g = get_plot_num_bytes_as_x(filter(data.melted, grepl("ompi", id)), title = "Overview only OpenMPI", "time", y_axis_desc = "time (ns)")
plot(g)
g = get_plot_num_bytes_as_x(filter(data.melted, grepl("intel", id)), title = "Overview only IntelMPI", "time", y_axis_desc = "time (ns)")
plot(g)
time_per_byte <- function(data) {
  data$value = data$value / as.integer(as.character(data$num_bytes))
  return (data)
}
byte_per_ns <- function(data) {
  data$value = as.integer(as.character(data$num_bytes)) / data$value
  return (data)
}
g = get_plot_num_bytes_as_x(data.melted, title = "Byte per nano-sec (superMUC OmniPath network with 100 Gbit/s ~ 13 Bytes/ns)", "time", y_axis_desc = "bytes per ns", transformation = byte_per_ns, use_log_y = TRUE)
plot(g)
data.melted = filter(data.melted, num_bytes <= 20000) # use a warm up run
g = get_plot_num_bytes_as_x(data.melted, title = "Small Message Lenghts", "time", y_axis_desc = "time (ns)", print_min_max = TRUE)
# transform from wide to long format
plot(g)
