#!/bin/sh
###############################################################################
# Script: irqsoff_latency.sh
# Autor: Adrián Martín
# Objetivo: medida de latencia de planificación a distintos niveles de carga 
#           del sistema operativo usando filtros sobre el report de trace-cmd
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
OUTPUT_DIR="measurements/scheduling-w" # directorio en el que volcar los reports
REPETITIONS="10" # número de repeticiones de cada prueba
#  Relativas a las pruebas
INI_WORKERS="4" # número de workers inicial
STEP="4" # incremento del número de workers entre pruebas consecutivas
MAX_WORKERS="44" # número límite de workers a utilizar en las pruebas
STRESSOR="sleep 1 --sleep-max" # para este stressor se parametriza el número de pthreads que genera cada worker, en vez del número de workers

#------------------------------------------
# Realización de las pruebas

mkdir -p ${OUTPUT_DIR}
cd ${OUTPUT_DIR}

trace-cmd reset # desactiva lo relativo a ftrace y devuelve todas sus estructuras de datos a los valores por defecto

echo "Comenzando mediciones de wakeup promedio"

for NUM_WORKERS in $(seq ${INI_WORKERS} ${STEP} ${MAX_WORKERS}); do

	echo "PRUEBA: ${REPETITIONS} iteracciones de ${STRESSOR} usando ${NUM_WORKERS} workers"
	
	mkdir ${NUM_WORKERS}

	for TEST_NUMBER in $(seq ${REPETITIONS}); do
		trace-cmd record -e sched_switch -e sched_wakeup stress-ng -q --timeout 10 --${STRESSOR} ${NUM_WORKERS}
		trace-cmd report -w | tail -n 50 > ${NUM_WORKERS}/${TEST_NUMBER}
		sleep 10 # dar unos segundos de descanso al sistema entre pruebas
	done

	sleep 20 # dar unos segundos de descanso al sistema entre pruebas

done

echo "Finalizadas mediciones de wakeup promedio"

exit 0