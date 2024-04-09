#!/bin/bash
# Author: Gerson L Camillo

# What this do: execute the R script
#     extract-from-wrfout-with-R-AREA-10km-attime-from-D2.R
#   for all the stations (codename and grid point coordinate)

# Rev.:
#  v.1 20240322: initial

# ./extract-PRP-from-WRF-for-all-stations.sh
#        wrfout_d02_2020-08-14_00.nc  KES  MRF


# --- Arguments: observations
# $1=wrfout_d02_2020-08-14_00.nc    NetCDF file from WRF output
# $2=KESS               Code for MP scheme
# $3=MRF               Code for PBL scheme

# Reference for parameterization options:
#   https://github.com/wrf-model/WRF/blob/master/run/README.namelist
#1, KESS, Kessler scheme
#99, MRF, MRF scheme

# --- Checking the arguments
if [ -z $1 ]; then
    echo "ERROR. Missing the namefile of NetCDF (output from WRF)."
    echo "$0 FILENAME_OF_NETCDF"
    exit
else
    NETCDF=$1
fi

# MP argument
if [ -z $2 ]; then
    echo "ERROR. Missing the MP parameter (parameterization option)."
    echo "Example: $0 FILENAME_OF_NETCDF KES"
    exit
else
    PARAM_MP=$2
fi


# PBL argument
if [ -z $3 ]; then
    echo "ERROR. Missing the PBL parameter (parameterization option)."
    echo "Example: $0 FILENAME_OF_NETCDF KES MRF"
    exit
else
    PARAM_PBL=$3
fi

#
TIME_FRAME=attime
# 

# INMET Stations for surface observations
# CH: Chapecó
# XA: Xanxerê
# JO: Joaçaba
# CN: Campos Novos
# CR: Curitibanos
# CA: Caçador

# 1. CH: Chapecó  -27,0853111  -52,6357111   679
#    WRF Grid points: -27.0789 j=236  -52.629 i=155
# 2. XA: Xanxerê -26,938666  -52,39809   878,74
#    WRF Grid points: -26.9241 j=243   -50.3976 i=167
# 3. JO: Joaçaba -27,16916666 -51,55888888  767,63
#    WRF Grid points: -27.1572 j=231   -51.5555 i=209
# 4. CN: Campos Novos -27,3886111 -51,21583333 963
#    WRF Grid points: -27.3935 j=218   -51.214  i=226
# 5. CT: Curitibanos  -27,288624 -50,604283 978,1
#    WRF Grid points: -27.2348 j=227   -50.5938 i=257
# 6. CA: Caçador   -26,819156  -50,98552   944,26m
#    WRF Grid points: -26.811  j=250    -50.992  i=238

# INDEXED Arrays
# declare -a stations
# declare -a stations=("CH" ...)
# stations[0]="CH" ...
stations=("CH" "XA" "JO" "CN" "CT" "CA")
st_coord_i=(155 167 209 226 257 238)
st_coord_j=(236 243 231 218 227 250)

# ASSOCIATIVE Arrays
# declare -A stations_i=(["CH"]=155 ["XA"]=167 ...)

# Printing: stations[@]
# for value in ${stations_i[@]} do echo "["$value"]" done

# ./extract-from-wrfout-with-R-AREA-10km-attime-from-D2.R wrfout_d02_2020-08-14_00.nc case-01-MP-and-PBL-99-CH-attime 155 236 CH 24 AREA attime


# Aqui o ls lista os arquivos dentro do diretório
for n in $(seq 0 5); do
    echo "${stations[n]} i=${st_coord_i[n]} j=${st_coord_j[n]}"
    ./extract-from-wrfout-with-R-AREA-TIME-10km-attime-from-D2.R $NETCDF data-prp-pbl_$PARAM_PBL-mp_$PARAM_MP-${stations[n]}-attime ${st_coord_i[n]} ${st_coord_j[n]} ${stations[n]} 24 AREA $TIME_FRAME
done


