#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Autor: Gerson Camillo
# Last revision:20240407

# python3 plot_wrf_for_ifsc.py  "/media/cirrus/0fa99504-ca1f-4274-89d6-c49ebd1b704f/model-data-output-projeto-IFSC/config-B-pbl-YSU-e-mp-VARIANDO/2020-08-14-00_dom_r_sul-RS-SC-2d/wrf-h/wrfout_d02_2020-08-14_00.nc"
# conda info --envs
# # conda environments:
# #
# base                     /home/cirrus/bin/miniconda3
# tutorial_2019            /home/cirrus/bin/miniconda3/envs/tutorial_2019
# wrfpy                    /home/cirrus/bin/miniconda3/envs/wrfpy
#
# @pyfwrf$ conda activate wrfpy
# (wrfpy) @pyfwrf$

##################################
# Imports
from netCDF4 import Dataset
import matplotlib.pyplot as plt
from matplotlib.cm import get_cmap
import cartopy.crs as crs
from cartopy.feature import NaturalEarthFeature

# from matplotlib.colormaps import get_cmap

import numpy as np

import traceback
from os.path import join
from os import getcwd
from sys import path, exit, argv

from wrf import (to_np, getvar, smooth2d, cape_2d, srhel, get_cartopy, cartopy_xlim, cartopy_ylim, latlon_coords, extract_times,
                 ALL_TIMES, interplevel)
##################################
# Some help
"""
Program (Python Script) that uses the framework wrf-python for read and plot NetCDF files from WRF output.
Main goal: 
Data definitions: globally defined data
References:
"""

##################################
# Function used to create the map subplots
def plot_background(ax):
    """
    :param ax:
    :return:
    # Define extents
    lat = [lats.min(), lats.max()]
    lon = [lons.min(), lons.max()]
    # format the plot
    axs.format(lonlim=lon, latlim=lat, labels=True, innerborders=True)

    """
    ax.set_extent([235., 290., 20., 55.])
    ax.add_feature(cfeature.COASTLINE.with_scale('50m'), linewidth=0.5)
    ax.add_feature(cfeature.STATES, linewidth=0.5)
    ax.add_feature(cfeature.BORDERS, linewidth=0.5)
    return ax


def init_netcdf4_dataset(nc_filename):
    global nc
    global hgt
    global times

    ##################################
    #  Definitions
    #  Patthern of WRF Output files
    #   "wrfout_d02_2020-08-14_00_00_00.nc"
    interp_levels = [200, 300, 500, 1000]
    nc_filename_sample = "/media/cirrus/0fa99504-ca1f-4274-89d6-c49ebd1b704f/model-data-output-projeto-IFSC/config-B-pbl-YSU-e-mp-VARIANDO/2020-08-14-00_dom_r_sul-RS-SC-2d/wrf-h/wrfout_d02_2020-08-14_00.nc"

    ##################################
    #  Open and Extract basic info from NetCDF

    # Open the NetCDF file
    try:
        nc = Dataset(nc_filename, "r")
    except:
        trace = traceback.format_exc()
        print('ERROR - exiting: ', trace)
        open('trace.log', 'a').write(trace)
        sys.exit(1)
    #finally:
    #    nc.close()
    """ Coordinates:
        XLONG    (south_north, west_east) float32 577kB -55.87 -55.85 ... -48.05
        XLAT     (south_north, west_east) float32 577kB -31.3 -31.3 ... -24.58
        XTIME    float32 4B 0.0
        Time     datetime64[ns] 8B 2020-08-14
    """

    print(nc.variables.keys()) # get all variable names
    temp = nc.variables['T']  # temperature variable
    print(temp)
    print(nc.__dict__)

    # Extract terrain height for coordinates
    hgt = getvar(nc, "HGT")
    print(hgt)

    # Create a clean datetime object for plotting based on time of Geopotential heights
    # vtime = datetime.strptime(str(nc.time.data[0].astype('datetime64[ms]')), '%Y-%m-%dT%H:%M:%S.%f')

    # Extract times
    # Ref.: https://numpy.org/doc/stable/reference/arrays.datetime.html
    # >>> type(times)
    # <class 'numpy.ndarray'>
    times = extract_times(nc, timeidx=ALL_TIMES)

    # times -> numpy.ndarray.size
    # ndarray.size: Number of elements in the array.
    print("Times:", times, " Size:", times.size)
    for t in range(times.size):
        t_timestamp = times[t]
        print(f"Time[{t}]=", t_timestamp.astype('datetime64[h]'))



