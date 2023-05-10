library(plumber)
library(ggplot2)

#' @filter cors
cors <- function(req, res) {
res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
  res$setHeader("Access-Control-Allow-Methods", "*")
  res$setHeader("Access-Control-Allow-Headers", "*")
  res$status <- 200
  return(list())
  } else {
  plumber::forward()
  }
}

device_size <- function() {
  h_ <- 14
  w_ <- 14
  list(
    h = function() h_,
    w = function() w_,
    set_h = function(h) if (!is.null(h)) {h_ <<- as.numeric(h)},
    set_w = function(w) if (!is.null(w)) {w_ <<- as.numeric(w)}
  )
}

output_size <- device_size()

serializer_dynamic_svg <- function(..., type = "image/svg+xml") {
  serializer_device(
    type = type,
    dev_on = function(filename) {
      grDevices::svg(filename,
                     width = output_size$w(),
                     height = output_size$h())
    }
  )
}
register_serializer("svg", serializer_dynamic_svg)

#* @filter dynamic_size
function(req) {
  if (req$PATH_INFO == "/plotly") {
    output_size$set_w(req$args$width)
    output_size$set_h(req$args$height)
  }
  plumber::forward()
}

#* @post /plotly
#* @param width
#* @param height
#* @serializer svg
plotly <- function(a, b) {
# print(a) посмотреть в консоли переданную переменную 
# print(b) посмотреть в консоли переданную переменную
# plot(cars) work!!!

options(scipen=999)  # turn-off scientific notation like 1e+48
library(ggplot2)
theme_set(theme_bw())  # pre-set the bw theme.
data("midwest", package = "ggplot2")
# midwest <- read.csv("http://goo.gl/G1K41K")  # bkup data source

# Scatterplot
gg <- ggplot(midwest, aes(x=area, y=poptotal)) + 
  geom_point(aes(col=state, size=popdensity)) + 
  geom_smooth(method="loess", se=F) + 
  xlim(c(0, 0.1)) + 
  ylim(c(0, 500000)) + 
  labs(subtitle="Area Vs Population", 
       y="Population", 
       x="Area", 
       title="Scatterplot", 
       caption = "Source: midwest")

plot(gg)

}
