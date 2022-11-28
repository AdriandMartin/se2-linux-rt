-> SYSCALL
stressor	|	load average using FPK/NFP (last minute)	|	latency obtained (FPK)	|	latency obtained (NFP)
------------------------------------------------------------------------------------------------------------------------------------
--tee 1	|			0.36/0.20			|		450us		|		120us
--tee 10	|			1.77/1.48			|		620us		|		500us
--tee 20	|			3.10/2.82			|		800us		|		680us
__________________________________________________________________________________________________________________________________________________________________
PROBLEMA: cuando se usa sleep, el flag sleep-max es mucho más sensible de lo que se pensaba; parece que 1024 no era el número de hilos de kernel que se creaban por defecto si no se indicaba nada, porque con 256 como valor de sleep-max y un solo worker se llega a una carga de trabajo en el último minuto superior a 9; por lo tanto, parece más apropiado modificar el valor de sleep-max en vez del número de workers
PROBLEMA: la carga de trabajo generada con una misma parametrización de la herramienta stress-ng varía en función del modelo de expulsión con el que esté configurado el kernel
PROBLEMA: el mismo stressor tampoco genera la misma carga de trabajo según el tracer que se use, pues el tracer como tal también supone una sobrecarga en función de cuál se use
__________________________________________________________________________________________________________________________________________________________________
-> SCHEDULING
stressor			|	load average using FPK/NFP (last minute)	|	latency obtained (FPK)	|	latency obtained (NFP)
---------------------------------------------------------------------------------------------------------------------------------------------------
--sleep 1 --sleep-max 4	|			0.08/0.14			|		701us		|		280us
--sleep 1 --sleep-max 24	|			0.44/0.44			|		1480us		|		500us
--sleep 1 --sleep-max 44	|			2.90/1.70			|		1850us		|		810us
__________________________________________________________________________________________________________________________________________________________________
-> IRQSOFF
stressor			|	load average using FPK/NFP (last minute)	|	latency obtained (FPK)	|	latency obtained (NFP)
---------------------------------------------------------------------------------------------------------------------------------------------------
--sleep 1 --sleep-max 4	|			0.49/0.14			|		880us		|		620us
--sleep 1 --sleep-max 24	|			3.00/2.50			|		1110us		|		880us
--sleep 1 --sleep-max 34	|			4.50/3.86			|		1140us		|		920us
--sleep 1 --sleep-max 44	|			6.00/4.65			|		1200us		|		980us
__________________________________________________________________________________________________________________________________________________________________
DECISIONES
==========
Irqsoff
4,7,10,13,16,19,22,25,28,31,34
#11

Scheduling
4,8,12,16,20,24,28,32,36,40,44
#11

Systemcalls
1,3,5,7,9,11,13,15,17,19,21
#11

=> Hay qye hacer un poweroff entre tandas de pruebas distintas (irqsoff, scheduling,...) porque el "trace-cmd reset" de principio del script no es suficiente para restaurar el rendimiento