def plot_surface_pressure():
    # Get the sea level pressure
    slp = getvar(nc, "PSFC", 5)
    print(slp)

    # Smooth the sea level pressure since it tends to be noisy near the
    # mountains
    # smooth_slp = smooth2d(to_np(slp*0.01), 3, cenweight=4)
    smooth_slp = smooth2d(np.multiply(slp, 0.01), 3, cenweight=4)
    # Option from MetPy
    # mslp = units.Quantity(mslp_var[:].squeeze(), mslp_var.units).to('hPa')

    # Get the latitude and longitude points
    lats, lons = latlon_coords(hgt)

    # Get the cartopy mapping object
    cart_proj = get_cartopy(hgt)

    # Create a figure
    fig = plt.figure(figsize=(12, 6))

    # Set the GeoAxes to the projection used by WRF
    ax = plt.axes(projection=cart_proj)

    # Download and add the states and coastlines
    states = NaturalEarthFeature(category="cultural", scale="110m", facecolor="none",
                                 name="admin_0_boundary_lines_land")

    ax.add_feature(states, linewidth=.5, edgecolor="black")
    ax.coastlines('110m', linewidth=0.8)

    # Make the contour outlines and filled contours for the smoothed sea level
    # pressure.
    plt.contour(to_np(lons), to_np(lats), to_np(smooth_slp), 10, colors="black",
                transform=crs.PlateCarree())
    plt.contourf(to_np(lons), to_np(lats), to_np(smooth_slp), 10,
                 transform=crs.PlateCarree(),
                 cmap=get_cmap("jet"))

    # Add a color bar
    plt.colorbar(ax=ax, shrink=.98)

    # Set the map bounds
    ax.set_xlim(cartopy_xlim(smooth_slp))
    ax.set_ylim(cartopy_ylim(smooth_slp))

    # Add the gridlines
    ax.gridlines(color="black", linestyle="dotted")

    plt.title("Sea Level Pressure (hPa)")
    plt.show()


def timestring(wrftime, curtime):
    curtime_str = '%02.0f' % curtime
    wrfdt = datetime.strptime(wrftime, '%Y-%m-%d_%H:%M:%S')
    outtime = '%sZ F%s' % (wrfdt.strftime('%a %Y%m%d/%H%M'), curtime_str)
    return outtime


def plot_geo_500():
    # Extract the Geopotential Height and Pressure (hPa) fields
    z = getvar(nc, "z")
    p = getvar(nc, "pressure")
    # Compute the 500 MB Geopotential Height
    ht_500mb = interplevel(z, p, 500.)
    print(ht_500mb)


