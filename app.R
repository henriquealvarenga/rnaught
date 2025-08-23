# app.R
library(shiny)
library(ggplot2)

# ---- Helper: formato brasileiro (milhar=".", decimal=",") -------------------
fmt_br <- function(x, digits = 2, tol = 1e-9) {
  eh_inteiro <- is.finite(x) & abs(x - round(x)) < tol
  out <- ifelse(
    eh_inteiro,
    format(round(x), big.mark = ".", decimal.mark = ",", scientific = FALSE),
    format(round(x, digits), big.mark = ".", decimal.mark = ",",
           nsmall = digits, scientific = FALSE)
  )
  return(out)
}

# ---- UI ---------------------------------------------------------------------
ui <- fluidPage(
  tags$h2(HTML("Comparação de Cenários com diferentes valores de R<sub>0</sub> (R-naught)")),
  sidebarLayout(
    sidebarPanel(
      h4("Parâmetros Gerais"),
      sliderInput("ciclos", "Número de ciclos:",
                  min = 1, max = 15, value = 12, step = 1),
      numericInput("i0", "Casos iniciais (Ciclo 0):", value = 1, min = 0, step = 1),
      tags$small(em("Aviso: máximo de 15 ciclos para melhor performance.")),
      br(), br(),
      
      h4("Cenário A"),
      sliderInput("R0_A", "R₀ (A):", min = 0, max = 15, value = 1.5, step = 0.5),
      
      h4("Cenário B"),
      sliderInput("R0_B", "R₀ (B):", min = 0, max = 15, value = 3.0, step = 0.5),
      
      h4("Visualização"),
      radioButtons("tipoSerie", "Série exibida:",
                   choices = c("Acumulado" = "acum", "No ciclo" = "inc"),
                   selected = "acum", inline = TRUE),
      #checkboxInput("inteiros", "Arredondar valores para inteiros", value = FALSE),
      checkboxInput("logy", "Escala log no eixo Y", value = FALSE),
      
      br(),
      actionButton("simular", "Calcular / Atualizar", class = "btn-primary"),
      br(), br(),
      
      h4("Download"),
      radioButtons("csv_fmt", "Formato do CSV:",
                   choices = c("Formato internacional (decimal é o ponto final)" = "bruto",
                               "Formato BR (decimal é a vírgula)" = "ptbr"),
                   selected = "bruto"),
      downloadButton("baixar_csv", "Baixar CSV"),
      
      tags$hr(),
      # Assinatura no final do painel lateral
      tags$p(
        "Aplicativo desenvolvido por ", strong("Henrique Alvarenga"),
        tags$br(),
        tags$a(href = "https://www.henriquealvarenga.com",
               "henriquealvarenga.com", target = "_blank")
      )
    ),
    
    mainPanel(
      plotOutput("grafico", height = "460px"),
      br(),
      h4("Tabela de resultados (A x B)"),
      tableOutput("tabela")
    )
  )
)

