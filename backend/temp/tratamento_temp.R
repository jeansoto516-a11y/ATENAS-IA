## - Code by: JEAN SOTO - jcsbarbosa@paschoalotto.com.br
## Script PARA TRATAMENTO DE INDICADORES

##############################################################
## INSTALAR PACOTES
##############################################################

# Execute apenas uma vez, se algum pacote ainda nao estiver instalado:
# install.packages("readxl")
# install.packages("openxlsx")
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("tidyr")
# install.packages("tools")

##############################################################
## BIBLIOTECAS
##############################################################

pacotes_necessarios <- c("readxl", "openxlsx", "dplyr", "stringr", "tidyr", "tools")
pacotes_faltando <- pacotes_necessarios[!sapply(pacotes_necessarios, requireNamespace, quietly = TRUE)]

if (length(pacotes_faltando) > 0) {
  stop(
    paste0(
      "Pacotes faltando: ",
      paste(pacotes_faltando, collapse = ", "),
      ". Execute antes: install.packages(c(\"",
      paste(pacotes_faltando, collapse = "\", \""),
      "\"))"
    )
  )
}

library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)
library(tidyr)
library(tools)

##############################################################
## CONFIGURACOES - ALTERAR SOMENTE ESTA PARTE
##############################################################

# Pasta onde esta o arquivo que sera lido.
pasta_arquivo <- "C:/Users/Samsung/OneDrive/Desktop/HUB 2026/ANALISES_R"

# Nome do arquivo que sera lido, com extensao.
# Exemplo: "indicadores_central.xlsx"
nome_arquivo_entrada <- "CO_LF.xlsx"

# Nome da aba que sera lida.
# Para ler uma aba: aba <- "ANALITICO"
# Para ler varias abas: aba <- c("CO_PJ", "OUTRA_ABA")
# Para ler todas as abas do arquivo Excel: aba <- c()
# Se deixar vazio, o script le a primeira aba do arquivo.
aba <- "ANALITICO"

# Nome do arquivo de saida.
# Se deixar vazio, o script cria automaticamente:
# ANALISE_<nome do arquivo original>.xlsx
nome_arquivo_saida <- "CO_LF_TRATADO"

# Colunas que identificam o intervalo da analise.
# Se deixar vazio, o script tenta encontrar automaticamente colunas de data/hora.
# Exemplos:
# colunas_intervalo <- c("DATA")
# colunas_intervalo <- c("DATA", "HORA")
colunas_intervalo <- c()

# Comparativos Plano x Real.
# Se deixar vazio, o script procura automaticamente pares como:
# "REC REAL" x "REC PLANO", "TMA REAL" x "TMA PLANO".
# Se quiser controlar manualmente, preencha assim:
# comparativos_plano_real <- c("REC REAL;REC PLANO", "TMA REAL;TMA PLANO")
comparativos_plano_real <- c()

# Indicadores onde MENOR que o plano e melhor.
# Para indicadores como TMA, TME, ABS, Fila, deixe o nome base aqui.
# O script procura esses textos no nome do indicador.
indicadores_menor_melhor <- c("TMA", "TME", "ABS", "FILA", "TEMPO")

# Analise do TSF ideal por valor fixo.
# Se deixar NA, essa analise nao sera criada.
# Exemplo: valor_tsf_ideal <- 80
coluna_tsf_ideal <- "TSF IDEAL"
valor_tsf_ideal <- 56

# Graficos editaveis no Excel.
# Se deixar vazio, o script cria graficos para todos os comparativos Plano x Real.
# Para escolher apenas alguns, informe o nome base do indicador:
# graficos_excel <- c("REC", "TMA", "TSF")
graficos_excel <- c()

# Como os graficos devem consolidar os intervalos repetidos.
# Use "media" para indicadores como TMA/TSF e "soma" para volume/REC.
agregacao_graficos <- "media"

# Analises extras.
# Cada item abaixo cria uma aba separada no Excel.
# Use ponto e virgula para informar varias colunas.
# Exemplos:
# analises_extras <- c("TMA REAL;REC REAL", "TMA REAL;REC REAL;HC REAL")
analises_extras <- c(
  #"TMA REAL;REC REAL"
)

##############################################################
## NAO ALTERAR DAQUI PARA BAIXO
##############################################################

normalizar_nome <- function(x) {
  x <- as.character(x)
  x <- str_trim(x)
  x <- str_squish(x)
  toupper(x)
}

nome_aba_excel <- function(x, existentes = character()) {
  x <- str_replace_all(x, "[\\[\\]\\*\\?/\\\\:]", "_")
  x <- str_squish(str_trim(x))
  if (is.na(x) || x == "") {
    x <- "Aba"
  }
  x <- substr(x, 1, 31)

  original <- x
  contador <- 1
  while (x %in% existentes) {
    sufixo <- paste0("_", contador)
    x <- paste0(substr(original, 1, 31 - nchar(sufixo)), sufixo)
    contador <- contador + 1
  }

  x
}

converter_numero <- function(x) {
  if (is.numeric(x)) {
    return(x)
  }

  x <- as.character(x)
  x <- str_trim(x)
  x <- str_replace_all(x, "%", "")
  tem_ponto <- str_detect(x, fixed("."))
  tem_virgula <- str_detect(x, fixed(","))

  x <- ifelse(
    tem_ponto & tem_virgula,
    str_replace_all(str_replace_all(x, "\\.", ""), ",", "."),
    x
  )
  x <- ifelse(!tem_ponto & tem_virgula, str_replace_all(x, ",", "."), x)

  suppressWarnings(as.numeric(x))
}

minimo_seguro <- function(x) {
  if (all(is.na(x))) {
    return(NA_real_)
  }

  min(x, na.rm = TRUE)
}

maximo_seguro <- function(x) {
  if (all(is.na(x))) {
    return(NA_real_)
  }

  max(x, na.rm = TRUE)
}

