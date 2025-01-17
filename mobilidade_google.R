#################################################################################################################
# Gr�ficos com dados de mobilidade do Google
# Felipe Simpl�cio Ferreira
# Data: 24-06-2021
#################################################################################################################



# Pacotes
library("rio")
library("dplyr")
library("tidyr")
library("zoo")
library("xts")
library("ggplot2")
library("scales")
# library("seasonal")



# Definindo caminho dos arquivos
# setwd("D:/Downloads")



# Coletando dados
dados <- import("dados.xlsx", sheet = "dados", col_names = F)
datas <- as.Date(as.numeric(dados[-1:-2,1]), origin = "1899-12-30")

populacao <- import("dados.xlsx", sheet = "populacao", col_names = T)
populacao[,2] <- as.numeric(populacao[,2])
row.names(populacao) <-  populacao[,1]



# Separando dados
separador <- seq(2,length(dados), 4)
lista_regioes <- NA

for (i in 1:length(separador)){
  dados_regiao <- dados[,separador[i]:(separador[i]+3)]
  nome_arquivo <- as.character(dados_regiao[1,1])
  nomes_colunas <- as.character(dados_regiao[2,])
  dados_regiao <- dados_regiao[-1:-2,]
  names(dados_regiao) <- nomes_colunas
  dados_regiao <- dados_regiao %>% mutate_all(function(x) as.numeric(as.character(x)))
  dados_regiao["Data"] <- datas
  dados_regiao <- dados_regiao %>% select(Data, everything()) %>% drop_na()
  assign(nome_arquivo, dados_regiao) #Nomeando arquivos
  lista_regioes[i] <- nome_arquivo
  print(paste(i, length(separador), sep = '/')) #Printa o progresso
}



# Calculando pesos
centro_oeste <- c("BR-GO", "BR-MT", "BR-MS", "BR-DF")
norte <- c("BR-AC", "BR-AM", "BR-AP", "BR-PA", "BR-RR", "BR-RO", "BR-TO")
nordeste <- c("BR-AL", "BR-BA", "BR-CE", "BR-MA", "BR-PI", "BR-PE", "BR-PB", "BR-RN", "BR-SE")
sul <- c("BR-RS", "BR-PR", "BR-SC")
sudeste <- c("BR-ES", "BR-MG", "BR-RJ", "BR-SP")

denominador <- sum(populacao[centro_oeste,2])
for (i in 1:length(centro_oeste)){
  numerador <- populacao[centro_oeste[i],2]
  fator <- numerador / denominador
  dados_ponderados <- get(centro_oeste[i])[,-1] * fator
  dados_ponderados["Data"] <- get(centro_oeste[i])[,1]
  dados_ponderados <- dados_ponderados %>% select(Data, everything())
  assign(centro_oeste[i], dados_ponderados) #Nomeando arquivos
  print(paste(i, length(centro_oeste), sep = '/')) #Printa o progresso
}

denominador <- sum(populacao[norte,2])
for (i in 1:length(norte)){
  numerador <- populacao[norte[i],2]
  fator <- numerador / denominador
  dados_ponderados <- get(norte[i])[,-1] * fator
  dados_ponderados["Data"] <- get(norte[i])[,1]
  dados_ponderados <- dados_ponderados %>% select(Data, everything())
  assign(norte[i], dados_ponderados) #Nomeando arquivos
  print(paste(i, length(norte), sep = '/')) #Printa o progresso
}

denominador <- sum(populacao[nordeste,2])
for (i in 1:length(nordeste)){
  numerador <- populacao[nordeste[i],2]
  fator <- numerador / denominador
  dados_ponderados <- get(nordeste[i])[,-1] * fator
  dados_ponderados["Data"] <- get(nordeste[i])[,1]
  dados_ponderados <- dados_ponderados %>% select(Data, everything())
  assign(nordeste[i], dados_ponderados) #Nomeando arquivos
  print(paste(i, length(nordeste), sep = '/')) #Printa o progresso
}

