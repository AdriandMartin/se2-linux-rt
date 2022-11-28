#!/bin/sh
###############################################################################
# Script: irqsoff_latency.sh
# Autor: Adrián Martín
# Objetivo: medida de la duración de las llamadas al sistema a distintos 
#           niveles de carga del sistema operativo
# Dependencias: trace-cmd, stress-ng
###############################################################################

# Comprobación de privilegios
if [ $( id -u ) -ne 0 ]
then
	echo "Este script necesita ser ejecutado con privilegios de administrador"
	exit 1
fi

#------------------------------------------
# Declaración de variables
OUTPUT_DIR="measurements/syscalls" # directorio en el que volcar los reports
REPETITIONS="10" # número de repeticiones de cada prueba
#  Relativas a las pruebas
INI_WORKERS="1" # número de workers inicial
STEP="2" # incremento del número de workers entre pruebas consecutivas
MAX_WORKERS="22" # número límite de workers a utilizar en las pruebas
STRESSOR="tee" # tee realiza llamadas write y read principalmente
SYSCALL="write"

#------------------------------------------
# Realización de las pruebas

mkdir -p ${OUTPUT_DIR}
cd ${OUTPUT_DIR}

trace-cmd reset # desactiva lo relativo a ftrace y devuelve todas sus estructuras de datos a los valores por defecto

echo "Comenzando mediciones de syscall"

for NUM_WORKERS in $(seq ${INI_WORKERS} ${STEP} ${MAX_WORKERS}); do

	echo "PRUEBA: ${REPETITIONS} iteracciones de ${STRESSOR} usando ${NUM_WORKERS} workers"
	
	mkdir ${NUM_WORKERS}

	for TEST_NUMBER in $(seq ${REPETITIONS}); do
		trace-cmd start -e sys_enter_${SYSCALL} -e sys_exit_${SYSCALL} -O latency-format stress-ng -q --timeout 10 --${STRESSOR} ${NUM_WORKERS}; trace-cmd stop
		trace-cmd show | tail -n +21 > ${NUM_WORKERS}/${TEST_NUMBER}
		sleep 10 # dar unos segundos de descanso al sistema entre pruebas
	done

	sleep 20 # dar unos segundos de descanso al sistema entre pruebas

done

echo "Finalizadas mediciones de syscall"

exit 0