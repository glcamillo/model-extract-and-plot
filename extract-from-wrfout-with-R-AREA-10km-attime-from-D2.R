#!/usr/bin/env Rscript
# Author: Gerson L Camillo

# What this do: extract PRP variable from NetCDF file that was generated
#      by WRF. Basic parameter: grid point

# Rev.:
#  v.1 20240321: initial: 25 grid points -> D2 -> 10km (area)

# ./extract-from-wrfout-with-R-AREA-10km-attime-from-D2.R  
#        wrfout_d02_2020-08-14_00.nc
#        case-01-MP-1-and-PBL-99-JO-attime
#        120 110
#        CH
#        24
#        AREA
#        attime



# Arguments
# args[1]=wrfout_d02_2020-08-14_00.nc    NetCDF file from WRF output
# args[2]=data-prp-pbl_MRF-mp_KESS-CH-attime        Name of output file (CSV data)
# args[3]=120           Central coordinate of grid point: x=i
# args[4]=110           Central coordinate of grid point: y=j
# args[5]=JO            Code name for meteorological station (name or ALL)
# args[6]=24            Time of forecast (24,48,72)
# args[7]=POINT|AREA    This script will print only AREA for now
# args[8]=attime        Compare OBS data time with WRF forecast at:
#                            attime: same time stamp;
#                            atfw:  forecast time 2hours in future
#                            atbw:  forecast time 2hours in past

# Observations:
# - The argument for station can be: a) only one, or b) the code 'ALL'
#   ALL means the next stations:
# CH: Chapecó
# XA: Xanxerê
# JO: Joaçaba
# CN: Campos Novos
# CR: Curitibanos
# CA: Caçador

# 1. CH: Chapecó  -27,0853111  -52,6357111   679
#    WRF Grid points: -27.0789 j=236  -52.629 x=155
# 2. XA: Xanxerê -26,938666  -52,39809   878,74
#    WRF Grid points: -26.9241 j=243   -50.3976 i=167
# 3. JO: Joaçaba -27,16916666 -51,55888888  767,63
#    WRF Grid points: -27.1572 j=231   -51.5555 i=209
# 4. CN: Campos Novos -27,3886111 -51,21583333 963
#    WRF Grid points: -27.3935 j=218   -51.214  i=226
# 5. CT: Curitibanos  -27,288624 -50,604283 978,1
#    WRF Grid points: -27.2348 j=227   -50.5938 i=257
# 6. CA: Caçador   -26,819156  -50,98552   944,26m
#    WRF Grid points: -26.811  j=250    -50.992  x=238

# For printing data e information
# DEBUG = TRUE
DEBUG = FALSE

library(ncdf4)

if (DEBUG){
  version
  sessionInfo()
}


args <- commandArgs(trailingOnly = TRUE)
print(paste("args[1]:", args[1], "args[2]:", args[2],"args[3]:", args[3], "args[4]:", args[4], "args[5]:", args[5], "args[6]:", args[6], "args[7]:", args[7], "args[8]:", args[8]))
netcdf.file <- args[1]
extract_point_or_area <- "AREA"

#  Somente será processado do domínio interno de maior resolução espacial
# nc <- ncdf4::nc_open(netcdf.file)
wrfout <- ncdf4::nc_open(netcdf.file)

xlon <- ncvar_get(wrfout, varid = 'XLONG')
xlat <- ncvar_get(wrfout, varid = 'XLAT')
rain <- ncvar_get(wrfout, varid = 'RAINNC')

# A respeito da variável, consultar obs ao final
# prp_variable <- c("rainnc")

i <- as.numeric(args[3])
j <- as.numeric(args[4])
# j=y=279  i=x=106
# i=120
# j=110

station <- args[5]


# forecast_time <- as.numeric(args[5])+1

forecast_time <- as.numeric(args[6])+1
# forecast_time=25  # Forecast Time: 24h
# forecast_time=49  # Forecast Time: 48h
# forecast_time=73  # Forecast Time: 72h

if (forecast_time == 25) {
    t_start=1
} else if (forecast_time == 49) {
    t_start=25
} else {
    t_start=49
}
if (forecast_time == 9) {
    t_start=1
}



if (DEBUG){
  print(paste(" --- Parameters ---"))
  print(paste("WRF output filename (netcdf.file)", netcdf.file))
  print(paste("Type of summarization: ", extract_point_or_area))
  print(paste("Coordinate i=x: ", i))
  print(paste("Coordinate j=y: ", j))
  print(paste("Name of INMET OBS station: ", station))
  print(paste("Forecast time (forecast_time):", forecast_time))
  print(paste("Forecast time (t_start):", t_start))
}


# Passos no tempo: 1(0h), 2(3h), 3(6h), 4(9h), 5(12h), 6(15h), 7(18h), 8(21h), 9(24h)
# 9: [1]   0 180 360 540 720 900

# pa pb pc pd pe
# pf pg ph pi pj
# pk pl pm pn po
# pp pq pr ps pt
# pu pv px pz py