def plot_precip():
    """
    # First, find out if this is first time or not
    # Based on skip.  This should be total from each output time
    if time == 0:
        prev_total = rainc[time] + rainnc[time]
    else:
        prev_total = rainc[time-1] + rainnc[time-1]
    total_accum = rainc[time] + rainnc[time]
    precip_tend = total_accum  - prev_total
    
    # Convert from mm to in
    # precip_tend = precip_tend * .0393700787
    # units = 'in'
    PCP_LEVELS = [0.01,0.03,0.05,0.10,0.15,0.20,0.25,0.30,0.40,0.50,0.60,0.70,0.80,0.90,1.00,1.25,1.50,1.75,2.00,2.50]
    PRECIP=plt.contourf(x,y,precip_tend,PCP_LEVELS,cmap=coltbls.precip1())
    #plt.jet()
    title = '%s Hour Precip' % skip
    prodid = 'precip'

    drawmap(PRECIP, title, prodid, units)

    """
    # slp = getvar(nc, "RAINC", timeidx=ALL_TIMES)
    # times -> numpy.ndarray.size
    # ndarray.size: Number of elements in the array.
    print("Times:", times, " Size:", times.size)
    for t in range(times.size - 20):
        print(f"Time[{t}]=", {t})
        rainc = getvar(nc, "RAINC", timeidx=t)
        # rainc = getvar(nc, "RAINC")
        print(type(rainc))
        print(rainc)
        rainnc = getvar(nc, "RAINNC", timeidx=t)
        # rainnc = getvar(nc, "RAINNC")
        print(type(rainnc))
        print(rainnc)
        rainc_tnext = getvar(nc, "RAINC", timeidx=t + 1)
        print(rainc_tnext)
        rainnc_tnext = getvar(nc, "RAINNC", timeidx=t + 1)
        print(rainnc_tnext)
        prp_hour = to_np(rainc + rainnc)
        if t != 0:
            prp_hour = to_np(rainc_tnext + rainnc_tnext - prp_hour)
        print(type(prp_hour))
        print(f"prp_hour: {prp_hour}")
        units = 'mm'
        PCP_LEVELS = [0.1, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 2.5, 3.0, 4, 5, 6, 8, 10, 15, 20, 25, 30, 40, 50]

        #   Smooth since it tends to be noisy near the mountains
        smooth_prp = smooth2d(prp_hour, 3, cenweight=4)

        # Get the latitude and longitude points
        lats, lons = latlon_coords(hgt)

        # Get the cartopy mapping object
        cart_proj = get_cartopy(hgt)

        # Create a figure
        fig = plt.figure(figsize=(12, 6))

        # Set the GeoAxes to the projection used by WRF
        ax = plt.axes(projection=cart_proj)

        # Download and add the states and coastlines
        states = NaturalEarthFeature(category="cultural", scale="50m", facecolor="none",
                                     name="admin_0_boundary_lines_land")

        # Add state/country boundaries to plot
        # ax.add_feature(cfeature.STATES)
        # ax.add_feature(cfeature.BORDERS)
        ax.add_feature(states, linewidth=.5, edgecolor="black")
        ax.coastlines('50m', linewidth=0.8)

        # Set Projection of Data
        datacrs = crs.PlateCarree()

        # Set Projection of Plot
        # plotcrs = crs.LambertConformal(central_latitude=[30, 60], central_longitude=-100)

        # Make the contour outlines and filled contours for the smoothed.
        plt.contour(to_np(lons), to_np(lats), to_np(prp_hour), PCP_LEVELS,
                    colors="black",
                    transform=datacrs)
        plt.contourf(lons, lats, prp_hour, PCP_LEVELS, transform=datacrs,
                     # cmap=matplotlib.colormaps.get_cmap("rainbow"))
                     cmap=get_cmap("rainbow"))
        # rainbow | jet

        # Add a color bar
        plt.colorbar(ax=ax, shrink=.98)

        # Set the map bounds
        # ax.set_xlim(cartopy_xlim(smooth_prp))
        # ax.set_ylim(cartopy_ylim(smooth_prp))

        ax.set_xlim(cartopy_xlim(hgt))
        ax.set_ylim(cartopy_ylim(hgt))

        # Add the gridlines
        ax.gridlines(color="black", linestyle="dotted")

        t_timestamp = times[t]
        timestamp = t_timestamp.astype('datetime64[h]')
        print(f"timestamp:{t_timestamp} - {str(timestamp)}")
        plt.title("Precipitação (mm/h) - " + str(timestamp))
        # plt.show()
        filename = "prp-" + str(timestamp) + ".png"
        fig.savefig(filename, dpi=600)

