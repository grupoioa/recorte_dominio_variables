!/bin/bash

#############################################################
# Centro de Ciencias de la Atmosfera
# Raúl Medina Peña
# raulmp@ciencias.unam.mx
# Script que envia en forma paralela scripts que utilizan NCO 
#############################################################

#SBATCH -J NCO_recortes
#SBATCH -p workq2
#SBATCH -N 1 # Numero de Nodos 
#SBATCH --ntasks-per-node 1 # Número de tareas por nodo
#SBATCH -t 5-00:00 # Tiempo (D­HH:MM) 
#SBATCH -o slurm.%x.%j.out # STDOUT Salida estandar (tag name,id)
#SBATCH -e slurm.%x.%j.err # STDERR Error estándar (tag name,id)

##DEBUG##
##Cargamos el modulo de NCO 
module load herramientas/nco/4.6.7

##Iteramos sobre los años y eviamos los proceso a ejecutarse en el cluster
for ANIO in $(seq 1979 2017);do
  #enviamos a correr de manera exclusiva cada proceso en un core 
	time srun -N1 -n1 --exclusive bash recortes.sh $ANIO &
done
#con 'wait' espera a que terminen todos los procesos que se enviaron
wait
