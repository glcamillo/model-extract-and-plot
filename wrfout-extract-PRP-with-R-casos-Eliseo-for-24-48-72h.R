#!/usr/bin/env Rscript
# Author: Gerson L Camillo
# Last rev: 20240907

## Objetivo principal: extrair dados de precipitação total de 25 pontos (**i** e **j**) de grade de um arquivo de saída do WRF (formato NetCDF) e sumarizar os resultados, escrevendo num arquivo de saída CSV. Os resultados correspondem a 24h, 48h ou 72h de precipitação acumulada, considerando o parâmetro para o script e o período de previsão contido nos dados de saída WRF.

## O que este script faz: 
# 1. Lê as coordenadas **i** e **j** como parâmetro
# 2. Extrai dados de PRP (RAINNC e RAINC) de 25 pontos em torno de **i** e **j**
# 3. Sumariza os resultados da área que corresponde aos 25 pontos
# 4. Salva o resultado em arquivo CSV

## Como executar
# ./wrfout-extract-PRP-with-R-casos-Eliseo-for-24-48-72h.R 
#        wrfout_d02_2016-07-15_00.nc
#        caso-01-urussanga-20160715-D2-24h-PRP-from-R
#        120 110
#        24
#        AREA

## Argumentos da linha de comando
# args[1]=wrfout_d02_2016-12-03_00.nc   Nome do arquivo de saída (formato NetCDF) gerado pelo WRF
# args[2]=caso-01-urussanga-20160715-D2-24h-PRP-from-R     Nome do arquivo de SAIDA
# args[3]=120    Coordenada WRF x=i
# args[4]=110    Coordenada WRF y=j
# args[5]=24|48|72   Quantas horas de extração de dados acumulados
# args[6]=POINT|AREA  Se extração por ponto ou área (somente implementado por área)


########################################################
############## Processamento: INÍCIO  ##################

library(ncdf4)

## Imprime dados de versão e de sessão
version
sessionInfo()

## Obtém argumentos da linha de comando e imprime
args <- commandArgs(trailingOnly = TRUE)
print(paste("args[1]:", args[1], "args[2]:", args[2],"args[3]:", args[3], "args[4]:", args[4], "args[5]:", args[5], "args[6]:", args[6]))
netcdf.file <- args[1]
print(netcdf.file)
extract_point_or_area <- "AREA"
print(extract_point_or_area)
#  Somente será processado do domínio interno de maior resolução espacial
# nc <- ncdf4::nc_open(netcdf.file)
wrfout <- ncdf4::nc_open(netcdf.file)
#wrfout <- nc_open('wrfout_d02_2017-11-02_00.nc')  # 72h
#wrfout <- nc_open('wrfout_d02_2017-11-03_00.nc')  # 48h
#wrfout <- nc_open('wrfout_d02_2017-11-04_00.nc')  # 24h

## Extração de dados de coordenada i e j e de unidades de tempo
i <- as.numeric(args[3])
print(paste("Coordenada i=x: ", i))
j <- as.numeric(args[4])
print(paste("Coordenada j=y: ", j))
# j=y=279  i=x=106
# i=120
# j=110

ft <- as.numeric(args[5])+1

# forecast_time <- as.numeric(args[5])+1
# ft=25  # Forecast Time: 24h
# ft=49  # Forecast Time: 48h
# ft=73  # Forecast Time: 72h

if (ft == 25) {
    ft_minus_24=1
} else if (ft == 49) {
    ft_minus_24=25
} else {
    ft_minus_24=49
}

if (ft == 9) {
    ft_minus_24=1
}

print(paste("Forecast time (ft):", ft))
print(paste("Forecast time (ft_minus_24):", ft_minus_24))

# Passos no tempo: 1(0h), 2(3h), 3(6h), 4(9h), 5(12h), 6(15h), 7(18h), 8(21h), 9(24h)
# 9: [1]   0 180 360 540 720 900


## Extração de dados de coordenada geográfica e de precipitação

# Coordenadas geográficas para os todos os pontos de grade i,j
xlon <- ncvar_get(wrfout, varid = 'XLONG')
nlon <- dim(xlon)

xlat <-  ncvar_get(wrfout, varid = 'XLAT')
nlat <- dim(xlat)

print(c(nlon,nlat))