def plot_cape2d(cape_2d, index, time):
    """
    cape2d_types = {1:" MCAPE", 2:MCIN [J kg-1]
    return_val[2,…] will contain LCL [m]
    return_val[3,…] will contain LFC [m]}
    :return:
    """
    print("\n ====== Plotting CAPE 2D ======= \n ")

    cape2d_types = {0: "MCAPE", 1: "MCIN", 2: "LCL", 3: "LFC"}
    t_timestamp = times[time]
    timestamp = t_timestamp.astype('datetime64[h]')
    print(f"timestamp:{t_timestamp} - {str(timestamp)}")

    if index == 0: # MCAPE levels
        LEVELS = [100, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000]
        title = "MCAPE (J*kg-1) - " + str(timestamp)
        print(title)
        filename = "mcape-" + str(timestamp) + ".png"
    elif index == 1: # MCIN levels
        LEVELS = [10, 20, 30, 40, 50, 75, 100, 150, 200, 250, 300, 400, 500, 600, 700, 800, 1000]
        title = "MCIN (J*kg-1) - " + str(timestamp)
        print(title)
        filename = "mcin-" + str(timestamp) + ".png"
    elif index == 2:
        LEVELS = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1200, 1400, 1600, 1800, 1900, 2000]
        title = "LCL (m) - " + str(timestamp)
        print(title)
        filename = "lcl-" + str(timestamp) + ".png"
    elif index == 3:
        LEVELS = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1200, 1400, 1600, 1800, 1900, 2000]
        title = "LFC (m) - " + str(timestamp)
        print(title)
        filename = "lfc-" + str(timestamp) + ".png"


    #   Smooth since it tends to be noisy near the mountains
    # smooth_prp = smooth2d(prp_hour, 3, cenweight=4)

    # Get the latitude and longitude points
    lats, lons = latlon_coords(hgt)

    # Get the cartopy mapping object
    cart_proj = get_cartopy(hgt)

    # Create a figure
    fig = plt.figure(figsize=(12, 6))

    # Set the GeoAxes to the projection used by WRF
    ax = plt.axes(projection=cart_proj)

    # Download and add the states and coastlines
    states = NaturalEarthFeature(category="cultural", scale="50m", facecolor="none",
                             name="admin_0_boundary_lines_land")

    # Add state/country boundaries to plot
    # ax.add_feature(cfeature.STATES)
    # ax.add_feature(cfeature.BORDERS)
    ax.add_feature(states, linewidth=.5, edgecolor="black")
    ax.coastlines('50m', linewidth=0.8)

    # Set Projection of Data
    datacrs = crs.PlateCarree()

    # Set Projection of Plot
    # plotcrs = crs.LambertConformal(central_latitude=[30, 60], central_longitude=-100)

    # Make the contour outlines and filled contours for the smoothed.
    plt.contour(to_np(lons), to_np(lats), to_np(cape_2d), LEVELS,
            colors="black",
            transform=datacrs)
    plt.contourf(lons, lats, cape_2d, LEVELS, transform=datacrs,
             # cmap=matplotlib.colormaps.get_cmap("rainbow"))
             cmap=get_cmap("rainbow"))
    # rainbow | jet

    # Add a color bar
    plt.colorbar(ax=ax, shrink=.98)

    # Set the map bounds
    # ax.set_xlim(cartopy_xlim(smooth_prp))
    # ax.set_ylim(cartopy_ylim(smooth_prp))

    ax.set_xlim(cartopy_xlim(hgt))
    ax.set_ylim(cartopy_ylim(hgt))

    # Add the gridlines
    ax.gridlines(color="black", linestyle="dotted")

    plt.title(title)
    fig.savefig(filename, dpi=600)