denominador <- sum(populacao[sul,2])
for (i in 1:length(sul)){
  numerador <- populacao[sul[i],2]
  fator <- numerador / denominador
  dados_ponderados <- get(sul[i])[,-1] * fator
  dados_ponderados["Data"] <- get(sul[i])[,1]
  dados_ponderados <- dados_ponderados %>% select(Data, everything())
  assign(sul[i], dados_ponderados) #Nomeando arquivos
  print(paste(i, length(sul), sep = '/')) #Printa o progresso
}

denominador <- sum(populacao[sudeste,2])
for (i in 1:length(sudeste)){
  numerador <- populacao[sudeste[i],2]
  fator <- numerador / denominador
  dados_ponderados <- get(sudeste[i])[,-1] * fator
  dados_ponderados["Data"] <- get(sudeste[i])[,1]
  dados_ponderados <- dados_ponderados %>% select(Data, everything())
  assign(sudeste[i], dados_ponderados) #Nomeando arquivos
  print(paste(i, length(sudeste), sep = '/')) #Printa o progresso
}



# Agregando em dados por regi�o
BR_centro_oeste <- `BR-GO` %>% rbind(`BR-MT`) %>% rbind(`BR-MS`) %>% rbind(`BR-DF`)
BR_centro_oeste <- BR_centro_oeste %>% group_by(Data) %>% summarise_each(funs(sum)) %>% as.data.frame()

BR_norte <- `BR-AC` %>% rbind(`BR-AM`) %>% rbind(`BR-AP`) %>% rbind(`BR-PA`) %>% rbind(`BR-RR`) %>% rbind(`BR-RO`) %>% rbind(`BR-TO`)
BR_norte <- BR_norte %>% group_by(Data) %>% summarise_each(funs(sum)) %>% as.data.frame()

BR_nordeste <- `BR-AL` %>% rbind(`BR-BA`) %>% rbind(`BR-CE`) %>% rbind(`BR-MA`) %>% rbind(`BR-PI`) %>% rbind(`BR-PE`) %>% rbind(`BR-PB`) %>% rbind(`BR-RN`) %>% rbind(`BR-SE`)
BR_nordeste <- BR_nordeste %>% group_by(Data) %>% summarise_each(funs(sum)) %>% as.data.frame()

BR_sul <- `BR-RS` %>% rbind(`BR-PR`) %>% rbind(`BR-SC`)
BR_sul <- BR_sul %>% group_by(Data) %>% summarise_each(funs(sum)) %>% as.data.frame()

BR_sudeste <- `BR-ES` %>% rbind(`BR-MG`) %>% rbind(`BR-RJ`) %>% rbind(`BR-SP`)
BR_sudeste <- BR_sudeste %>% group_by(Data) %>% summarise_each(funs(sum)) %>% as.data.frame()

lista_regioes <- c("BR_centro_oeste", "BR_norte", "BR_nordeste", "BR_sul", "BR_sudeste")



# Dados mensais
lista_regioes_mensal <- NA
for (i in 1:length(lista_regioes)){
  dados_mensal <- as.xts(get(lista_regioes[i])[,-1], order.by=get(lista_regioes[i])[,1])
  nome_arquivo_mensal <- as.character(paste(lista_regioes[i], "mensal", sep = "_"))
  dados_mensal <- apply.monthly(dados_mensal, mean)
  dados_mensal <-  fortify(dados_mensal)
  dados_mensal <- select(dados_mensal, Data = Index, everything())
  lista_regioes_mensal[i] <- nome_arquivo_mensal
  assign(nome_arquivo_mensal, dados_mensal) #Nomeando arquivos
  print(paste(i, length(lista_regioes), sep = '/')) #Printa o progresso
}