# Extrai unidades de tempo
time <- ncvar_get(wrfout, "XTIME")
ntime <- dim(time)
head(time)
tunits <- ncatt_get(wrfout, "XTIME", "units")
tunits[["value"]]

# RAINNC:description = "ACCUMULATED TOTAL GRID SCALE PRECIPITATION"
rainnc <- ncvar_get(wrfout, varid = "RAINNC")
runits <- ncatt_get(wrfout, "RAINNC", "units")
runits[["value"]]
dim(rainnc)

# RAINC:description = "ACCUMULATED TOTAL CUMULUS PRECIPITATION"
rainc <- ncvar_get(wrfout, varid = "RAINC")
runits <- ncatt_get(wrfout, "RAINC", "units")
runits[["value"]]
dim(rainc)

## Fecha o arquivo NetCDF
nc_close(wrfout)

# TODO TODO Por enquanto não usado, mas para plotagem de imagens
lon <- xlon[,1,]
dim(lon)
lat <-  xlat[1,,]
dim(lat)

###  Como as coordenadas i e j (do WRF) são nomeadas e referidas
###    para fins de extração de dados
# Nome e localização em termos de coordenadas WRF para os 25 pontos
#  Considerando o domínio da execução da conf B, cujo domínio D2 tem
#  resolução de 2km, daria uma área de 10x10km.
# pa pb pc pd pe
# pf pg ph pi pj
# pk pl pm pn po
# pp pq pr ps pt
# pu pv px pz py

## Para o caso de extração por ponto
# pa: i-2,j+2
#r_pa <- rain[i-2,j+2,ft]
# pb: i-1,j+2
#r_pb <- rain[i-1,j+2,ft]
# pc: i,j+2
#r_pc <- rain[i,j+2,ft]
# pd: i+1,j+2
#r_pd <- rain[i+1,j+2,ft]
# The 24-hr precipitation for the period 24-28hr simulation should be:
# [rainc +rainnc (at 48hr)] - [rainc+rainnc (at 24hr)]
# pe: i+2,j+2
# r_pe <- rain[i+2,j+2,ft]

## Extrai os dados de precipitação de cada ponto de grade (todos os 25 pontos)
# pa: i-2,j+2
r_pa <- rainnc[i-2,j+2,ft]+rainc[i-2,j+2,ft]-(rainnc[i-2,j+2,ft_minus_24]+rainc[i-2,j+2,ft_minus_24])
# pb: i-1,j+2
r_pb <- rainnc[i-1,j+2,ft]+rainc[i-1,j+2,ft]-(rainnc[i-1,j+2,ft_minus_24]+rainc[i-1,j+2,ft_minus_24])
# pc: i,j+2
r_pc <- rainnc[i,j+2,ft]+rainc[i,j+2,ft]-(rainnc[i,j+2,ft_minus_24]+rainc[i,j+2,ft_minus_24])
# pd: i+1,j+2
r_pd <- rainnc[i+1,j+2,ft]+rainc[i+1,j+2,ft]-(rainnc[i+1,j+2,ft_minus_24]+rainc[i+1,j+2,ft_minus_24])
# pe: i+2,j+2
r_pe <- rainnc[i+2,j+2,ft]+rainc[i+2,j+2,ft]-(rainnc[i+2,j+2,ft_minus_24]+rainc[i+2,j+2,ft_minus_24])

# ----  pf pg ph pi pj
# pf: i-2,j+1
r_pf <- rainnc[i-2,j+1,ft]+rainc[i-2,j+1,ft]-(rainnc[i-2,j+1,ft_minus_24]+rainc[i-2,j+1,ft_minus_24])
# pg: i-1,j+1
r_pg <- rainnc[i-1,j+1,ft]+rainc[i-1,j+1,ft]-(rainnc[i-1,j+1,ft_minus_24]+rainc[i-1,j+1,ft_minus_24])
# ph: i,j+1
r_ph <- rainnc[i,j+1,ft]+rainc[i,j+1,ft]-(rainnc[i,j+1,ft_minus_24]+rainc[i,j+1,ft_minus_24])
# pi: i+1,j+1
r_pi <- rainnc[i+1,j+1,ft]+rainc[i+1,j+1,ft]-(rainnc[i+1,j+1,ft_minus_24]+rainc[i+1,j+1,ft_minus_24])
# pj: i+2,j+1
r_pj <- rainnc[i+2,j+1,ft]+rainc[i+2,j+1,ft]-(rainnc[i+2,j+1,ft_minus_24]+rainc[i+2,j+1,ft_minus_24])