xml_escape <- function(x) {
  x <- as.character(x)
  x <- str_replace_all(x, "&", "&amp;")
  x <- str_replace_all(x, "<", "&lt;")
  x <- str_replace_all(x, ">", "&gt;")
  x <- str_replace_all(x, "\"", "&quot;")
  x
}

nome_planilha_formula <- function(sheet) {
  paste0("'", str_replace_all(sheet, "'", "''"), "'")
}

coluna_excel <- function(numero) {
  letras <- c()
  while (numero > 0) {
    resto <- (numero - 1) %% 26
    letras <- c(LETTERS[resto + 1], letras)
    numero <- (numero - resto - 1) %/% 26
  }

  paste0(letras, collapse = "")
}

referencia_excel <- function(sheet, col_ini, linha_ini, col_fim, linha_fim) {
  paste0(
    nome_planilha_formula(sheet),
    "!$",
    coluna_excel(col_ini),
    "$",
    linha_ini,
    ":$",
    coluna_excel(col_fim),
    "$",
    linha_fim
  )
}

compactar_pasta_xlsx <- function(pasta_xlsx, arquivo_saida) {
  arquivo_temp <- tempfile(fileext = ".xlsx")

  if (.Platform$OS.type == "windows" && nzchar(Sys.which("powershell"))) {
    comando <- paste0(
      "Compress-Archive -Path ",
      shQuote(file.path(normalizePath(pasta_xlsx, winslash = "\\"), "*")),
      " -DestinationPath ",
      shQuote(normalizePath(arquivo_temp, winslash = "\\", mustWork = FALSE)),
      " -Force"
    )
    status <- system2("powershell", c("-NoProfile", "-Command", comando), stdout = TRUE, stderr = TRUE)

    if (!file.exists(arquivo_temp)) {
      stop(paste("Falha ao recriar o arquivo xlsx:", paste(status, collapse = " ")))
    }
  } else {
    arquivos <- list.files(pasta_xlsx, recursive = TRUE, all.files = TRUE, no.. = TRUE)
    pasta_atual <- getwd()
    setwd(pasta_xlsx)
    on.exit(setwd(pasta_atual), add = TRUE)
    utils::zip(zipfile = arquivo_temp, files = arquivos)
  }

  file.copy(arquivo_temp, arquivo_saida, overwrite = TRUE)
}

separar_colunas_config <- function(texto) {
  colunas <- strsplit(texto, ";", fixed = TRUE)[[1]]
  str_squish(str_trim(colunas[colunas != ""]))
}

encontrar_coluna <- function(nome, nomes_reais) {
  alvo <- normalizar_nome(nome)
  nomes_norm <- normalizar_nome(nomes_reais)
  pos <- match(alvo, nomes_norm)

  if (is.na(pos)) {
    return(NA_character_)
  }

  nomes_reais[pos]
}

detectar_intervalos <- function(dados) {
  nomes <- names(dados)
  nomes_norm <- normalizar_nome(nomes)

  padroes_data <- c("DATA", "DT", "DIA", "PERIODO", "INTERVALO DATA")
  padroes_hora <- c("HORA", "HR", "HORARIO", "INTERVALO", "FAIXA", "TIME")

  eh_data <- Reduce(`|`, lapply(padroes_data, function(p) str_detect(nomes_norm, fixed(p))))
  eh_hora <- Reduce(`|`, lapply(padroes_hora, function(p) str_detect(nomes_norm, fixed(p))))

  candidatos <- nomes[eh_data | eh_hora]

  if (length(candidatos) == 0) {
    return(character())
  }

  unique(candidatos)
}