# pa: i-2,j+2
#r_pa <- rain[i-2,j+2,t+1]

# pb: i-1,j+2
#r_pb <- rain[i-1,j+2,t+1]

# pc: i,j+2
#r_pc <- rain[i,j+2,t+1]

# pd: i+1,j+2
#r_pd <- rain[i+1,j+2,t+1]

# The 24-hr precipitation for the period 24-28hr simulation should be:
# [rainc +rainnc (at 48hr)] - [rainc+rainnc (at 24hr)]
# pe: i+2,j+2
# r_pe <- rain[i+2,j+2,t+1]


# =======================================================

# Extração da variável
xlon <- ncvar_get(wrfout, varid = 'XLONG')
nlon <- dim(xlon)

xlat <-  ncvar_get(wrfout, varid = 'XLAT')
nlat <- dim(xlat)

print(c(nlon,nlat))

time <- ncvar_get(wrfout, "XTIME")
ntime <- dim(time)
head(time)
tunits <- ncatt_get(wrfout, "XTIME", "units")
tunits[["value"]]

# =========== Observações
#  RAINC:description = "ACCUMULATED TOTAL CUMULUS PRECIPITATION" ;
#  RAINSH:description = "ACCUMULATED SHALLOW CUMULUS PRECIPITATION" ;
#  RAINNC:description = "ACCUMULATED TOTAL GRID SCALE PRECIPITATION" ;

# Essas variáveis são cumulativas quanto aos passos futuros no tempo

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
nc_close(wrfout)

# For missing values in NetCDF files:
#  “fill values” (_FillValue) or missing values (missing_value)
# In R, we use NA for missing values:
#   rainnc[rainnc == fillvalue$value] <- NA
#   rainc[rainc == fillvalue$value] <- NA
# TODO: Erro: objeto 'fillvalue' não encontrado

# TODO Por enquanto não usado, mas para plotagem de imagens
lon <- xlon[,1,]
dim(lon)
lat <-  xlat[1,,]
dim(lat)


# Cálculo de precipitação acumulada TOTAL últimas 24 horas de previsão
#  rain_accum_in_mm <- rainnc[,,25]+rainc[,,25]
#  dim(rain_accum_in_mm)
#  rain_accum_in_mm <- rainnc[,,49]+rainc[,,49]-(rainnc[,,25]+rainc[,,25])
#  dim(rain_accum_in_mm)
#  rain_accum_in_mm <- rainnc[,,73]+rainc[,,73]-(rainnc[,,49] + rainc[,,49])
#  dim(rain_accum_in_mm)


# Nome e localização em termos de coordenadas WRF para os 25 pontos
#  Considerando o domínio da execução da conf B, cujo domínio D2 tem
#  resolução de 2km, daria uma área de 10x10km.

# pa pb pc pd pe
# pf pg ph pi pj
# pk pl pm pn po
# pp pq pr ps pt
# pu pv px pz py

prp_avg_area <- 0.0
prp_mean_area <- matrix(1:48, nrow = 24, ncol = 2)
colnames(prp_mean_area) <- c("hour","prp_mean_area")


if (DEBUG){
  print(paste(" --- Data extracted ---")) 
}