def calc_cape2d():
    """
    https://wrf-python.readthedocs.io/en/latest/diagnostics.html
    mcape 	cape_2d 	2D Max CAPE 	J kg-1
    mcin 	cape_2d 	2D Max CIN 	J kg-1
    lcl 	cape_2d 	2D Lifted Condensation Level 	m
    lfc 	cape_2d 	2D Level of Free Convection 	m
    https://github.com/scavallo/python_scripts/blob/master/wrf_interp/parallel_interp_pres.py
    """
    cape2d_types = {0:"MCAPE", 1:"MCIN", 2:"LCL", 3:"LFC"}
    print("Times:", times, " Size:", times.size)
    # for t in range(times.size - 1):
    for t in range(10, 15):
        print(f"Time[{t}]=", {t})
        # PB and P (base and pertrubation pressure) variables and calls the
        #    _pert_add function and returns the result
        pb = getvar(nc, "PB", timeidx=t)
        p = getvar(nc, "P", timeidx=t)
        # 'Full Model Pressure'.
        pres_pa = to_np(pb + p)
        pres_hpa = to_np(pres_pa * 0.01)
        # pres_hpa = getvar(nc, "PB", timeidx=t)
        print(type(pres_hpa))
        print(pres_hpa)

        #    """ Calculate the potential temperature given the Perturbation Potential Temperature (T) in degrees Kelvin.
        #     ---------------------
        #     T (numpy.ndarray): ndarray of Perturbation Potential Temperature from WRF
        #     ---------------------
        #     returns:
        #         numpy.ndarray of potential temperature in degrees Kelvin, same shape as T
        #         """
        #     return T + 30
        t_theta = getvar(nc, "T", timeidx=t)
        #         float T(Time, bottom_top, south_north, west_east) ;
        #                 T:description = "perturbation potential temperature theta-t0" ;
        #                 T:units = "K" ;
        #     """ Calculate the 'normal' temperature in degrees Kelvin given the
        #     Potential Temperature (THETA in Kelvin) and Pressure (PRES in hPa or mb).
        #     PRES and THETA must be the same shape.
        #     ---------------------
        #     THETA (numpy.ndarray): ndarray of potential temperature in degrees Kelvin
        #     PRES (numpy.ndarray): ndarray of pressure in hPa or mb same shape as TH
        tkel = to_np(t_theta * (pres_pa / 1000)**(0.2854))
        print(type(tkel))
        print(tkel)
        # qv = getvar(nc, "QVAPOR", timeidx=t + 1)
        qv = getvar(nc, "QVAPOR", timeidx=t)
        print(type(qv))
        print(qv)

        #    """ Calculate the geopotential height given the Perturbation Geopotential (PH) and the Base State
        #         Geopotential (PHB). PH and PHB must be the same shape.
        #     ---------------------
        #     PH (numpy.ndarray): ndarray of Perturbation Geopotential from WRF
        #     PHB (numpy.ndarray): ndarray of Base State Geopotential fr
        height = to_np((pb + p) / 9.81)
        print(type(height))
        print(height)
        # terrain (xarray.DataArray or numpy.ndarray) – Terrain height in [m]. This is at least a two-dimensional array with the same dimensionality as pres_hpa, excluding the vertical (bottom_top/top_bottom) dimension.
        #   When operating on a single vertical column, this argument must be a scalar
        # terrain = getvar(nc, "HGT", timeidx=t + 1)
        terrain = getvar(nc, "HGT", timeidx=t)
        print(type(terrain))
        print(terrain)

        # psfc_hpa = getvar(nc, "PSFC", timeidx=t + 1)
        psfc_hpa = getvar(nc, "PSFC", timeidx=t)
        print(type(psfc_hpa))
        print(psfc_hpa)
        # A boolean that should be set to True if the data uses
        #    terrain following coordinates (WRF data).
        #    Set to False for pressure level data.
        ter_follow = True
        print(type(ter_follow))
        print(ter_follow)

        #  wrf.cape_2d(pres_hpa, tkel, qv, height, terrain, psfc_hpa, ter_follow, missing=<MagicMock name='mock().item()' id='140675643013392'>, meta=True)
        #
        #  Return the two-dimensional MCAPE, MCIN, LCL, and LFC.
        #  return_val[0,…] will contain MCAPE [J kg-1]
        #  return_val[1,…] will contain MCIN [J kg-1]
        #  return_val[2,…] will contain LCL [m]
        #  return_val[3,…] will contain LFC [m]
        # The cape, cin, lcl, and lfc values as an array whose leftmost
        # dimension is 4 (0=CAPE, 1=CIN, 2=LCL, 3=LFC) . If xarray is enabled
        # and the meta parameter is True, then the result will be an xarray.DataArray object.
        # Otherwise, the result will be a numpy.ndarray object with no metadata.
        diag_cape_2d = cape_2d(pres_hpa=pres_hpa, tkel=tkel, qv=qv, height=height, terrain=terrain, psfc_hpa=psfc_hpa, ter_follow=ter_follow)
        for i in range(0,3):
            print(diag_cape_2d[i])
            plot_cape2d(to_np(diag_cape_2d[i]), i, t)