# ---- SERVER -----------------------------------------------------------------
server <- function(input, output, session) {
  
  # Gera séries (incidência por ciclo e acumulado)
  gera_series <- function(R0, ciclos, i0) {
    inc <- numeric(ciclos + 1)
    inc[1] <- i0
    if (ciclos >= 1) {
      for (k in 2:(ciclos + 1)) inc[k] <- inc[k - 1] * R0
    }
    acum <- cumsum(inc)
    list(inc = inc, acum = acum)
  }
  
  dados <- eventReactive(input$simular, {
    # Clamping/validação
    ciclos <- max(1, min(15, as.integer(input$ciclos)))
    i0     <- max(0, as.numeric(input$i0))
    R0_A   <- max(0, min(15, as.numeric(input$R0_A)))
    R0_B   <- max(0, min(15, as.numeric(input$R0_B)))
    
    validate(
      need(!is.na(ciclos), "Número de ciclos inválido."),
      need(!is.na(i0), "Casos iniciais inválidos."),
      need(!is.na(R0_A) && !is.na(R0_B), "Valores de R₀ inválidos.")
    )
    
    A <- gera_series(R0_A, ciclos, i0)
    B <- gera_series(R0_B, ciclos, i0)
    
    if (isTRUE(input$inteiros)) {
      A$inc <- round(A$inc); A$acum <- round(A$acum)
      B$inc <- round(B$inc); B$acum <- round(B$acum)
    }
    
    df <- data.frame(
      Ciclo   = 0:ciclos,
      Inc_A   = A$inc,
      Inc_B   = B$inc,
      Acum_A  = A$acum,
      Acum_B  = B$acum
    )
    
    df$Dif_abs <- if (input$tipoSerie == "acum") (df$Acum_B - df$Acum_A) else (df$Inc_B - df$Inc_A)
    
    razao <- if (input$tipoSerie == "acum") {
      ifelse(df$Acum_A == 0, NA_real_, df$Acum_B / df$Acum_A)
    } else {
      ifelse(df$Inc_A == 0, NA_real_, df$Inc_B / df$Inc_A)
    }
    razao[!is.finite(razao)] <- NA_real_
    df$Razao_BsobreA <- razao
    
    df
  }, ignoreInit = TRUE)  # só roda após clicar no botão
  
  # ----- Gráfico
  output$grafico <- renderPlot({
    df <- req(dados())  # exige clique no botão
    serieA <- if (input$tipoSerie == "acum") df$Acum_A else df$Inc_A
    serieB <- if (input$tipoSerie == "acum") df$Acum_B else df$Inc_B
    ylab   <- if (input$tipoSerie == "acum") "Casos (acumulado)" else "Casos (no ciclo)"
    
    dflong <- rbind(
      data.frame(Ciclo = df$Ciclo, Valor = serieA, Cenário = "A"),
      data.frame(Ciclo = df$Ciclo, Valor = serieB, Cenário = "B")
    )
    
    p <- ggplot(dflong, aes(x = Ciclo, y = Valor, color = Cenário)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 2) +
      labs(
        title = paste0("Evolução de casos (", ifelse(input$tipoSerie == "acum", "Acumulado", "No ciclo"), ")"),
        subtitle = paste0("R₀ A = ", input$R0_A, " | R₀ B = ", input$R0_B,
                          " | Casos iniciais = ", input$i0),
        x = "Ciclo", y = ylab
      ) +
      theme_minimal(base_size = 14)
    
    if (isTRUE(input$logy)) p <- p + scale_y_log10()
    p
  })
  
  # ----- Tabela visível (formato BR, 2 casas)
  output$tabela <- renderTable({
    df <- req(dados())
    if (input$tipoSerie == "acum") {
      data.frame(
        Ciclo             = df$Ciclo,
        Acumulado_A       = fmt_br(df$Acum_A, digits = 2),
        Acumulado_B       = fmt_br(df$Acum_B, digits = 2),
        Diferenca_abs     = fmt_br(df$Dif_abs, digits = 2),
        Razao_B_sobre_A   = format(round(df$Razao_BsobreA, 2),
                                   big.mark = ".", decimal.mark = ",",
                                   scientific = FALSE, nsmall = 2)
      )
    } else {
      data.frame(
        Ciclo             = df$Ciclo,
        Incidencia_A      = fmt_br(df$Inc_A, digits = 2),
        Incidencia_B      = fmt_br(df$Inc_B, digits = 2),
        Diferenca_abs     = fmt_br(df$Dif_abs, digits = 2),
        Razao_B_sobre_A   = format(round(df$Razao_BsobreA, 2),
                                   big.mark = ".", decimal.mark = ",",
                                   scientific = FALSE, nsmall = 2)
      )
    }
  })
  
  # ----- Download CSV (bruto ou pt-BR), 2 casas decimais
  output$baixar_csv <- downloadHandler(
    filename = function() {
      serie <- if (input$tipoSerie == "acum") "acumulado" else "incidencia"
      paste0("tabela_", serie, "_R0A_", input$R0_A, "_R0B_", input$R0_B, ".csv")
    },
    content = function(file) {
      df <- req(dados())
      if (input$tipoSerie == "acum") {
        bruto <- data.frame(
          Ciclo         = df$Ciclo,
          Acumulado_A   = df$Acum_A,
          Acumulado_B   = df$Acum_B,
          Diferenca_abs = df$Dif_abs,
          Razao_B_sobre_A = df$Razao_BsobreA
        )
      } else {
        bruto <- data.frame(
          Ciclo         = df$Ciclo,
          Incidencia_A  = df$Inc_A,
          Incidencia_B  = df$Inc_B,
          Diferenca_abs = df$Dif_abs,
          Razao_B_sobre_A = df$Razao_BsobreA
        )
      }
      
      if (input$csv_fmt == "ptbr") {
        utils::write.table(
          round(bruto, 2), file, sep = ";", dec = ",",
          row.names = FALSE, col.names = TRUE, qmethod = "double"
        )
      } else {
        utils::write.csv(round(bruto, 2), file, row.names = FALSE)
      }
    }
  )
}

shinyApp(ui, server)