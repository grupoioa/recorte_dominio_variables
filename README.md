# Recorte de dominio al GoM de variables meteorológicas
Se realiza un recorte de dominio al **GoM** sobre los netCDF del re-análisis que se hace sobre el modelo WRF versión 4.  

## Primeros pasos
Estos scripts estan diseñados para ejecutarse sobre un cluster(en nuestro caso sobre el cluster Ometeotl).Para obtener una  
copia del proyecto basta con hacer lo siguiente : 
   
   `git clone https://github.com/grupoioa/recorte_dominio_variables.git`  

En caso de que se quieran modificar las rutas de las entradas, salidas y los indices de los recortes en necesario cambiar  
en el archivo `recortes.sh` las siguientes variables :    

   * ROOT_IN : es la ruta raíz en donde se encuentran nuestros archivos netCDF de entrada.  
   * IN : es la ruta absoluta del año que se esté procesando, se cambiara solo en caso de cambiar la estructura del directorio.  
   * ROOT_OOUT : es la ruta raiz en donde se guardaran nuestros archivos netCDF que generemos.     
   * OUT: es la ruta absoluta del año que se esta procesando.
   
### Prerrequisitos
   * Sistemas operativo CentOS release 6.9 (Cluster)
   * Administrador de cluster [SLURM][1]
   * Lenguaje [Bash][2]
   * Herramienta [NCO 4.6.7 (ncrcat)][3]

## Probando
Para ejecutar el script se tiene que hacer lo siguiente desde una línea de comando:  

   `user@:~$ SBATCH run_recortes.sh`  

 #### Descripción del script `` run_recortes.sh ``
 Este script manda a ejecutar el script `recortes.sh` 39 veces de forma paralela en el cluster, este número se determina por  
 el intervalo *1979-2017*, que son los años que se van procesar. 

 La forma en como paralelizamos los scripts es por medio de un `for` :  
 
 ``` 
  for ANIO in $(seq 1979 2017);do
    time srun -N1 -n1 --exclusive bash recortes.sh $ANIO &
  done
 ```  

 En donde *ANIO* toma los valores de 1979 hasta 2017 y en cada valor de esta varible se pasa como parametro :  

 ``time srun -N1 -n1 --exclusive bash recortes.sh $ANIO``  

 , lo que hace `srun -N1 -n1 --exclusive` es ejecutar el script de manera exclusiva en un core del cluster.
 
 Hay que aclarar que las lineas que empiezan con `#SBATCH` no son comentarios, estas variables nos permiten especificar  
 la manera en que *SLURM* administrará nuestros procesos. 
 
 #### Descripción del script ``recortes.sh``
 Es importante mencionar que orden de los valores en los arreglos *PREFIXS* y *VARS* estan relacionados  
 
 ```
 PREFIXS=("wrfout_c1h_d01_" "wrfout_c3h_d01_" "wrfout_c15d_d01_" "wrfout_c_anio_d01_")  
 
 VARS=("-v P,Q2,T2,PSFC,U10,V10,XTIME,TSK,RAINC,RAINNC,SWDOWN,GLW,OLR,ALBEDO,HFX,QFX,LH,SST" "-v U,V,W,PH,T,XTIME,QVAPOR,CLDFRA" "-v XLAT,XLONG,LU_INDEX,ZNU,ZNW,ACHFX,ACLHF,ALBEDO,CLDFRA,EMISS,GLW,HFX,HGT,LAKEMASK,LANDMASK,LH,OLR,P,PB,PBLH,PHB,PSFC,Q2,QFX,QRAIN,QVAPOR,RAINC,RAINNC,SMOIS,SST,SSTSK,SWDOWN,T,T00,T2,TSK,U10,UST,V10,XLAT_U,XLAT_V,XLONG,XLONG_U,XLONG_V,XTIME" "")
 ```  
 
 , y esta relación está determinada por la posición de los valores en el arreglo, es decir :
    
   * al prefijo **wrfout_c1h_d01_** le corresponde las variables : P, Q2, T2, PSFC, U10, V10, XTIME, TSK, RAINC, RAINNC,  
      SWDOWN, GLW, OLR, ALBEDO, HFX, QFX, LH, SST.  
   * al prefijo **wrfout_c3h_d01_** le corresponde las variables : U, V, W, PH, T, XTIME, QVAPOR, CLDFRA  
   * al prefijo **wrfout_c15d_d01_** le corresponde las variables : XLAT, XLONG, LU_INDEX, ZNU, ZNW, ACHFX, ACLHF, ALBEDO,  
     CLDFRA,EMISS, GLW, HFX, HGT, LAKEMASK, LANDMASK, LH, OLR, P, PB, PBLH, PHB, PSFC, Q2, QFX, QRAIN, QVAPOR, RAINC,  
     RAINNC, SMOIS, SST, SSTSK, SWDOWN, T, T00, T2, TSK, U10, UST, V10, XLAT_U, XLAT_V, XLONG, XLONG_U, XLONG_V, XTIME.  
   * al prefijo **wrfout_c_anio_d01_** se relaciona con la cadena vacia *""* lo que significa que tomara encuenta todas  
     las variables que se encuentren en el netCDF.

 Ahora en el caso de las variables *west*, *east*, *south* y *north*, estas son los indices o limites que se consideran para  
 hacer el recorte del dominio.  
    
   * **west** es el índice sobre el eje X más a la izquierda.  
   * **east** es el indice sobre el eje X más a la derecha.  
   * **south** es el índice sobre el eje Y más hacia abajo.  
   * **north** es el indice sobre el eje Y más hacia arriba.  

 El ciclo `for` se realiza 4 veces desde el índice 0 al 3 ya que es la cantidad de elementos que hay en tanto ene l arreglo  
 *PREFIXS* como en el arreglo *VARS*,  

 ``for i in `seq 0 3`;do``  

 El siguiente `for` lo que hace es ejecutar el comando `ncrcat` de *NCO* en cada archivo netCDF que cumpla con el prefijo.

 ```
  for netCDF in $prefix*;do  
    time ncrcat -dwest_east,$west,$east -dsouth_north,$south,$north $var $netCDF -o $salida/$netCDF.nc  		
	done
 ```  

## Construido con
* [Bash][2] Lenguaje de programación
* [NCO][3] Usado para generar los recortes en los netCDF.

## Versionando  
Usamos [SemVer][4] para versionar. Para las versiones disponibles, consulte [las etiquetas en este repositorio][5].

## Autores
* **Raúl Medina Peña** - [Github][6]

## Licencia
Este proyecto está licenciado bajo la licencia MIT; consulte el archivo [LICENSE](LICENSE) para obtener detalles.

## Agradecimientos  
* Agradecemos a Roberto Pineda Leon por su colaboración y apoyo en este proyecto.

[1]: https://slurm.schedmd.com/sbatch.html
[2]: https://www.gnu.org/software/bash/
[3]: http://nco.sourceforge.net/
[4]: https://semver.org/lang/es/
[5]: https://github.com/grupoioa/recorte_dominio_variables/tags
[6]: https://github.com/rmedina09
