#!/bin/bash

#Ruta raiz
ROOT_IN="/CHACMOOL/DATOS/RESPALDO_V4"

#Ruta raiz donde se guardaran las salidas
ROOT_OUT="/CHACMOOL/DATOS/RECORTES"

#Asignamos el año a procesar
ANIO=$1

#Ruta absoluta en donde se encuentran los netCDF del año a procesar
IN=$ROOT_IN"/a"$ANIO"/salidas/"

#Ruta absoluta en donde se guardan los netCDF recortados del año procesado
OUT=$ROOT_OUT/$ANIO

#Abrimos el directorio que se va a procesar
cd $IN

#Creamos el directo en donde se almacenaran las salidas
mkdir -p $OUT

#Los prefijos de cada tipo de netCDF según su paso de tiempo
PREFIXS=("wrfout_c1h_d01_" "wrfout_c3h_d01_" "wrfout_c15d_d01_" "wrfout_c_anio_d01_")

#Las variables meteorologicas a las que se hara el recorte de dominio, ordenadas segun su paso de tiempo
VARS=("-v Times,P,Q2,T2,PSFC,U10,V10,XTIME,TSK,RAINC,RAINNC,SWDOWN,GLW,OLR,ALBEDO,HFX,QFX,LH,SST" "-v Times,U,V,W,PH,T,XTIME,QVAPOR,CLDFRA" "-v Times,XLAT,XLONG,LU_INDEX,ZNU,ZNW,ACHFX,ACLHF,ALBEDO,CLDFRA,EMISS,GLW,HFX,HGT,LAKEMASK,LANDMASK,LH,OLR,P,PB,PBLH,PHB,PSFC,Q2,QFX,QRAIN,QVAPOR,RAINC,RAINNC,SMOIS,SST,SSTSK,SWDOWN,T,T00,T2,TSK,U10,UST,V10,XLAT_U,XLAT_V,XLONG,XLONG_U,XLONG_V,XTIME" "")

#Indices west-east (direccion oeste-este) del dominio a recortar
west=313
east=533

west_stag=313
east_stag=534

#Indices south-north (direccion sur-norte) del dominio a recortar
south=121
north=307

south_stag=121
north_stag=308

#Iteramos sobre la cantidad de prefijos que existen en el arreglo 'PREFIXS'   
for i in `seq 0 3`;do
	#Obtenemos el prefijo
	prefix=${PREFIXS[$i]}
	#Obtenemos las variables relacionadas con el prefijo
	var=${VARS[$i]}
		
	#Iteramos sobre todos los archivos que cumplen con el prefijo
	for netCDF in $prefix*;do
  
		echo "Procesando" $netCDF "..."
		
                #Ejecutamos el recorte de dominio sobre el archivo con 'ncrcat', e indicamosla ruta de la salida con '-o'
		time ncrcat -dwest_east,$west,$east -dsouth_north,$south,$north -dwest_east_stag,$west_stag,$east_stag -dsouth_north_stag,$south_stag,$north_stag $var $netCDF -o $salida/$netCDF.nc
		
    echo "OK"
	
  done

done