def calc_plot_srhel():
    """
    https://wrf-python.readthedocs.io/en/latest/user_api/generated/wrf.srhel.html
    Return the storm relative helicity.
    This function calculates storm relative helicity from WRF ARW output.
    SRH (Storm Relative Helicity) is a measure of the potential for cyclonic
    updraft rotation in right-moving supercells, and is calculated for the
    lowest 1-km and 3-km layers above ground level. There is no clear threshold
    value for SRH when forecasting supercells, since the formation of supercells
    appears to be related more strongly to the deeper layer vertical shear.
    Larger values of 0-3 km SRH (greater than 250 m2 s-2) and
    0-1 km SRH (greater than 100 m2 s-2), however, do suggest an increased threat
    of tornadoes with supercells. For SRH, larger values are generally better,
    but there are no clear “boundaries” between non-tornadic and significant tornadic supercells.
    """
    # slp = getvar(nc, "RAINC", timeidx=ALL_TIMES)
    # times -> numpy.ndarray.size
    # ndarray.size: Number of elements in the array.
    print("Times:", times, " Size:", times.size)
    #for t in range(times.size - 1):
    for t in range(10, 15):
        print(f"Time[{t}]=", {t})
        u = getvar(nc, "U", timeidx=t)
        v = getvar(nc, "V", timeidx=t)
        #  Calculate the geopotential height given:
        #     Perturbation Geopotential (PH) and Base State Geopotential (PHB).
        #     PH and PHB must be the same shape.
        #     PH (numpy.ndarray): ndarray of Perturbation Geopotential from WRF
        #     PHB (numpy.ndarray): ndarray of Base State Geopotential fr
        pb = getvar(nc, "PB", timeidx=t)
        p = getvar(nc, "P", timeidx=t)
        height = to_np((pb + p) / 9.81)
        print(type(height))
        print(height)
        # terrain (xarray.DataArray or numpy.ndarray) – Terrain height in [m].
        #  This is at least a two-dimensional array with the same dimensionality
        #     as u, excluding the bottom_top dimension.
        # This variable must be supplied as a xarray.DataArray in order to copy
        # the dimension names to the output. Otherwise, default names will be used.
        # terrain = getvar(nc, "HGT", timeidx=t + 1)
        terrain = getvar(nc, "HGT", timeidx=t)
        print(type(terrain))
        print(terrain)

        # top (float) – The height of the layer below which helicity is
        #    calculated (meters above ground level).
        top_0to3 = 3000.0
        top_0to1 = 1000.0

        # lats (xarray.DataArray or numpy.ndarray, optional) – Array of latitudes.
        #  This is required if any (or all) of your domain is in the southern hemisphere.
        #  If not provided, the northern hemisphere is assumed. Default is None.
        lats, lons = latlon_coords(hgt)

        #  wrf.srhel(u, v, height, terrain, top=3000.0, lats=None, meta=True)
        #
        #  The storm relative helicity. If xarray is enabled and the meta parameter is True,
        #   then the result will be an xarray.DataArray object.
        #   Otherwise, the result will be a numpy.ndarray object with no metadata.
        diag_srhel_0to3 = srhel(u=u, v=v, height=height, terrain=terrain, top=top_0to3, lats=lats, meta=True)
        diag_srhel_0to1 = srhel(u=u, v=v, height=height, terrain=terrain, top=top_0to1, lats=lats, meta=True)
        LEVELS = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280]

        #   Smooth since it tends to be noisy near the mountains
        #smooth_prp = smooth2d(prp_hour, 3, cenweight=4)
        cart_proj = get_cartopy(hgt)
        fig = plt.figure(figsize=(12, 6))
        ax = plt.axes(projection=cart_proj)
        states = NaturalEarthFeature(category="cultural", scale="50m", facecolor="none",
                                     name="admin_0_boundary_lines_land")
        ax.add_feature(states, linewidth=.5, edgecolor="black")
        ax.coastlines('50m', linewidth=0.8)
        datacrs = crs.PlateCarree()
        plt.contour(to_np(lons), to_np(lats), to_np(diag_srhel_0to3), LEVELS,
                    colors="black",
                    transform=datacrs)
        plt.contourf(lons, lats, diag_srhel_0to3, LEVELS, transform=datacrs,
                     # cmap=matplotlib.colormaps.get_cmap("rainbow"))
                     cmap=get_cmap("rainbow"))
        plt.colorbar(ax=ax, shrink=.98)
        ax.set_xlim(cartopy_xlim(hgt))
        ax.set_ylim(cartopy_ylim(hgt))
        ax.gridlines(color="black", linestyle="dotted")
        t_timestamp = times[t]
        timestamp = t_timestamp.astype('datetime64[h]')
        plt.title("SRH 0-3km (Storm Relative Helicity) (m^2/s^2) - " + str(timestamp))
        filename = "srh-0to3-" + str(timestamp) + ".png"
        fig.savefig(filename, dpi=600)

        cart_proj = get_cartopy(hgt)
        fig = plt.figure(figsize=(12, 6))
        ax = plt.axes(projection=cart_proj)
        states = NaturalEarthFeature(category="cultural", scale="50m", facecolor="none",
                                     name="admin_0_boundary_lines_land")
        ax.add_feature(states, linewidth=.5, edgecolor="black")
        ax.coastlines('50m', linewidth=0.8)
        datacrs = crs.PlateCarree()
        plt.contour(to_np(lons), to_np(lats), to_np(diag_srhel_0to1), LEVELS,
                    colors="black",
                    transform=datacrs)
        plt.contourf(lons, lats, diag_srhel_0to1, LEVELS, transform=datacrs,
                     # cmap=matplotlib.colormaps.get_cmap("rainbow"))
                     cmap=get_cmap("rainbow"))
        plt.colorbar(ax=ax, shrink=.98)
        ax.set_xlim(cartopy_xlim(hgt))
        ax.set_ylim(cartopy_ylim(hgt))
        ax.gridlines(color="black", linestyle="dotted")
        plt.title("SRH 0-1km (Storm Relative Helicity) (m^2/s^2) - " + str(timestamp))
        filename = "srh-0to1-" + str(timestamp) + ".png"
        fig.savefig(filename, dpi=600)


