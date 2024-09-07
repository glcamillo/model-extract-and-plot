# model-extract-and-plot
Scripts in R, GrADS, and Python for extraction and plot meteorological data from NetCDF files (WRF output)

A brief description will be provided for two scripts that manipulate NetCDF files (WRF output data forecast). They are in a state of **specific problem solving** and do not contain clean code and comments/help for now.


## Information about the file `wrfout-extract-PRP-with-R-casos-Eliseo-for-24-48-72h.R`

Main purpose: Extract total precipitation data from 25 grid points (**i** and **j**) from a WRF output file (NetCDF format) and summarize the results, writing them to a CSV output file. The results correspond to 24h, 48h or 72h of accumulated precipitation, considering the parameter for the script and the forecast period contained in the WRF output data.

### What the script does:
1. Reads the coordinates **i** and **j** as a parameter
2. Extracts PRP data (RAINNC and RAINC) from 25 points around **i** and **j**
3. Summarizes the results of the area that corresponds to the 25 points
4. Saves the result to a CSV file

### How execute the script:
`./wrfout-extract-PRP-with-R-casos-Eliseo-for-24-48-72h.R
        wrfout_d02_2016-07-15_00.nc
        caso-01-urussanga-20160715-D2-24h-PRP-from-R
        120 110
        24
        AREA`

### About the Arguments
- args[1]=wrfout_d02_2016-12-03_00.nc   Name of the file of the WRF that contains de forecast data in format NetCDF
- args[2]=caso-01-urussanga-20160715-D2-24h-PRP-from-R     Name of the output file (contains data for the points and statistical summary)
- args[3]=120    Coordinate WRF x=i
- args[4]=110    Coordinate WRF y=j
- args[5]=24|48|72   How many hours of forecast that will be extracted? The precipitation is accumulated for each future time step
- args[6]=POINT|AREA  If the extration will be for point or area (only implemented for area)


## Information about the file `wrfout-extract-PRP-with-R-for10kmAREA-and-statistics-from-D2.R`

This script is written in [R language](https://www.r-project.org/) and the objectives are:
1. Extract PRP (total precipitation) variable from NetCDF files that were generated by WRF
2. Calculate difference between forecast and observed values for some stations (that are hard-coded in the code, including the observational data)
3. Calculate some statistics  (BIAS, RMSE)
4. Save the results in CSV files

### Some important observations:
1. The script is configured for a **specific** grid configuration used in WRF execution. The points **i** and **j** correspond to the  coordinates of the stations pre-configured in the script.
2. The WRF configuration domain used can be seen at these links:
>  [https://github.com/glcamillo/model-wrf/tree/main/config-domains](https://github.com/glcamillo/model-wrf/tree/main/config-domains)

>  [https://github.com/glcamillo/model-wrf/blob/main/config-domains/r_sul-RS-SC-2d/projection.jpg](https://github.com/glcamillo/model-wrf/blob/main/config-domains/r_sul-RS-SC-2d/projection.jpg)
3. The 10 km AREA results in a 25 points around the station in the  Domain 2 of the output file from WRF (wrfout_d02_2015-07-24_00_00_00)  (domain configuration as pointed in 2.)

### How execute:
1. Set the executable bit:
  `chmod u+x wrfout-extract-PRP-with-R-for10kmAREA-and-statistics-from-D2.R`
2. Execute with the next parameters:
  `./wrfout-extract-PRP-with-R-for10kmAREA-and-statistics-from-D2.R
        wrfout_d02_2020-08-14_00.nc
        data-prp-pbl_BOUGEAULT-8-mp_MADWRF-96
        ALL
        24
        AREA`


### About the Arguments
- args[1]=wrfout_d02_2020-08-14_00.nc    NetCDF file from WRF output
- args[2]=data-prp-pbl_BOUGEAULT-8-mp_MADWRF-96        Name of output file (CSV data)
- args[3]=ALL            ALL for all meteorological stations (name or ALL)
- args[4]=24             Time of forecast (24,48, or 72 hours)
- args[5]=POINT|AREA     This script will extract only AREA for now


## About the stations:
The argument for station can be: a) only one, or b) the code `ALL`. The `ALL` means the next stations:
- CH: Chapecó
- XA: Xanxerê
- JO: Joaçaba
- CN: Campos Novos
- CR: Curitibanos
- CA: Caçador

Coordinates and the corresponding **i** and **j** WRF points.
1. CH: Chapecó  -27.0853111  -52.6357111   679
   WRF Grid points: -27.0789 j=236  -52.629 x=155
2. XA: Xanxerê -26.938666  -52.39809   878,74
   WRF Grid points: -26.9241 j=243   -50.3976 i=167
3. JO: Joaçaba -27.16916666 -51.55888888  767,63
   WRF Grid points: -27.1572 j=231   -51.5555 i=209
4. CN: Campos Novos -27.3886111 -51.21583333 963
   WRF Grid points: -27.3935 j=218   -51.214  i=226
5. CT: Curitibanos  -27.288624 -50.604283 978,1
   WRF Grid points: -27.2348 j=227   -50.5938 i=257
6. CA: Caçador   -26.819156  -50.98552   944,26m
   WRF Grid points: -26.811  j=250    -50.992  x=238

The **times** data found ina a 24 hour forecast (WRF output)
Times: ['2020-08-14T00:00:00.000000000' '2020-08-14T01:00:00.000000000'
 '2020-08-14T02:00:00.000000000' '2020-08-14T03:00:00.000000000'
 '2020-08-14T04:00:00.000000000' '2020-08-14T05:00:00.000000000'
 '2020-08-14T06:00:00.000000000' '2020-08-14T07:00:00.000000000'
 '2020-08-14T08:00:00.000000000' '2020-08-14T09:00:00.000000000'
 '2020-08-14T10:00:00.000000000' '2020-08-14T11:00:00.000000000'
 '2020-08-14T12:00:00.000000000' '2020-08-14T13:00:00.000000000'
 '2020-08-14T14:00:00.000000000' '2020-08-14T15:00:00.000000000'
 '2020-08-14T16:00:00.000000000' '2020-08-14T17:00:00.000000000'
 '2020-08-14T18:00:00.000000000' '2020-08-14T19:00:00.000000000'
 '2020-08-14T20:00:00.000000000' '2020-08-14T21:00:00.000000000'
 '2020-08-14T22:00:00.000000000' '2020-08-14T23:00:00.000000000'
 '2020-08-15T00:00:00.000000000']  Size: 25

### Observation about PRP variable
- RAINC:description = "ACCUMULATED TOTAL CUMULUS PRECIPITATION" ;
- RAINSH:description = "ACCUMULATED SHALLOW CUMULUS PRECIPITATION" ;
- RAINNC:description = "ACCUMULATED TOTAL GRID SCALE PRECIPITATION" ;
These variables accumulate forecast precipitation in each time steps

#  Some references about R and statistics
Statistics from Package `Metrics`: generate unique values
[https://cran.r-project.org/web/packages/Metrics/Metrics.pdf](https://cran.r-project.org/web/packages/Metrics/Metrics.pdf)
- **ae** (absolute error): output a vector with absolute differences
- **mae**, **bias**, **rmse**: summarization stats

Last revision: 20240907
