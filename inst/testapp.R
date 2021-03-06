library(shiny)
library(ggplot2)
library(plotly)

dfN <- data.frame(
  time_stamp = seq.Date(as.Date("2018-04-01"), as.Date("2018-07-30"), 1),
  val = runif(121, 100,1000),
  col = "green", stringsAsFactors = F
)
dfN[sample(1:10, size = 5, replace = F), "col"] <- "red"
# dfN[sample(1:10, size = 5, replace = F), ]$col <- "red"
# dfN[c(1,5,10,14,15), ]$col <- "red"
any(duplicated(dfN$time_stamp))

dfN[55, ]$col <- "orange"
dfN[69, ]$col <- "orange"
# dfN <- dfN[order(as.numeric(dfN$time_stamp)), ]

ui <- fluidPage(
  plotlyOutput("plot"),
  h4("click events"),
  verbatimTextOutput("clicked"),
  h4("SHIFT-click events"),
  verbatimTextOutput("shift_clicked"),
  h4("ALT-click events"),
  verbatimTextOutput("alt_clicked"),
  h4("selection events"),
  verbatimTextOutput("selection")
)

server <- function(input, output, session) {
  dfn_rv <- reactiveVal(NULL)
  
  output$plot <- renderPlotly({
    key <- highlight_key(dfN)
    dfn_rv(dfN)
    
    p <- ggplot() +
      geom_col(data = key, aes(x = plotly:::to_milliseconds(time_stamp), 
                               y = val, 
                               fill = I(col)))
    
    ggplotly(p, source = "Src") %>% 
      layout(xaxis = list(tickval = NULL, ticktext = NULL, type = "date")) %>% 
      highlight(off = "plotly_doubleclick", on = "plotly_click", #color = "blue",
                opacityDim = 0.3, selected = attrs_selected(opacity = 1))
  })
  
  
  output$clicked <- renderPrint({
    s <- event_data("plotly_click", source = "Src")
    s
  })
  output$shift_clicked <- renderPrint({
    s <- event_data("plotly_click_persist_on_shift", source = "Src")
    s
  })
  output$alt_clicked <- renderPrint({
    s <- event_data("plotly_alt_click", source = "Src")
    req(s)

    range_sel <- sort(as.numeric(range(s$key)))
    seq_fromto <- range_sel[1] : range_sel[2]

    # plotlyProxy("plot", session) %>%
      # plotlyProxyInvoke("restyle", list(opacity = 1), as.matrix(seq_fromto))
      # plotlyProxyInvoke("restyle", list(opacity = 1)
      # plotlyProxyInvoke("update", list(opacity = 1, marker.color = "purple")
                        # ,list(seq_fromto)
      # )
  
    # marker.color = "purple"
    plotlyProxy("plot", session) %>%
      plotlyProxyInvoke("restyle", list(opacity = 1, selectedpoints = seq_fromto))
    
    
    data_key = dfn_rv()[seq_fromto, ]
    print(data_key)
    s
  })
  output$selection <- renderPrint({
    s <- event_data("plotly_selected", source = "Src")
    s
  })
}

shinyApp(ui, server)