if __name__ == '__main__':

    # Some prefixed configurations
    # os.path.join(os.getcwd()) + "/"
    base_dir = join(getcwd()) + "/"

    # sys.argv; sys.exit
    if base_dir is None and len(argv) == 1:
        print(f"""\n ERROR in command. The program parameters: {sys.argv[0]} wrfout_d02_2020-08-14_00_00_00.nc\n""")
        sys.exit(1)
    elif len(argv) == 2:
        nc_filename = argv[1]
        init_netcdf4_dataset(nc_filename)
        #plot_surface_pressure()
        #plot_precip()
        calc_cape2d()
        calc_plot_srhel()

    # Closing the NetCDF file
    # NameError: name 'nc' is not defined. Did you mean: 'np'?
    # nc.close()

"""
This variable must be supplied as a xarray.DataArray in order to copy the
dimension names to the output. Otherwise, default names will be used.
"""

"""
-----
sys.path
-----

import os
os.path.join()

from os import path
path.join()

from os import *
path.join()

from os.path import join
join()



if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(description=main.__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    arg_parser.add_argument('-f', '--file',
                            dest='file',
                            default='data/nc_raw/wrfout_d01_2018-11-19_000000.nc',
                            type=str,
                            help='Full file path to Raw WRF netCDF file ')

    arg_parser.add_argument('-s', '--save_file',
                            dest='save_file',
                            default='data/nc_subset/new_wrf-processed.nc',
                            type=str,
                            help='Full file path to save directory and save filename')

    parsed_args = arg_parser.parse_args()
    sys.exit(main(parsed_args))

"""

"""
Using xarray.Dataset with wrf-python

import xarray
import wrf

ds = xarray.open_dataset(FILENAME)
slp = wrf.getvar(ds._file_obj.ds, "slp")
"""

"""
# >>> dt = times[2]
# >>> dt
# numpy.datetime64('2020-08-14T02:00:00.000000000')
# >>> type(dt)
# <class 'numpy.datetime64'>
# >>> dt.astype('datetime64[D]')
#    numpy.datetime64('2020-08-14')
# >>> dt.astype('datetime64[h]')
#    numpy.datetime64('2020-08-14T02','h')
# >>> from datetime import datetime
# >>> dth.astype(datetime)
# datetime.datetime(2020, 8, 14, 2, 0)

"""