# Dados com m�dia m�vel
lista_regioes_mm <- NA
for (i in 1:length(lista_regioes)){
  dados_mm <- get(lista_regioes[i])[-1:-6,]
  nome_arquivo_mm <- as.character(paste(lista_regioes[i], "mm", sep = "_"))
  for (j in 2:length(get(lista_regioes[i]))){
    dados_mm[,j] = rollmean(get(lista_regioes[i])[,j], 7)
  }
  lista_regioes_mm[i] <- nome_arquivo_mm
  assign(nome_arquivo_mm, dados_mm) #Nomeando arquivos
  print(paste(i, length(lista_regioes), sep = '/')) #Printa o progresso
}



# Gr�ficos
seletor_graficos <- function(opcao){
  if (opcao == "diario")
    for (i in 1:length(lista_regioes)){
      dados_graf <- pivot_longer(get(lista_regioes[i]), all_of(nomes_colunas))
      ggplot(dados_graf, aes(x = Data, y = value, color = name)) + 
        geom_line(size = 2) + 
        theme(axis.text.x=element_text(angle=90, hjust=1)) + 
        ylab("") +
        xlab("Data") +
        labs(title = lista_regioes[i], subtitle = "Dados di�rios - var% sobre o valor de refer�ncia",
             caption = "Fonte: Google   Valor de refer�ncia: valor mediano do per�odo de cinco semanas entre 3 de janeiro a 6 de fevereiro de 2020") +
        scale_x_date(breaks = date_breaks("1 month"), labels = date_format("%d/%b")) + 
        theme(legend.position="bottom") +
        scale_color_discrete(name = "Colunas") + 
        guides(color=guide_legend(nrow=2, byrow=TRUE))
      ggsave(paste(lista_regioes[i],".png", sep = ""))
    }
      
  if (opcao == "mensal")
    for (i in 1:length(lista_regioes)){
      dados_graf_mensal <- pivot_longer(get(lista_regioes_mensal[i]), all_of(nomes_colunas))
      ggplot(dados_graf_mensal, aes(x = Data, y = value, color = name)) + 
        geom_line(size = 2) + 
        theme(axis.text.x=element_text(angle=90, hjust=1)) + 
        ylab("") +
        xlab("Data") +
        labs(title = lista_regioes[i], subtitle = "Dados mensais - var% sobre o valor de refer�ncia",
             caption = "Fonte: Google   Valor de refer�ncia: valor mediano do per�odo de cinco semanas entre 3 de janeiro a 6 de fevereiro de 2020") +
        scale_x_date(breaks = date_breaks("1 month"), labels = date_format("%d/%b")) + 
        theme(legend.position="bottom") +
        scale_color_discrete(name = "Colunas") + 
        guides(color=guide_legend(nrow=2, byrow=TRUE))
      ggsave(paste(lista_regioes_mensal[i],".png", sep = ""))
    }
    
    if (opcao == "mm")
      for (i in 1:length(lista_regioes)){
        dados_mm <- pivot_longer(get(lista_regioes_mm[i]), all_of(nomes_colunas))
        ggplot(dados_mm, aes(x = Data, y = value, color = name)) + 
          geom_line(size = 2) + 
          theme(axis.text.x=element_text(angle=90, hjust=1)) + 
          ylab("") +
          xlab("Data") +
          labs(title = lista_regioes[i], subtitle = "M�dia m�vel de 7 dias, var% sobre o valor de refer�ncia",
               caption = "Fonte: Google   Valor de refer�ncia: valor mediano do per�odo de cinco semanas entre 3 de janeiro a 6 de fevereiro de 2020") +
          scale_x_date(breaks = date_breaks("1 month"), labels = date_format("%d/%b")) + 
          theme(legend.position="bottom") +
          scale_color_discrete(name = "Colunas") + 
          guides(color=guide_legend(nrow=2, byrow=TRUE))
        ggsave(paste(lista_regioes_mm[i],".png", sep = ""))
  }
}



# Resultados
seletor_graficos("diario")
seletor_graficos("mensal")
seletor_graficos("mm")