# ----  pk pl pm pn po
# pk: i-2,j
r_pk <- rainnc[i-2,j,ft]+rainc[i-2,j,ft]-(rainnc[i-2,j,ft_minus_24]+rainc[i-2,j,ft_minus_24])
# pl: i-1,j
r_pl <- rainnc[i-1,j,ft]+rainc[i-1,j,ft]-(rainnc[i-1,j,ft_minus_24]+rainc[i-1,j,ft_minus_24])
# pm: i,j
r_pm <- rainnc[i,j,ft]+rainc[i,j,ft]-(rainnc[i,j,ft_minus_24]+rainc[i,j,ft_minus_24])
# pn: i+1,j
r_pn <- rainnc[i+1,j,ft]+rainc[i+1,j,ft]-(rainnc[i+1,j,ft_minus_24]+rainc[i+1,j,ft_minus_24])
# po: i+2,j
r_po <- rainnc[i+2,j,ft]+rainc[i+2,j,ft]-(rainnc[i+2,j,ft_minus_24]+rainc[i+2,j,ft_minus_24])

# ----  pp pq pr ps pt
# pp: i-2,j-1
r_pp <- rainnc[i-2,j-1,ft]+rainc[i-2,j-1,ft]-(rainnc[i-2,j-1,ft_minus_24]+rainc[i-2,j-1,ft_minus_24])
# pq: i-1,j-1
r_pq <- rainnc[i-1,j-1,ft]+rainc[i-1,j-1,ft]-(rainnc[i-1,j-1,ft_minus_24]+rainc[i-1,j-1,ft_minus_24])
# pr: i,j-1
r_pr <- rainnc[i,j-1,ft]+rainc[i,j-1,ft]-(rainnc[i,j-1,ft_minus_24]+rainc[i,j-1,ft_minus_24])
# ps: i+1,j-1
r_ps <- rainnc[i+1,j-1,ft]+rainc[i+1,j-1,ft]-(rainnc[i+1,j-1,ft_minus_24]+rainc[i+1,j-1,ft_minus_24])
# pt: i+2,j-1
r_pt <- rainnc[i+2,j-1,ft]+rainc[i+2,j-1,ft]-(rainnc[i+2,j-1,ft_minus_24]+rainc[i+2,j-1,ft_minus_24])

# ----  pu pv px pz py
# pu: i-2,j-1
r_pu <- rainnc[i-2,j-2,ft]+rainc[i-2,j-2,ft]-(rainnc[i-2,j-2,ft_minus_24]+rainc[i-2,j-2,ft_minus_24])
# pv: i-1,j-1
r_pv <- rainnc[i-1,j-2,ft]+rainc[i-1,j-2,ft]-(rainnc[i-1,j-2,ft_minus_24]+rainc[i-1,j-2,ft_minus_24])
# px: i,j-1
r_px <- rainnc[i,j-2,ft]+rainc[i,j-2,ft]-(rainnc[i,j-2,ft_minus_24]+rainc[i,j-2,ft_minus_24])
# pz: i+1,j-1
r_pz <- rainnc[i+1,j-2,ft]+rainc[i+1,j-2,ft]-(rainnc[i+1,j-2,ft_minus_24]+rainc[i+1,j-2,ft_minus_24])
# py: i+2,j-1
r_py <- rainnc[i+2,j-2,ft]+rainc[i+2,j-2,ft]-(rainnc[i+2,j-2,ft_minus_24]+rainc[i+2,j-2,ft_minus_24])

## Coloca os dados em um vetor
result <- c(r_pa, r_pb, r_pc, r_pd, r_pe, r_pf, r_pg, r_ph, r_pi, r_pj, r_pk, r_pl, r_pm, r_pn, r_po, r_pp, r_pq, r_pr, r_ps, r_pt, r_pu, r_pv, r_px, r_pz, r_py)

## Imprime os dados de cada ponto e a sumarização estatística da função do R: summary()
print(result)
print(summary(result))

## Escreve os resultados em arquivos CSV
data <- data.frame(prp_24h_accum_total=result)
filename_output <- paste(args[2],"-points.csv",sep="")
write.csv2(data,file=filename_output, row.names = TRUE)

filename_output <- paste(args[2],"-summary.csv",sep="")
sink(filename_output)
print(summary(result))
sink()