for (t in t_start:forecast_time-1){
  
  # pa: i-2,j+2
  r_pa <- rainnc[i-2,j+2,t+1]+rainc[i-2,j+2,t+1]-(rainnc[i-2,j+2,t]+rainc[i-2,j+2,t])
  # pb: i-1,j+2
  r_pb <- rainnc[i-1,j+2,t+1]+rainc[i-1,j+2,t+1]-(rainnc[i-1,j+2,t]+rainc[i-1,j+2,t])
  # pc: i,j+2
  r_pc <- rainnc[i,j+2,t+1]+rainc[i,j+2,t+1]-(rainnc[i,j+2,t]+rainc[i,j+2,t])
  # pd: i+1,j+2
  r_pd <- rainnc[i+1,j+2,t+1]+rainc[i+1,j+2,t+1]-(rainnc[i+1,j+2,t]+rainc[i+1,j+2,t])
  # pe: i+2,j+2
  r_pe <- rainnc[i+2,j+2,t+1]+rainc[i+2,j+2,t+1]-(rainnc[i+2,j+2,t]+rainc[i+2,j+2,t])
  
  # ----  pf pg ph pi pj
  # pf: i-2,j+1
  r_pf <- rainnc[i-2,j+1,t+1]+rainc[i-2,j+1,t+1]-(rainnc[i-2,j+1,t]+rainc[i-2,j+1,t])
  # pg: i-1,j+1
  r_pg <- rainnc[i-1,j+1,t+1]+rainc[i-1,j+1,t+1]-(rainnc[i-1,j+1,t]+rainc[i-1,j+1,t])
  # ph: i,j+1
  r_ph <- rainnc[i,j+1,t+1]+rainc[i,j+1,t+1]-(rainnc[i,j+1,t]+rainc[i,j+1,t])
  # pi: i+1,j+1
  r_pi <- rainnc[i+1,j+1,t+1]+rainc[i+1,j+1,t+1]-(rainnc[i+1,j+1,t]+rainc[i+1,j+1,t])
  # pj: i+2,j+1
  r_pj <- rainnc[i+2,j+1,t+1]+rainc[i+2,j+1,t+1]-(rainnc[i+2,j+1,t]+rainc[i+2,j+1,t])
  
  # ----  pk pl pm pn po
  # pk: i-2,j
  r_pk <- rainnc[i-2,j,t+1]+rainc[i-2,j,t+1]-(rainnc[i-2,j,t]+rainc[i-2,j,t])
  # pl: i-1,j
  r_pl <- rainnc[i-1,j,t+1]+rainc[i-1,j,t+1]-(rainnc[i-1,j,t]+rainc[i-1,j,t])
  # pm: i,j
  r_pm <- rainnc[i,j,t+1]+rainc[i,j,t+1]-(rainnc[i,j,t]+rainc[i,j,t])
  # pn: i+1,j
  r_pn <- rainnc[i+1,j,t+1]+rainc[i+1,j,t+1]-(rainnc[i+1,j,t]+rainc[i+1,j,t])
  # po: i+2,j
  r_po <- rainnc[i+2,j,t+1]+rainc[i+2,j,t+1]-(rainnc[i+2,j,t]+rainc[i+2,j,t])
  
  # ----  pp pq pr ps pt
  # pp: i-2,j-1
  r_pp <- rainnc[i-2,j-1,t+1]+rainc[i-2,j-1,t+1]-(rainnc[i-2,j-1,t]+rainc[i-2,j-1,t])
  # pq: i-1,j-1
  r_pq <- rainnc[i-1,j-1,t+1]+rainc[i-1,j-1,t+1]-(rainnc[i-1,j-1,t]+rainc[i-1,j-1,t])
  # pr: i,j-1
  r_pr <- rainnc[i,j-1,t+1]+rainc[i,j-1,t+1]-(rainnc[i,j-1,t]+rainc[i,j-1,t])
  # ps: i+1,j-1
  r_ps <- rainnc[i+1,j-1,t+1]+rainc[i+1,j-1,t+1]-(rainnc[i+1,j-1,t]+rainc[i+1,j-1,t])
  # pt: i+2,j-1
  r_pt <- rainnc[i+2,j-1,t+1]+rainc[i+2,j-1,t+1]-(rainnc[i+2,j-1,t]+rainc[i+2,j-1,t])
  
  # ----  pu pv px pz py
  # pu: i-2,j-1
  r_pu <- rainnc[i-2,j-2,t+1]+rainc[i-2,j-2,t+1]-(rainnc[i-2,j-2,t]+rainc[i-2,j-2,t])
  # pv: i-1,j-1
  r_pv <- rainnc[i-1,j-2,t+1]+rainc[i-1,j-2,t+1]-(rainnc[i-1,j-2,t]+rainc[i-1,j-2,t])
  # px: i,j-1
  r_px <- rainnc[i,j-2,t+1]+rainc[i,j-2,t+1]-(rainnc[i,j-2,t]+rainc[i,j-2,t])
  # pz: i+1,j-1
  r_pz <- rainnc[i+1,j-2,t+1]+rainc[i+1,j-2,t+1]-(rainnc[i+1,j-2,t]+rainc[i+1,j-2,t])
  # py: i+2,j-1
  r_py <- rainnc[i+2,j-2,t+1]+rainc[i+2,j-2,t+1]-(rainnc[i+2,j-2,t]+rainc[i+2,j-2,t])

  
  result <- c(r_pa, r_pb, r_pc, r_pd, r_pe, r_pf, r_pg, r_ph, r_pi, r_pj, r_pk, r_pl, r_pm, r_pn, r_po, r_pp, r_pq, r_pr, r_ps, r_pt, r_pu, r_pv, r_px, r_pz, r_py)
  # Remove missing values from calculus: na.rm=TRUE. If there were a missing value,
  #    then the function will end with a error.
  prp_avg_area <- mean(result, na.rm=TRUE)
  prp_mean_area[t,] <- c(t, prp_avg_area)
  
  if (DEBUG){
    print(paste("Hour:", t, "  ", "PRP area average:", prp_avg_area))
    print(result)
  }
}

# data <- data.frame(result)
# csvfilename <- paste(args[2],"-points.csv",sep="")
# write.csv2(data,file=csvfilename, row.names = TRUE)
# print(paste("Writing -> write.csv2(data,file=csvfilename, row.names = TRUE) - POINTS"))

data <- data.frame(prp_mean_area)
csvfilename <- paste(args[2], "-prp-area-hour.csv")
# write.csv2(data, file=csvfilename, row.names = TRUE, sep=".")
write.table(data, csvfilename, row.names=TRUE, sep=".")
print(paste("Writing -> write.csv2(data,file=csvfilename, row.names = TRUE) - AREA"))

# sink(filename_output)
# sink()