"""
If you need to convert an xarray.DataArray to a numpy.ndarray,
 wrf-python provides the wrf.to_np() function for this purpose.
 Although an xarray.DataArary object already contains the xarray.DataArray.values attribute to extract the Numpy array, there is a problem when working with compiled extensions. The behavior for xarray (and pandas) is to convert missing/fill values to NaN, which may cause crashes when working with compiled extensions. Also, some existing code may be designed to work with numpy.ma.MaskedArray, and numpy arrays with NaN may not work with it.
"""

# plot_geop_500hpa()
# # Extract the Geopotential Height and Pressure (hPa) fields
# z = getvar(ncfile, "z")
# p = getvar(ncfile, "pressure")
# Compute the 500 MB Geopotential Height
# ht_500mb = interplevel(z, p, 500.)
# print(ht_500mb)

# 2020-08-14T01:00:00.000000000
# timestamp:2020-08-14T01:00:00.000000000
# Time[2]= {2}
# timestamp.strftime("%Y-%m-%d_%H")
## hour = '%02d' % t

# Set Figure Size (1000 x 800)
# plt.figure(figsize=(width,height),frameon=False)
# rainc =  nc.variables['RAINC']
# rainnc = nc.variables['RAINNC']

# 0.31381142 0.31682968 0.31197727 ... 0.         0.         0.        ]]
# /home/cirrus/projects-py/pyfwrf/plot_wrf_prp.py:217: MatplotlibDeprecationWarning: The get_cmap function was deprecated in Matplotlib 3.7 and will be removed two minor releases later. Use ``matplotlib.colormaps[name]`` or ``matplotlib.colormaps.get_cmap(obj)`` instead.
#  cmap=get_cmap("rainbow"))
# timestamp:<built-in method tostring of numpy.datetime64 object at 0x7ff75026edf0>
# Time[17]= {17}
# <class 'xarray.core.dataarray.DataArray'>
# <xarray.DataArray 'RAINC' (south_north: 370, west_east: 390)> Size: 577kB
# array([[0.        , 0.        , 0.        , ..., 3.7546992 , 3.5826166 ,
#        3.7253258 ],


# for var in wrf_ds:
#    try:
#        print(f'variable: {var}, description: {wrf_ds[var].description}')
#    except:
#        pass


# Convert from mm to in prp_hour = prp_hour * .0393700787  units = 'in'

# NameError: name 'wrf' is not defined
# >>> import wrf
# >>> i = wrf.g_times.get_times(nc)
# >>> type(i)
# <class 'xarray.core.dataarray.DataArray'>
# >>> i
# <xarray.DataArray 'times' ()> Size: 8B
# array('2020-08-14T00:00:00.000000000', #dtype='datetime64[ns]')
# Attributes:
#    description:  model times [np.datetime64]

"""
# MatplotlibDeprecationWarning: The get_cmap function was deprecated in Matplotlib 3.7 and will be removed two minor releases later. Use ``matplotlib.colormaps[name]`` or ``matplotlib.colormaps.get_cmap(obj)`` instead.

#  plt.contour(to_np(lons), to_np(lats), to_np(prp_hour), 10,colors="black",transform=crs.PlateCarree())
#  raise TypeError(f"Input z must be 2D, not {z.ndim}D")
# TypeError: Input z must be 2D, not 1D
# plt.contour(to_np(lons), to_np(lats), to_np(rainc), 10,colors="black",transform=crs.PlateCarree())


fig, axs = plot.subplots(proj='cyl')


m = axs.contourf(wrf.to_np(lons), wrf.to_np(lats), wrf.to_np(slp), 
                transform=crs.PlateCarree(), cmap='roma_r')
# Adding colorbar with label
cbar = fig.colorbar(m, loc='b', label='Sea Level Pressure (hPa)') 

"""

# Function used to create the map subplots
# def plot_background(ax):
#    ax.set_extent([235., 290., 20., 55.])
#    ax.add_feature(cfeature.COASTLINE.with_scale('50m'), linewidth=0.5)
#    ax.add_feature(cfeature.STATES, linewidth=0.5)
#    ax.add_feature(cfeature.BORDERS, linewidth=0.5)
#    return ax
#     ax.add_feature(states, linewidth=.5, edgecolor="black")
#     ax.coastlines('110m', linewidth=0.8)
