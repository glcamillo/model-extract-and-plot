#!/usr/bin/env Rscript

# Objetivo: extrair dados de precipitação por ponto i e j de arquivos de saída WRF em formato NetCDF a cada uma hora ou a cada três horas.

# ./wrfout-extract-PRP-with-R-timeinterval.R  
#        wrfout_d02_2016-07-15_00.nc
#        caso-01-urussanga-20160715-D2-24h-PRP-from-R
#        120
#        110
#        24
#        AREA
#        1

# Argumentos
# args[1]=wrfout_d02_2016-12-03_00.nc
# args[2]=Nome arquivo SAIDA: caso-01-urussanga-20160715-D2-24h-PRP-from-R
# args[3]=120 coordenada x=i
# args[4]=110 coordenada y=j
# args[5]=24|48|72   horário previsão
# args[6]=POINT|AREA
# args[7]=[1|3] saída de hora em hora (1) ou a cada 3 horas (3)



library(ncdf4)

args <- commandArgs(trailingOnly = TRUE)

print(args)

# What the name of file (WRF output)
netcdf.file <- args[1]


# -----------------------------------------------------
#   Open the WRF output file (NetCDF format)
nc <- ncdf4::nc_open(netcdf.file)


# What time interval: from command line
time_forecast <- 3  # Default value: 3 hours
if (as.numeric(args[7]) == 1 || as.numeric(args[7]) == 3) {
    time_forecast <- as.numeric(args[7])
}

# Extract the coordinates from NetCDF file
xlon <- ncvar_get(nc, varid = 'XLONG')
nlon <- dim(xlon)

xlat <-  ncvar_get(nc, varid = 'XLAT')
nlat <- dim(xlat)

print(c(nlon,nlat))

i <- as.numeric(args[3])
print(paste("Coordenada i=x: ", i))
j <- as.numeric(args[4])
print(paste("Coordenada j=y: ", j))
# j=y=279  i=x=106
# i=120
# j=110

# forecast_time <- as.numeric(args[5])+1

ft <- as.numeric(args[5])+1

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



# Extract the time information from NetCDF file
time <- ncvar_get(nc, "XTIME")
ntime <- dim(time)
head(time)
tunits <- ncatt_get(nc, "XTIME", "units")
tunits[["value"]]

# Extract the next two PRP data from NetCDF file
#   produced by WRF

# RAINNC:description = "ACCUMULATED TOTAL GRID SCALE PRECIPITATION"
rainnc <- ncvar_get(nc, varid = "RAINNC")
runits <- ncatt_get(nc, "RAINNC", "units")
runits[["value"]]
dim(rainnc)

# RAINC:description = "ACCUMULATED TOTAL CUMULUS PRECIPITATION"
rainc <- ncvar_get(nc, varid = "RAINC")
runits <- ncatt_get(nc, "RAINC", "units")
runits[["value"]]
dim(rainc)

nc_close(nc)


# -----------------------------------------------------
#   Extract accumulated PRP (last 24h of forecast)
prp_val_in_mm_24 <- (rainc[i,j,ft]+rainnc[i,j,ft])-(rainc[i,j,ft_minus_24]+rainnc[i,j,ft_minus_24])
prp_val_in_mm <- prp_val_in_mm_24

prp_variable <- c("rainnc_e_rainc")

print(paste("24h: ",prp_val_in_mm_24," Result: ", prp_val_in_mm))

data <- data.frame(prp_variable, prp_val_in_mm)

filename_output <- paste(args[2],".csv",sep="")
write.csv(data,filename_output,  row.names = TRUE)

# -----------------------------------------------------
#   Extract accumulated PRP by increments of time_forecast
prp_for_24h = c(NA, length(ft))

#   This is for extract the last 24 hours of forecast
# for (t in ft_minus_24:ft-1) {
#    prp_in_a_hour <- (rainnc[i,j,t+1]+rainc[i,j,t+1])-(rainnc[i,j,t]+rainc[i,j,t])
#    print(paste("Hour: ", t, "PRP in mm: ", prp_in_a_hour))
#    prp_for_24h[t] <- prp_in_a_hour
#}

# Data Frame
# To avoid the automatic conversion of char strings in FACTOR: stringAsFactors=FALSE
# new variable -> columns -> cbind
# more records -> rows    -> rbind
# df = data.frame(hora_previsao=c(), prp_por_hora=c(), stringAsFactors=FALSE)
df = data.frame(hora_previsao=c(), prp_por_hora=c())


# This is for extract the prp for all the time forecast
for (t in 2:ft-1) {
    prp_in_a_hour <- (rainnc[i,j,t+1]+rainc[i,j,t+1])-(rainnc[i,j,t]+rainc[i,j,t])
    print(paste("Hour: ", t, "PRP in mm: ", prp_in_a_hour))
    hora_previsao = c(t)
    prp_por_hora = c(prp_in_a_hour)
    df = rbind(df, data.frame(hora_previsao, prp_por_hora))
}

dim(df)
nrow(df)
ncol(df)


filename_output <- paste(args[2],"-por-hora.csv",sep="")
#write.table(results, filename_output, row.names=FALSE,sep=",")

write.table(df, filename_output, row.names=FALSE,sep=",")