detectar_comparativos <- function(dados) {
  nomes <- names(dados)
  nomes_norm <- normalizar_nome(nomes)
  reais <- nomes[str_detect(nomes_norm, "\\bREAL\\b")]
  pares <- list()

  for (col_real in reais) {
    base <- normalizar_nome(col_real)
    base <- str_replace(base, "\\bREAL\\b", "")
    base <- str_squish(base)

    candidatos_plano <- c(
      paste(base, "PLANO"),
      paste(base, "PLAN"),
      paste(base, "META"),
      str_replace(normalizar_nome(col_real), "\\bREAL\\b", "PLANO")
    )

    nomes_norm <- normalizar_nome(nomes)
    pos <- match(candidatos_plano, nomes_norm)
    pos <- pos[!is.na(pos)]

    if (length(pos) > 0) {
      pares[[length(pares) + 1]] <- data.frame(
        indicador = base,
        real = col_real,
        plano = nomes[pos[1]],
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(pares) == 0) {
    return(data.frame(indicador = character(), real = character(), plano = character()))
  }

  bind_rows(pares) %>% distinct(real, plano, .keep_all = TRUE)
}

montar_comparativos_manuais <- function(config, dados) {
  if (length(config) == 0) {
    return(detectar_comparativos(dados))
  }

  pares <- list()

  for (item in config) {
    colunas <- separar_colunas_config(item)

    if (length(colunas) != 2) {
      warning(paste("Comparativo ignorado por formato invalido:", item))
      next
    }

    col_real <- encontrar_coluna(colunas[1], names(dados))
    col_plano <- encontrar_coluna(colunas[2], names(dados))

    if (is.na(col_real) || is.na(col_plano)) {
      warning(paste("Comparativo ignorado porque alguma coluna nao existe:", item))
      next
    }

    indicador <- normalizar_nome(col_real)
    indicador <- str_replace(indicador, "\\bREAL\\b", "")
    indicador <- str_squish(indicador)

    pares[[length(pares) + 1]] <- data.frame(
      indicador = indicador,
      real = col_real,
      plano = col_plano,
      stringsAsFactors = FALSE
    )
  }

  if (length(pares) == 0) {
    return(data.frame(indicador = character(), real = character(), plano = character()))
  }

  bind_rows(pares) %>% distinct(real, plano, .keep_all = TRUE)
}

regra_menor_melhor <- function(indicador) {
  indicador_norm <- normalizar_nome(indicador)
  any(str_detect(indicador_norm, fixed(normalizar_nome(indicadores_menor_melhor))))
}

classificar_resultado <- function(real, plano, menor_melhor = FALSE) {
  case_when(
    is.na(real) | is.na(plano) ~ "SEM DADO",
    real == plano ~ "IGUAL AO PLANO",
    menor_melhor & real < plano ~ "ACIMA DO PLANO",
    menor_melhor & real > plano ~ "ABAIXO DO PLANO",
    !menor_melhor & real > plano ~ "ACIMA DO PLANO",
    !menor_melhor & real < plano ~ "ABAIXO DO PLANO",
    TRUE ~ "SEM DADO"
  )
}

resumir_status <- function(status) {
  total <- length(status)
  acima <- sum(status == "ACIMA DO PLANO", na.rm = TRUE)
  abaixo <- sum(status == "ABAIXO DO PLANO", na.rm = TRUE)
  igual <- sum(status == "IGUAL AO PLANO", na.rm = TRUE)
  sem_dado <- sum(status == "SEM DADO", na.rm = TRUE)

  data.frame(
    Total = total,
    Acima_Plano = acima,
    Abaixo_Plano = abaixo,
    Igual_Plano = igual,
    Sem_Dado = sem_dado,
    Perc_Acima = ifelse(total > 0, acima / total, NA_real_),
    Perc_Abaixo = ifelse(total > 0, abaixo / total, NA_real_),
    stringsAsFactors = FALSE
  )
}

criar_resumo_comparativo <- function(dados, pares, colunas_intervalo) {
  linhas <- list()
  detalhes <- dados[, colunas_intervalo, drop = FALSE]

  for (i in seq_len(nrow(pares))) {
    indicador <- pares$indicador[i]
    col_real <- pares$real[i]
    col_plano <- pares$plano[i]
    menor_melhor <- regra_menor_melhor(indicador)

    real <- converter_numero(dados[[col_real]])
    plano <- converter_numero(dados[[col_plano]])
    diferenca <- real - plano
    perc_diferenca <- ifelse(!is.na(plano) & plano != 0, diferenca / plano, NA_real_)
    status <- classificar_resultado(real, plano, menor_melhor)

    detalhes[[paste0(indicador, " | Real")]] <- real
    detalhes[[paste0(indicador, " | Plano")]] <- plano
    detalhes[[paste0(indicador, " | Diferenca")]] <- diferenca
    detalhes[[paste0(indicador, " | Dif %")]] <- perc_diferenca
    detalhes[[paste0(indicador, " | Status")]] <- status

    resumo <- resumir_status(status)

    linhas[[length(linhas) + 1]] <- data.frame(
      Indicador = indicador,
      Coluna_Real = col_real,
      Coluna_Plano = col_plano,
      Regra = ifelse(menor_melhor, "Menor e melhor", "Maior e melhor"),
      Media_Real = mean(real, na.rm = TRUE),
      Media_Plano = mean(plano, na.rm = TRUE),
      Soma_Real = sum(real, na.rm = TRUE),
      Soma_Plano = sum(plano, na.rm = TRUE),
      Diferenca_Total = sum(real, na.rm = TRUE) - sum(plano, na.rm = TRUE),
      resumo,
      stringsAsFactors = FALSE
    )
  }

  resumo <- bind_rows(linhas)

  list(
    resumo = resumo,
    detalhes = detalhes
  )
}

criar_analise_extra <- function(dados, texto_config, colunas_intervalo) {
  colunas_pedidas <- separar_colunas_config(texto_config)
  colunas_encontradas <- sapply(colunas_pedidas, encontrar_coluna, nomes_reais = names(dados))
  colunas_encontradas <- unname(colunas_encontradas[!is.na(colunas_encontradas)])

  if (length(colunas_encontradas) == 0) {
    warning(paste("Analise extra ignorada. Nenhuma coluna encontrada:", texto_config))
    return(NULL)
  }

  colunas_saida <- unique(c(colunas_intervalo, colunas_encontradas))
  base <- dados[, colunas_saida, drop = FALSE]

  metricas <- list()
  for (coluna in colunas_encontradas) {
    valores <- converter_numero(dados[[coluna]])
    metricas[[length(metricas) + 1]] <- data.frame(
      Coluna = coluna,
      Total_Registros = length(valores),
      Registros_Com_Valor = sum(!is.na(valores)),
      Soma = sum(valores, na.rm = TRUE),
      Media = mean(valores, na.rm = TRUE),
      Minimo = minimo_seguro(valores),
      Maximo = maximo_seguro(valores),
      stringsAsFactors = FALSE
    )
  }

  if (length(colunas_intervalo) > 0) {
    agrupado <- dados %>%
      mutate(across(all_of(colunas_encontradas), converter_numero)) %>%
      group_by(across(all_of(colunas_intervalo))) %>%
      summarise(
        across(
          all_of(colunas_encontradas),
          list(Soma = ~sum(.x, na.rm = TRUE), Media = ~mean(.x, na.rm = TRUE)),
          .names = "{.col}_{.fn}"
        ),
        .groups = "drop"
      )
  } else {
    agrupado <- data.frame(Observacao = "Nenhuma coluna de intervalo foi definida/encontrada.")
  }

  list(
    base = base,
    metricas = bind_rows(metricas),
    agrupado = agrupado
  )
}

criar_analise_tsf_ideal <- function(dados, colunas_intervalo) {
  if (is.na(valor_tsf_ideal)) {
    return(NULL)
  }

  coluna_tsf <- encontrar_coluna(coluna_tsf_ideal, names(dados))

  if (is.na(coluna_tsf)) {
    warning(paste("Coluna do TSF ideal nao encontrada:", coluna_tsf_ideal))
    return(NULL)
  }

  valor <- converter_numero(dados[[coluna_tsf]])
  status <- case_when(
    is.na(valor) ~ "SEM DADO",
    valor < valor_tsf_ideal ~ "ABAIXO DO PLANO",
    valor >= valor_tsf_ideal ~ "ACIMA DO PLANO",
    TRUE ~ "SEM DADO"
  )

  detalhes <- dados[, colunas_intervalo, drop = FALSE]
  detalhes[[coluna_tsf]] <- valor
  detalhes[["TSF Ideal Informado"]] <- valor_tsf_ideal
  detalhes[["Diferenca"]] <- valor - valor_tsf_ideal
  detalhes[["Status"]] <- status

  resumo <- resumir_status(status)
  resumo <- data.frame(
    Indicador = coluna_tsf,
    Valor_Referencia = valor_tsf_ideal,
    Media_Real = mean(valor, na.rm = TRUE),
    Minimo_Real = minimo_seguro(valor),
    Maximo_Real = maximo_seguro(valor),
    resumo,
    stringsAsFactors = FALSE
  )

  list(
    coluna = coluna_tsf,
    resumo = resumo,
    detalhes = detalhes
  )
}

criar_base_graficos <- function(dados, pares, colunas_intervalo, analise_tsf = NULL) {
  specs <- list()
  linha_atual <- 1
  indicadores_graficos <- normalizar_nome(graficos_excel)
  agregacao <- tolower(agregacao_graficos)

  if (!(agregacao %in% c("media", "soma"))) {
    agregacao <- "media"
  }

  for (i in seq_len(nrow(pares))) {
    indicador <- pares$indicador[i]

    if (length(indicadores_graficos) > 0 && !(normalizar_nome(indicador) %in% indicadores_graficos)) {
      next
    }

    col_real <- pares$real[i]
    col_plano <- pares$plano[i]

    base <- data.frame(
      Intervalo = if (length(colunas_intervalo) > 0) {
        apply(dados[, colunas_intervalo, drop = FALSE], 1, paste, collapse = " - ")
      } else {
        seq_len(nrow(dados))
      },
      Real = converter_numero(dados[[col_real]]),
      Plano = converter_numero(dados[[col_plano]]),
      stringsAsFactors = FALSE
    )

    if (agregacao == "soma") {
      base <- base %>%
        group_by(Intervalo) %>%
        summarise(Real = sum(Real, na.rm = TRUE), Plano = sum(Plano, na.rm = TRUE), .groups = "drop")
    } else {
      base <- base %>%
        group_by(Intervalo) %>%
        summarise(Real = mean(Real, na.rm = TRUE), Plano = mean(Plano, na.rm = TRUE), .groups = "drop")
    }

    base <- base %>% filter(!is.na(Real) | !is.na(Plano))

    if (nrow(base) == 0) {
      next
    }

    specs[[length(specs) + 1]] <- list(
      titulo = paste(indicador, "Plano x Real"),
      linha_titulo = linha_atual,
      linha_cabecalho = linha_atual + 1,
      linha_inicio = linha_atual + 2,
      linha_fim = linha_atual + nrow(base) + 1,
      colunas_series = c("Real", "Plano"),
      dados = base
    )

    linha_atual <- linha_atual + nrow(base) + 4
  }

  if (!is.null(analise_tsf)) {
    base_tsf <- data.frame(
      Intervalo = if (length(colunas_intervalo) > 0) {
        apply(dados[, colunas_intervalo, drop = FALSE], 1, paste, collapse = " - ")
      } else {
        seq_len(nrow(dados))
      },
      Valor = converter_numero(dados[[analise_tsf$coluna]]),
      Limite = valor_tsf_ideal,
      stringsAsFactors = FALSE
    )

    base_tsf <- base_tsf %>%
      group_by(Intervalo) %>%
      summarise(Valor = mean(Valor, na.rm = TRUE), Limite = mean(Limite, na.rm = TRUE), .groups = "drop") %>%
      filter(!is.na(Valor))

    if (nrow(base_tsf) > 0) {
      names(base_tsf) <- c("Intervalo", "Real", "Plano")

      specs[[length(specs) + 1]] <- list(
        titulo = paste(analise_tsf$coluna, "x Limite Informado"),
        linha_titulo = linha_atual,
        linha_cabecalho = linha_atual + 1,
        linha_inicio = linha_atual + 2,
        linha_fim = linha_atual + nrow(base_tsf) + 1,
        colunas_series = c("Valor", "Limite"),
        dados = base_tsf
      )
    }
  }

  list(specs = specs)
}

criar_xml_chart <- function(spec, aba_dados) {
  categorias <- referencia_excel(aba_dados, 1, spec$linha_inicio, 1, spec$linha_fim)
  serie_1 <- referencia_excel(aba_dados, 2, spec$linha_inicio, 2, spec$linha_fim)
  serie_2 <- referencia_excel(aba_dados, 3, spec$linha_inicio, 3, spec$linha_fim)
  nome_serie_1 <- referencia_excel(aba_dados, 2, spec$linha_cabecalho, 2, spec$linha_cabecalho)
  nome_serie_2 <- referencia_excel(aba_dados, 3, spec$linha_cabecalho, 3, spec$linha_cabecalho)

  paste0(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" ',
    'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" ',
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">',
    '<c:chart><c:title><c:tx><c:rich><a:bodyPr/><a:lstStyle/><a:p><a:r><a:t>',
    xml_escape(spec$titulo),
    '</a:t></a:r></a:p></c:rich></c:tx></c:title>',
    '<c:plotArea><c:layout/><c:lineChart><c:grouping val="standard"/>',
    '<c:ser><c:idx val="0"/><c:order val="0"/><c:tx><c:strRef><c:f>',
    xml_escape(nome_serie_1),
    '</c:f></c:strRef></c:tx><c:cat><c:strRef><c:f>',
    xml_escape(categorias),
    '</c:f></c:strRef></c:cat><c:val><c:numRef><c:f>',
    xml_escape(serie_1),
    '</c:f></c:numRef></c:val></c:ser>',
    '<c:ser><c:idx val="1"/><c:order val="1"/><c:tx><c:strRef><c:f>',
    xml_escape(nome_serie_2),
    '</c:f></c:strRef></c:tx><c:cat><c:strRef><c:f>',
    xml_escape(categorias),
    '</c:f></c:strRef></c:cat><c:val><c:numRef><c:f>',
    xml_escape(serie_2),
    '</c:f></c:numRef></c:val></c:ser>',
    '<c:axId val="12345678"/><c:axId val="87654321"/></c:lineChart>',
    '<c:catAx><c:axId val="12345678"/><c:scaling><c:orientation val="minMax"/></c:scaling>',
    '<c:axPos val="b"/><c:tickLblPos val="nextTo"/><c:crossAx val="87654321"/><c:crosses val="autoZero"/></c:catAx>',
    '<c:valAx><c:axId val="87654321"/><c:scaling><c:orientation val="minMax"/></c:scaling>',
    '<c:axPos val="l"/><c:majorGridlines/><c:tickLblPos val="nextTo"/><c:crossAx val="12345678"/><c:crosses val="autoZero"/></c:valAx>',
    '</c:plotArea><c:legend><c:legendPos val="b"/></c:legend><c:plotVisOnly val="1"/></c:chart>',
    '<c:printSettings><c:headerFooter/><c:pageMargins b="0.75" l="0.7" r="0.7" t="0.75" header="0.3" footer="0.3"/><c:pageSetup/></c:printSettings>',
    '</c:chartSpace>'
  )
}

adicionar_graficos_editaveis_xlsx <- function(arquivo_xlsx, aba_graficos, aba_dados, specs) {
  if (length(specs) == 0) {
    return(invisible(FALSE))
  }

  pasta_temp <- tempfile("xlsx_graficos_")
  dir.create(pasta_temp, recursive = TRUE)
  unzip(arquivo_xlsx, exdir = pasta_temp)

  workbook_path <- file.path(pasta_temp, "xl", "workbook.xml")
  workbook_rels_path <- file.path(pasta_temp, "xl", "_rels", "workbook.xml.rels")
  workbook_xml <- paste(readLines(workbook_path, warn = FALSE), collapse = "")
  workbook_rels <- paste(readLines(workbook_rels_path, warn = FALSE), collapse = "")

  sheets <- regmatches(workbook_xml, gregexpr("<sheet[^>]*/>", workbook_xml))[[1]]
  sheet_tag <- sheets[str_detect(sheets, paste0('name="', xml_escape(aba_graficos), '"'))][1]

  if (is.na(sheet_tag)) {
    warning("Aba de graficos nao encontrada para inserir graficos editaveis.")
    return(invisible(FALSE))
  }

  sheet_rid <- str_match(sheet_tag, 'r:id="([^"]+)"')[, 2]
  rel_tag <- regmatches(workbook_rels, gregexpr(paste0('<Relationship[^>]+Id="', sheet_rid, '"[^>]*/>'), workbook_rels))[[1]][1]
  if (is.na(rel_tag)) {
    warning("Relacionamento da aba de graficos nao encontrado.")
    return(invisible(FALSE))
  }

  sheet_target <- str_match(rel_tag, 'Target="([^"]+)"')[, 2]
  sheet_target <- str_replace(sheet_target, "^/", "")
  sheet_path <- file.path(pasta_temp, "xl", sheet_target)

  if (!file.exists(sheet_path)) {
    sheet_path <- file.path(pasta_temp, "xl", "worksheets", basename(sheet_target))
  }

  sheet_file <- basename(sheet_path)
  sheet_rels_dir <- file.path(dirname(sheet_path), "_rels")
  dir.create(sheet_rels_dir, showWarnings = FALSE, recursive = TRUE)
  sheet_rels_path <- file.path(sheet_rels_dir, paste0(sheet_file, ".rels"))

  if (file.exists(sheet_rels_path)) {
    sheet_rels <- paste(readLines(sheet_rels_path, warn = FALSE), collapse = "")
  } else {
    sheet_rels <- '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"></Relationships>'
  }

  rel_matches <- str_match_all(sheet_rels, 'Id="rId([0-9]+)"')[[1]]
  rel_ids <- if (nrow(rel_matches) == 0) character() else rel_matches[, 2]
  novo_rel_id <- ifelse(length(rel_ids) == 0, 1, max(as.integer(rel_ids)) + 1)
  drawing_num <- length(list.files(file.path(pasta_temp, "xl", "drawings"), pattern = "^drawing[0-9]+\\.xml$")) + 1
  drawing_file <- paste0("drawing", drawing_num, ".xml")
  drawing_rid <- paste0("rId", novo_rel_id)

  sheet_rels <- str_replace(
    sheet_rels,
    "</Relationships>",
    paste0(
      '<Relationship Id="',
      drawing_rid,
      '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/',
      drawing_file,
      '"/></Relationships>'
    )
  )
  writeLines(sheet_rels, sheet_rels_path, useBytes = TRUE)

  sheet_xml <- paste(readLines(sheet_path, warn = FALSE), collapse = "")
  if (!str_detect(sheet_xml, "<drawing ")) {
    sheet_xml <- str_replace(sheet_xml, "</worksheet>", paste0('<drawing r:id="', drawing_rid, '"/></worksheet>'))
    writeLines(sheet_xml, sheet_path, useBytes = TRUE)
  }

  charts_dir <- file.path(pasta_temp, "xl", "charts")
  drawings_dir <- file.path(pasta_temp, "xl", "drawings")
  drawing_rels_dir <- file.path(drawings_dir, "_rels")
  dir.create(charts_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(drawings_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(drawing_rels_dir, showWarnings = FALSE, recursive = TRUE)

  chart_start <- length(list.files(charts_dir, pattern = "^chart[0-9]+\\.xml$")) + 1
  anchors <- c()
  drawing_rels_items <- c()

  for (i in seq_along(specs)) {
    chart_num <- chart_start + i - 1
    chart_file <- paste0("chart", chart_num, ".xml")
    chart_rid <- paste0("rId", i)
    writeLines(criar_xml_chart(specs[[i]], aba_dados), file.path(charts_dir, chart_file), useBytes = TRUE)

    drawing_rels_items <- c(
      drawing_rels_items,
      paste0(
        '<Relationship Id="',
        chart_rid,
        '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart" Target="../charts/',
        chart_file,
        '"/>'
      )
    )

    coluna <- ifelse((i - 1) %% 2 == 0, 0, 8)
    linha <- 1 + floor((i - 1) / 2) * 18

    anchors <- c(
      anchors,
      paste0(
        '<xdr:twoCellAnchor editAs="oneCell"><xdr:from><xdr:col>',
        coluna,
        '</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>',
        linha,
        '</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from><xdr:to><xdr:col>',
        coluna + 7,
        '</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>',
        linha + 16,
        '</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:to><xdr:graphicFrame macro=""><xdr:nvGraphicFramePr><xdr:cNvPr id="',
        i + 1,
        '" name="Grafico ',
        i,
        '"/><xdr:cNvGraphicFramePr/></xdr:nvGraphicFramePr><xdr:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/></xdr:xfrm><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/chart"><c:chart xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="',
        chart_rid,
        '"/></a:graphicData></a:graphic></xdr:graphicFrame><xdr:clientData/></xdr:twoCellAnchor>'
      )
    )
  }

  drawing_xml <- paste0(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<xdr:wsDr xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" ',
    'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" ',
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">',
    paste0(anchors, collapse = ""),
    '</xdr:wsDr>'
  )
  writeLines(drawing_xml, file.path(drawings_dir, drawing_file), useBytes = TRUE)

  drawing_rels_xml <- paste0(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    paste0(drawing_rels_items, collapse = ""),
    '</Relationships>'
  )
  writeLines(drawing_rels_xml, file.path(drawing_rels_dir, paste0(drawing_file, ".rels")), useBytes = TRUE)

  content_types_path <- file.path(pasta_temp, "[Content_Types].xml")
  content_types <- paste(readLines(content_types_path, warn = FALSE), collapse = "")

  if (!str_detect(content_types, paste0("drawings/", drawing_file))) {
    content_types <- str_replace(
      content_types,
      "</Types>",
      paste0(
        '<Override PartName="/xl/drawings/',
        drawing_file,
        '" ContentType="application/vnd.openxmlformats-officedocument.drawing+xml"/></Types>'
      )
    )
  }

  for (i in seq_along(specs)) {
    chart_file <- paste0("chart", chart_start + i - 1, ".xml")
    if (!str_detect(content_types, paste0("charts/", chart_file))) {
      content_types <- str_replace(
        content_types,
        "</Types>",
        paste0(
          '<Override PartName="/xl/charts/',
          chart_file,
          '" ContentType="application/vnd.openxmlformats-officedocument.drawingml.chart+xml"/></Types>'
        )
      )
    }
  }

  writeLines(content_types, content_types_path, useBytes = TRUE)
  compactar_pasta_xlsx(pasta_temp, arquivo_xlsx)
  invisible(TRUE)
}

aplicar_estilos <- function(wb, sheet, dados, congelar_primeira_linha = TRUE) {
  if (nrow(dados) == 0 || ncol(dados) == 0) {
    return(invisible(NULL))
  }

  estilo_cabecalho <- createStyle(
    textDecoration = "bold",
    fontColour = "white",
    fgFill = "#1F4E79",
    halign = "center",
    valign = "center",
    border = "TopBottomLeftRight"
  )

  estilo_borda <- createStyle(border = "TopBottomLeftRight")
  estilo_percentual <- createStyle(numFmt = "0.00%", border = "TopBottomLeftRight")

  addStyle(wb, sheet, estilo_cabecalho, rows = 1, cols = seq_len(ncol(dados)), gridExpand = TRUE)

  if (nrow(dados) > 0) {
    addStyle(
      wb,
      sheet,
      estilo_borda,
      rows = 2:(nrow(dados) + 1),
      cols = seq_len(ncol(dados)),
      gridExpand = TRUE,
      stack = TRUE
    )
  }

  colunas_percentuais <- which(str_detect(normalizar_nome(names(dados)), "%|PERC"))
  if (length(colunas_percentuais) > 0 && nrow(dados) > 0) {
    addStyle(
      wb,
      sheet,
      estilo_percentual,
      rows = 2:(nrow(dados) + 1),
      cols = colunas_percentuais,
      gridExpand = TRUE,
      stack = TRUE
    )
  }

  setColWidths(wb, sheet, cols = seq_len(ncol(dados)), widths = "auto")

  if (congelar_primeira_linha) {
    freezePane(wb, sheet, firstActiveRow = 2)
  }

  invisible(NULL)
}

validar_configuracao <- function() {
  if (pasta_arquivo == "") {
    stop("Informe a pasta do arquivo em 'pasta_arquivo'.")
  }

  if (nome_arquivo_entrada == "") {
    stop("Informe o nome do arquivo em 'nome_arquivo_entrada'.")
  }

  arquivo_entrada <- file.path(pasta_arquivo, nome_arquivo_entrada)

  if (!file.exists(arquivo_entrada)) {
    stop(paste("Arquivo nao encontrado:", arquivo_entrada))
  }

  arquivo_entrada
}

nome_aba_analise <- function(aba_origem, tipo, abas_existentes) {
  prefixo <- substr(str_squish(str_trim(aba_origem)), 1, 12)
  nome_aba_excel(paste(prefixo, tipo), abas_existentes)
}

processar_aba <- function(dados, aba_lida, wb, abas_existentes, graficos_para_inserir) {
  if (nrow(dados) == 0) {
    warning(paste("A aba foi ignorada porque esta vazia:", aba_lida))
    return(list(wb = wb, abas_existentes = abas_existentes, graficos_para_inserir = graficos_para_inserir))
  }

  if (ncol(dados) == 0) {
    warning(paste("A aba foi ignorada porque nao tem colunas:", aba_lida))
    return(list(wb = wb, abas_existentes = abas_existentes, graficos_para_inserir = graficos_para_inserir))
  }

  names(dados) <- str_squish(str_trim(names(dados)))

  cat("--------------------------------------\n")
  cat("Analisando aba:", aba_lida, "\n")
  cat("Registros:", nrow(dados), "\n")
  cat("Colunas:", ncol(dados), "\n")

  if (length(colunas_intervalo) == 0) {
    colunas_intervalo_aba <- detectar_intervalos(dados)
  } else {
    colunas_intervalo_aba <- sapply(colunas_intervalo, encontrar_coluna, nomes_reais = names(dados))
    colunas_intervalo_aba <- unname(colunas_intervalo_aba[!is.na(colunas_intervalo_aba)])
  }

  pares <- montar_comparativos_manuais(comparativos_plano_real, dados)

  if (nrow(pares) == 0) {
    warning(paste("Aba ignorada porque nenhum par Plano x Real foi encontrado:", aba_lida))
    return(list(wb = wb, abas_existentes = abas_existentes, graficos_para_inserir = graficos_para_inserir))
  }

  cat("Colunas de intervalo:", ifelse(length(colunas_intervalo_aba) == 0, "nenhuma", paste(colunas_intervalo_aba, collapse = "; ")), "\n")
  cat("Comparativos encontrados:", nrow(pares), "\n")

  resultado <- criar_resumo_comparativo(dados, pares, colunas_intervalo_aba)
  resumo_comparativos <- resultado$resumo
  detalhes_comparativos <- resultado$detalhes
  analise_tsf <- criar_analise_tsf_ideal(dados, colunas_intervalo_aba)

  if (length(colunas_intervalo_aba) > 0) {
    resumo_intervalo <- detalhes_comparativos %>%
      group_by(across(all_of(colunas_intervalo_aba))) %>%
      summarise(
        across(where(is.numeric), ~sum(.x, na.rm = TRUE)),
        .groups = "drop"
      )
  } else {
    resumo_intervalo <- data.frame(Observacao = "Nenhuma coluna de intervalo foi definida/encontrada.")
  }

  aba_resumo <- nome_aba_analise(aba_lida, "Resumo PxR", abas_existentes)
  addWorksheet(wb, aba_resumo)
  writeData(wb, aba_resumo, resumo_comparativos)
  aplicar_estilos(wb, aba_resumo, resumo_comparativos)
  abas_existentes <- c(abas_existentes, aba_resumo)

  aba_detalhes <- nome_aba_analise(aba_lida, "Detalhes", abas_existentes)
  addWorksheet(wb, aba_detalhes)
  writeData(wb, aba_detalhes, detalhes_comparativos)
  aplicar_estilos(wb, aba_detalhes, detalhes_comparativos)
  abas_existentes <- c(abas_existentes, aba_detalhes)

  aba_intervalo <- nome_aba_analise(aba_lida, "Resumo Int", abas_existentes)
  addWorksheet(wb, aba_intervalo)
  writeData(wb, aba_intervalo, resumo_intervalo)
  aplicar_estilos(wb, aba_intervalo, resumo_intervalo)
  abas_existentes <- c(abas_existentes, aba_intervalo)

  if (!is.null(analise_tsf)) {
    aba_tsf <- nome_aba_analise(aba_lida, "TSF Ideal", abas_existentes)
    addWorksheet(wb, aba_tsf)

    writeData(wb, aba_tsf, "Resumo TSF Ideal", startRow = 1, startCol = 1)
    writeData(wb, aba_tsf, analise_tsf$resumo, startRow = 2, startCol = 1)

    linha_tsf_detalhes <- nrow(analise_tsf$resumo) + 5
    writeData(wb, aba_tsf, "Detalhes por intervalo", startRow = linha_tsf_detalhes, startCol = 1)
    writeData(wb, aba_tsf, analise_tsf$detalhes, startRow = linha_tsf_detalhes + 1, startCol = 1)

    setColWidths(wb, aba_tsf, cols = 1:max(1, ncol(analise_tsf$detalhes)), widths = "auto")
    freezePane(wb, aba_tsf, firstActiveRow = 2)
    abas_existentes <- c(abas_existentes, aba_tsf)
  }

  base_graficos <- criar_base_graficos(dados, pares, colunas_intervalo_aba, analise_tsf)

  if (length(base_graficos$specs) > 0) {
    aba_dados_graficos <- nome_aba_analise(aba_lida, "Dados Graf", abas_existentes)
    addWorksheet(wb, aba_dados_graficos)
    abas_existentes <- c(abas_existentes, aba_dados_graficos)

    for (spec in base_graficos$specs) {
      writeData(wb, aba_dados_graficos, spec$titulo, startRow = spec$linha_titulo, startCol = 1)
      writeData(
        wb,
        aba_dados_graficos,
        data.frame(Intervalo = "Intervalo", Real = spec$colunas_series[1], Plano = spec$colunas_series[2]),
        startRow = spec$linha_cabecalho,
        startCol = 1,
        colNames = FALSE
      )
      writeData(wb, aba_dados_graficos, spec$dados, startRow = spec$linha_inicio, startCol = 1, colNames = FALSE)
    }

    setColWidths(wb, aba_dados_graficos, cols = 1:3, widths = "auto")

    aba_graficos <- nome_aba_analise(aba_lida, "Graficos", abas_existentes)
    addWorksheet(wb, aba_graficos)
    writeData(wb, aba_graficos, "Graficos editaveis do Excel", startRow = 1, startCol = 1)
    writeData(wb, aba_graficos, "Clique no grafico dentro do Excel para editar cores, linhas, series e titulos.", startRow = 2, startCol = 1)
    setColWidths(wb, aba_graficos, cols = 1:16, widths = 12)
    abas_existentes <- c(abas_existentes, aba_graficos)

    graficos_para_inserir[[length(graficos_para_inserir) + 1]] <- list(
      aba_graficos = aba_graficos,
      aba_dados_graficos = aba_dados_graficos,
      specs = base_graficos$specs
    )
  }

  for (i in seq_along(analises_extras)) {
    analise <- criar_analise_extra(dados, analises_extras[i], colunas_intervalo_aba)

    if (is.null(analise)) {
      next
    }

    aba_extra <- nome_aba_analise(aba_lida, paste0("Analise ", i), abas_existentes)
    addWorksheet(wb, aba_extra)

    writeData(wb, aba_extra, paste("Colunas analisadas:", analises_extras[i]), startRow = 1, startCol = 1)
    writeData(wb, aba_extra, "Metricas gerais", startRow = 3, startCol = 1)
    writeData(wb, aba_extra, analise$metricas, startRow = 4, startCol = 1)

    linha_agrupado <- nrow(analise$metricas) + 7
    writeData(wb, aba_extra, "Analise por intervalo", startRow = linha_agrupado, startCol = 1)
    writeData(wb, aba_extra, analise$agrupado, startRow = linha_agrupado + 1, startCol = 1)

    linha_base <- linha_agrupado + nrow(analise$agrupado) + 4
    writeData(wb, aba_extra, "Base da analise", startRow = linha_base, startCol = 1)
    writeData(wb, aba_extra, analise$base, startRow = linha_base + 1, startCol = 1)

    setColWidths(wb, aba_extra, cols = 1:max(1, ncol(analise$base)), widths = "auto")
    freezePane(wb, aba_extra, firstActiveRow = 4)
    abas_existentes <- c(abas_existentes, aba_extra)
  }

  list(wb = wb, abas_existentes = abas_existentes, graficos_para_inserir = graficos_para_inserir)
}

##############################################################
## LEITURA
##############################################################

cat("--------------------------------------\n")
cat("Iniciando analise Plano x Real...\n")
cat("--------------------------------------\n")

arquivo_entrada <- validar_configuracao()
extensao <- tolower(file_ext(arquivo_entrada))

if (nome_arquivo_saida == "") {
  nome_arquivo_saida <- paste0("ANALISE_", file_path_sans_ext(nome_arquivo_entrada), ".xlsx")
}

arquivo_saida <- file.path(pasta_arquivo, nome_arquivo_saida)

if (normalizePath(arquivo_entrada, winslash = "/", mustWork = FALSE) ==
    normalizePath(arquivo_saida, winslash = "/", mustWork = FALSE)) {
  stop("O arquivo de saida nao pode ter o mesmo nome do arquivo de entrada.")
}

cat("Arquivo lido:", arquivo_entrada, "\n")

##############################################################
## CRIACAO DO ARQUIVO EXCEL
##############################################################

if (extensao %in% c("xlsx", "xls")) {
  if (extensao == "xlsx") {
    wb <- loadWorkbook(arquivo_entrada)
  } else {
    wb <- createWorkbook()
  }

  abas_disponiveis <- excel_sheets(arquivo_entrada)

  if (length(aba) == 0) {
    abas_para_ler <- abas_disponiveis
  } else if (length(aba) == 1 && aba == "") {
    abas_para_ler <- abas_disponiveis[1]
  } else {
    abas_para_ler <- aba
  }

  abas_inexistentes <- setdiff(abas_para_ler, abas_disponiveis)
  if (length(abas_inexistentes) > 0) {
    stop(paste("Abas nao encontradas no arquivo:", paste(abas_inexistentes, collapse = "; ")))
  }
} else {
  if (!(extensao == "csv")) {
    stop("Formato nao suportado. Use arquivos .xlsx, .xls ou .csv.")
  }

  wb <- createWorkbook()
  abas_para_ler <- "Dados"
  dados_csv <- read.csv2(arquivo_entrada, stringsAsFactors = FALSE, check.names = FALSE)
  addWorksheet(wb, "Dados Originais")
  writeData(wb, "Dados Originais", dados_csv)
  aplicar_estilos(wb, "Dados Originais", dados_csv)
}

abas_existentes <- names(wb)
graficos_para_inserir <- list()

cat("Abas para analisar:", paste(abas_para_ler, collapse = "; "), "\n")

for (aba_lida in abas_para_ler) {
  if (extensao %in% c("xlsx", "xls")) {
    dados <- read_excel(path = arquivo_entrada, sheet = aba_lida)
  } else {
    dados <- dados_csv
  }

  if (extensao == "xls") {
    aba_original <- nome_aba_excel(aba_lida, abas_existentes)
    addWorksheet(wb, aba_original)
    writeData(wb, aba_original, dados)
    aplicar_estilos(wb, aba_original, dados)
    abas_existentes <- c(abas_existentes, aba_original)
  }

  resultado_aba <- processar_aba(
    dados = dados,
    aba_lida = aba_lida,
    wb = wb,
    abas_existentes = abas_existentes,
    graficos_para_inserir = graficos_para_inserir
  )

  wb <- resultado_aba$wb
  abas_existentes <- resultado_aba$abas_existentes
  graficos_para_inserir <- resultado_aba$graficos_para_inserir
}

##############################################################
## SALVAR
##############################################################

saveWorkbook(wb, file = arquivo_saida, overwrite = TRUE)

for (grafico_info in graficos_para_inserir) {
  adicionar_graficos_editaveis_xlsx(
    arquivo_xlsx = arquivo_saida,
    aba_graficos = grafico_info$aba_graficos,
    aba_dados = grafico_info$aba_dados_graficos,
    specs = grafico_info$specs
  )
}

cat("--------------------------------------\n")
cat("Analise concluida com sucesso!\n")
cat("Arquivo salvo em:\n")
cat(arquivo_saida, "\n")
cat("--------------------------------------\n")
